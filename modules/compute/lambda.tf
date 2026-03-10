resource "aws_lambda_function" "web_app" {
    function_name = "${var.env}-web-app"
    role = aws_iam_role.lambda_exec_role.arn
    handler = "index.handler"
    runtime = "nodejs14.x"

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
}

resource "aws_lambda_permission" "allow_alb" {
    statement_id = "AllowExecutionFromALB"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.web_app.function_name
    principal = "elasticloadbalancing.amazonaws.com"
    source_arn = aws_lb_target_group.lambda_tg.arn
}

resource "local_file" "lambda_template" {
  filename = "${path.module}/index.mjs"
  content  = <<-EOF
    import net from 'net';

    export const handler = async (event) => {
      // We grab the proxy endpoint you passed in via Terraform environment variables
      const dbHost = process.env.DB_HOST; 
      const dbPort = 3306;

      return new Promise((resolve) => {
        const socket = new net.Socket();
        socket.setTimeout(3000); // 3-second timeout so the Lambda doesn't hang forever

        // Try to connect to the RDS Proxy
        socket.connect(dbPort, dbHost, () => {
          socket.destroy(); // Clean up the connection
          resolve({
            statusCode: 200,
            headers: { "Content-Type": "text/html" },
            body: `<h1>Network Success!</h1><p>The Lambda function successfully reached the RDS Proxy at <b>$${dbHost}:$${dbPort}</b>.</p>`
          });
        });

        // If the connection fails (e.g., Security Group issue)
        socket.on('error', (err) => {
          resolve({
            statusCode: 500,
            headers: { "Content-Type": "text/html" },
            body: `<h1>Connection Failed!</h1><p>Error: $${err.message}</p>`
          });
        });

        // If the connection times out (e.g., Subnet routing issue)
        socket.on('timeout', () => {
          socket.destroy();
          resolve({
            statusCode: 500,
            headers: { "Content-Type": "text/html" },
            body: `<h1>Timeout!</h1><p>Could not reach the RDS Proxy within 3 seconds.</p>`
          });
        });
      });
    };
  EOF
}

data "archive_file" "lambda_zip" {
    type = "zip"
    source_file = local_file.lambda_template.filename
    output_path = "${path.module}/lambda_function_payload.zip"
}