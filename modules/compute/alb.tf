resource "aws_lb" "alb" {
    name = "${var.env}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_sg.id]
    subnets = var.public_alb_subnet_ids
}

resource "aws_lb_target_group" "lambda_tg" {
    name = "${var.env}-lambda-tg"
    target_type = "lambda"
}

resource "aws_lb_listener" "alb_listener" {
    load_balancer_arn = aws_lb.alb.arn
    port = 443
    protocol = "HTTPS"
    
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.lambda_tg.arn
    }
}

resource "aws_lb_target_group_attachment" "lambda_attachment" {
    target_group_arn = aws_lb_target_group.lambda_tg.arn
    target_id = aws_lambda_function.web_app.arn
    depends_on = [aws_lambda_permission.allow_alb]
}