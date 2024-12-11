resource "aws_ecs_task_definition" "ecs_task_definition" {
    family             = var.ecs_deployment_name
    network_mode       = "awsvpc"
    execution_role_arn = var.execution_role_arn
    task_role_arn           = var.execution_role_arn
    cpu                = 256
    memory             = 1024
    requires_compatibilities = ["FARGATE"]
    runtime_platform {
        operating_system_family = "LINUX"
        cpu_architecture        = "X86_64"
    }

    container_definitions = jsonencode([
        {
            name      = var.ecs_container_name
            image     = var.ecs_deployment_image
            cpu       = 256
            memory    = 1024
            enableExecuteCommand = true
            essential = true
            portMappings = [
                {
                    name          = var.ecs_deployment_name
                    containerPort = var.app_port
                    hostPort      = var.app_port
                    protocol      = "tcp"
                    appProtocol   = "http"
                }
            ]
            logConfiguration = {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-create-group": "true",
                    "awslogs-group": "/ecs/${var.ecs_deployment_name}",
                    "awslogs-region": "us-west-1",
                    "awslogs-stream-prefix": "ecs"
                },
                "secretOptions": []
            }
            environment = var.environment_vars
        }
    ])

    # Description: This resource defines an ECS task definition named var.ecs_deployment_name.
    # It uses the Fargate launch type with specified CPU and memory.
    # The task runs a container from the specified image, with port mappings for containerPort 5000 and hostPort 5000.
}

resource "aws_ecs_service" "ecs_service" {
    name            = var.ecs_container_name
    cluster         = var.aws_ecs_cluster_id
    task_definition = aws_ecs_task_definition.ecs_task_definition.arn
    desired_count   = var.replicas
    launch_type     = "FARGATE"
    enable_execute_command = true

    service_connect_configuration {
        enabled = true
        namespace = var.namespace_arn
    }

    network_configuration {
        subnets         = var.internal_alb ? var.private_subnet_ids : var.public_subnet_ids
        security_groups = var.sg_ids
        assign_public_ip = true
    }

    # Description: This block defines the network configuration for the ECS service.
    # It specifies the subnets and security groups to use, and assigns a public IP to the tasks.

    load_balancer {
        target_group_arn = aws_lb_target_group.ecs_tg.arn
        container_name   = var.ecs_container_name
        container_port   = var.app_port
    }

    # Description: This block configures the load balancer for the ECS service.
    # It specifies the target group ARN, container name, and container port for the load balancer.

    depends_on = [
        aws_lb_listener.ecs_alb_listener
    ]

    # Description: This resource creates an ECS service named var.ecs_deployment_name.
    # It runs on the specified ECS cluster and uses the defined task definition.
    # The service is configured to run 2 instances of the task using the Fargate launch type.
}