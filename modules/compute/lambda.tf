resource "aws_lambda_function" "web_app" {
    function_name = "${var.env}-web-app"
    role = aws_iam_role.lambda_exec_role.arn
    handler = "index.handler"
    runtime = "nodejs20.x"

    filename = data.archive_file.lambda_zip.output_path
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
    
    vpc_config {
        subnet_ids = var.private_lambda_subnet_ids
        security_group_ids = [aws_security_group.lambda_sg.id]
    }

    environment {
        variables = {
            DB_HOST = var.aurora_proxy_endpoint
        }
    }

    tags = merge(var.tags, {
        Name = "${var.env}-lambda-web-app"
    })
}

resource "aws_lambda_permission" "allow_alb" {
    statement_id = "AllowExecutionFromALB"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.web_app.function_name
    principal = "elasticloadbalancing.amazonaws.com"
    source_arn = aws_lb_target_group.lambda_tg.arn
}

resource "local_file" "lambda_template" {
  filename = "${path.module}/lambda_src/index.mjs"
  content  = <<-EOF
    import mysql from 'mysql2/promise';

    export const handler = async (event) => {
      const dbHost = process.env.DB_HOST;
      const dbUser = process.env.DB_USER;
      const dbPassword = process.env.DB_PASSWORD;
      // const dbName = process.env.DB_NAME; // Uncomment if connecting to a specific DB

      try {
        // 1. Attempt to authenticate with the RDS Proxy
        const connection = await mysql.createConnection({
          host: dbHost,
          user: dbUser,
          password: dbPassword,
          connectTimeout: 3000 // 3 seconds
        });

        // 2. Execute a real SQL query
        const [rows] = await connection.execute('SELECT 1 + 1 AS solution');
        await connection.end();

        return {
          statusCode: 200,
          headers: { "Content-Type": "text/html" },
          body: `
            <div style="font-family: sans-serif; padding: 20px;">
              <h1 style="color: #4CAF50;">✅ Full Database Connection Successful!</h1>
              <p>The Lambda function reached the RDS Proxy at <b>$${dbHost}</b>.</p>
              <p>Authentication was successful.</p>
              <p><b>Database Query Result (SELECT 1 + 1):</b> $${rows[0].solution}</p>
            </div>
          `
        };

      } catch (err) {
        // If the password is wrong, or the network times out
        return {
          statusCode: 500,
          headers: { "Content-Type": "text/html" },
          body: `
            <div style="font-family: sans-serif; padding: 20px;">
              <h1 style="color: #F44336;">❌ Connection Failed!</h1>
              <p><b>Error Code:</b> $${err.code}</p>
              <p><b>Message:</b> $${err.message}</p>
            </div>
          `
        };
      }
    };
  EOF
}

data "archive_file" "lambda_zip" {
    type = "zip"
    source_file = "${path.module}/lambda_src"
    output_path = "${path.module}/lambda_function_payload.zip"
}