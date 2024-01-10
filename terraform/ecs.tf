resource "aws_ecs_cluster" "notes-prod-ecs_cluster" {
  name = "notes-prod"
}

resource "aws_ecs_task_definition" "notes-prod-ecs_td" {
  container_definitions = <<TASK_DEFINITION
[
  {
    "cpu": 0,
    "environment": [],
    "essential": true,
    "image": "584916250327.dkr.ecr.us-west-2.amazonaws.com/notes-api:latest",
    "name": "notes-api-container",
    "portMappings": [
      {
        "containerPort": 8000,
        "hostPort": 80,
        "name": "notes-api-container-8000-tcp",
        "protocol": "tcp"
      }
    ],
    "volumesFrom": [],
    "secrets": [
      {
        "name": "MONGO_USER",
        "valueFrom": "arn:aws:secretsmanager:us-west-2:584916250327:secret:notes-mongo-eIdNP9:MONGO_USER::"
      },
      {
        "name": "MONGO_PASS",
        "valueFrom": "arn:aws:secretsmanager:us-west-2:584916250327:secret:notes-mongo-eIdNP9:MONGO_PASS::"
      }
    ]
  }
]
  TASK_DEFINITION
  cpu = "1024"
  execution_role_arn = "arn:aws:iam::584916250327:role/ecsTaskExecutionRole"
  family = "notes-prod-task"
  memory = "64"
  requires_compatibilities = ["EC2"]
}

resource "aws_ecs_service" "notes-prod-ecs_service" {
  name = "notes-prod-ecs_service"
  cluster = aws_ecs_cluster.notes-prod-ecs_cluster.id
  task_definition = aws_ecs_task_definition.notes-prod-ecs_td.arn
  scheduling_strategy = "DAEMON"
}