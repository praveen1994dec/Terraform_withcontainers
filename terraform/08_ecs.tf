# resource "aws_ecs_cluster" "production" {
#   name = "${var.ecs_cluster_name}-cluster"
# }

# resource "aws_launch_configuration" "ecs" {
#   name                        = "${var.ecs_cluster_name}-cluster"
#   image_id                    = lookup(var.amis, var.region)
#   instance_type               = var.instance_type
#   security_groups             = [aws_security_group.ecs.id]
#   iam_instance_profile        = aws_iam_instance_profile.ecs.name
#   key_name                    = aws_key_pair.production.key_name
#   associate_public_ip_address = true
#   user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${var.ecs_cluster_name}-cluster' > /etc/ecs/ecs.config"
# }

# data "template_file" "app" {
#   template = file("templates/django_app.json.tpl")

#   vars = {
#     docker_image_url_django = var.docker_image_url_django
#     region                  = var.region
#   }
# }

# resource "aws_ecs_task_definition" "app" {
#   family                = "django-app"
#   container_definitions = data.template_file.app.rendered
# }

# resource "aws_ecs_service" "production" {
#   name            = "${var.ecs_cluster_name}-service"
#   cluster         = aws_ecs_cluster.production.id
#   task_definition = aws_ecs_task_definition.app.arn
#   iam_role        = aws_iam_role.ecs-service-role.arn
#   desired_count   = var.app_count
#   depends_on      = [aws_alb_listener.ecs-alb-http-listener, aws_iam_role_policy.ecs-service-role-policy]

#   load_balancer {
#     target_group_arn = aws_alb_target_group.default-target-group.arn
#     container_name   = "django-app"
#     container_port   = 8000
#   }
# }

# ECS Cluster
resource "aws_ecs_cluster" "production" {
  name = "${var.ecs_cluster_name}-cluster"
}

# ✅ Launch Template (replaces Launch Configuration)
resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.ecs_cluster_name}-lt-"
  image_id      = lookup(var.amis, var.region)
  instance_type = var.instance_type
  key_name      = aws_key_pair.production.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  network_interfaces {
    security_groups             = [aws_security_group.ecs.id]
    associate_public_ip_address = true
  }

  # Note: user_data must be base64-encoded in Launch Templates
  user_data = base64encode(<<EOF
#!/bin/bash
echo "ECS_CLUSTER='${var.ecs_cluster_name}-cluster'" > /etc/ecs/ecs.config
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.ecs_cluster_name}-ecs-instance"
    }
  }
}

# ✅ Auto Scaling Group using Launch Template
resource "aws_autoscaling_group" "ecs" {
  name                      = "${var.ecs_cluster_name}-asg"
  max_size                  = 3
  min_size                  = 2
  desired_capacity           = 2
  vpc_zone_identifier        = var.subnet_ids
  health_check_type          = "EC2"

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.ecs_cluster_name}-ecs-instance"
    propagate_at_launch = true
  }
}

# ECS Task Definition
data "template_file" "app" {
  template = file("templates/django_app.json.tpl")

  vars = {
    docker_image_url_django = var.docker_image_url_django
    region                  = var.region
  }
}

resource "aws_ecs_task_definition" "app" {
  family                = "django-app"
  container_definitions = data.template_file.app.rendered
}

# ECS Service
resource "aws_ecs_service" "production" {
  name            = "${var.ecs_cluster_name}-service"
  cluster         = aws_ecs_cluster.production.id
  task_definition = aws_ecs_task_definition.app.arn
  iam_role        = aws_iam_role.ecs-service-role.arn
  desired_count   = var.app_count
  depends_on      = [
    aws_alb_listener.ecs-alb-http-listener,
    aws_iam_role_policy.ecs-service-role-policy
  ]

  load_balancer {
    target_group_arn = aws_alb_target_group.default-target-group.arn
    container_name   = "django-app"
    container_port   = 8000
  }
}
