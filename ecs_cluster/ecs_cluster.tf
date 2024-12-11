# Create an ECS cluster named "dev-ecs-cluster"
resource "aws_ecs_cluster" "ecs_cluster" {
    name = "dev-ecs-cluster"

    # Description: This resource creates an ECS cluster named "dev-ecs-cluster".
}

resource "aws_service_discovery_http_namespace" "development" {
  name        = "development"
  description = "test-namespace"
}

# Create a DB subnet group for the RDS instance
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = data.aws_subnet_ids.subnets.ids

  tags = {
    Name = "My DB subnet group"
  }
}

# Create a custom parameter group for PostgreSQL
resource "aws_db_parameter_group" "blossom_postgres_parameter_group" {
  name        = "blossom-postgres-parameter-group"
  family      = "postgres16"
  description = "Custom parameter group for PostgreSQL"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
    apply_method = "immediate"
  }

  parameter {
    name  = "log_statement"
    value = "all"
    apply_method = "immediate"
  }
}

# Create a PostgreSQL RDS instance
resource "aws_db_instance" "postgres" {
    allocated_storage = 10
    db_name = "testLocal"
    storage_type = "gp2"
    engine = "postgres"
    engine_version = "16.3"
    instance_class = "db.t3.micro"
    identifier = "postgres"
    username = "myusername"
    password = "mypassword"
    publicly_accessible = true
    parameter_group_name = aws_db_parameter_group.blossom_postgres_parameter_group.name

    vpc_security_group_ids = data.aws_security_groups.default_vpc_security_groups.ids
    db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

    skip_final_snapshot = true
}

# Module for deploying the test API
module "test-api" {
    source = "../modules/ecs-deployment"
    ecs_deployment_image = "897722673755.dkr.ecr.us-west-1.amazonaws.com/blossom/test-api:latest"
    ecs_deployment_name = "test-api"
    ecs_container_name = "testNodeContainer"
    internal_alb = false
    app_port = 4000
    replicas = 2
    aws_ecs_cluster_id = aws_ecs_cluster.ecs_cluster.id
    private_subnet_ids = data.aws_subnet_ids.subnets.ids
    public_subnet_ids = data.aws_subnet_ids.subnets.ids
    sg_ids = data.aws_security_groups.default_vpc_security_groups.ids
    vpc_id = data.aws_vpc.default_vpc.id
    execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
    namespace_arn = aws_service_discovery_http_namespace.development.arn
    environment_vars = [
        {
            "name": "SEQ_PW",
            "value": "mypassword"
        },
        {
            "name": "SEQ_USER",
            "value": "myusername"
        },
        {
            "name": "SEQ_DB",
            "value": "testLocal"
        },
        {
            "name": "SEQ_PORT",
            "value": 5432
        },
        {
            "name": "SEQ_HOST",
            "value": aws_db_instance.postgres.address
        },
        {
            "name": "Test",
            "value": "test"
        }
    ]
}

# Module for deploying the test application
module "test-app" {
    source = "../modules/ecs-deployment"
    ecs_deployment_image = "897722673755.dkr.ecr.us-west-1.amazonaws.com/blossom/test-app:latest"
    ecs_deployment_name = "test-app"
    ecs_container_name = "testReactContainer"
    internal_alb = false
    app_port = 3000
    replicas = 2
    aws_ecs_cluster_id = aws_ecs_cluster.ecs_cluster.id
    private_subnet_ids = data.aws_subnet_ids.subnets.ids
    public_subnet_ids = data.aws_subnet_ids.subnets.ids
    sg_ids = data.aws_security_groups.default_vpc_security_groups.ids
    vpc_id = data.aws_vpc.default_vpc.id
    execution_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
    namespace_arn = aws_service_discovery_http_namespace.development.arn
    environment_vars = [
        {
            "name": "REACT_APP_URL_API",
            "value": "http://${module.test-api.alb_url}:4000"
        }
    ]
    health_check_code = "200,304"
}
