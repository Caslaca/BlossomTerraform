resource "aws_lb" "ecs_alb" {
    name               = "${var.ecs_deployment_name}-alb"
    internal           = var.internal_alb
    load_balancer_type = "application"
    security_groups    = var.sg_ids
    subnets            = var.internal_alb ? var.private_subnet_ids : var.public_subnet_ids

    tags = {
        Name = "${var.ecs_deployment_name}-alb"
    }

    # Description: This resource creates an Application Load Balancer (ALB) named "xxx-alb".
    # It is an external ALB (internal = false) and uses the specified security groups and subnets.
    # The ALB is tagged with the name "xxx-alb" and depends on the public route table association.
}

resource "aws_lb_listener" "ecs_alb_listener" {
    load_balancer_arn = aws_lb.ecs_alb.arn
    port              = var.app_port
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.ecs_tg.arn
    }

    # Description: This resource creates a listener for the ALB on port 80 using the HTTP protocol.
    # The default action forwards requests to the specified target group.
}

resource "aws_lb_target_group" "ecs_tg" {
    name        = "${var.ecs_deployment_name}-target-group"
    port        = var.app_port
    protocol    = "HTTP"
    target_type = "ip"
    vpc_id      = var.vpc_id

    health_check {
        path = "/"
        matcher = var.health_check_code
        protocol = "HTTP"
    }

    # Description: This resource creates a target group named "xxx-target-group" for the ALB.
    # It listens on port var.vpc_id (since the container are using this port) using the HTTP protocol and targets IP addresses.
}
