provider "aws" {
    region = "us-east-2"
}
# server is just an ES2 instance. WE a simple want the server to answer our query

resource "aws_launch_configuration" "example_ec2" {
  image_id = "ami-0c55b159cbfafe1f0" 
  instance_type = "t2.micro"

  user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p "${var.server_port}" & 
                EOF

  security_groups = [aws_security_group.asg_ec2_example.id]

    lifecycle {
      create_before_destroy = true
  }
}


resource "aws_security_group" "asg_ec2_example" {
    name = "asg_ec2_example"

    ingress {
        from_port = var.server_port
        to_port = var.server_port
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] #specifies range of IP adresses
    }
}

variable "server_port" {
    description = "HTTP requests port"
    type = number
    default = 8080
}

# output "public_ip" {
#     value = aws_instance.example_ec2.public_ip
#     description = "Public server IP"
# }

# launch from 2 to 10 machines with name =  Name
resource "aws_autoscaling_group" "autoscaling_example" {
    launch_configuration = aws_launch_configuration.example_ec2.id

    min_size = 2 # num of instances we want to run
    max_size = 10

    load_balancers = [aws_elb.elb_example.name]
    health_check_type = "ELB"
    availability_zones = data.aws_availability_zones.all.names

    tag {
        key = "Name"
        value = "autoscaling_example"
        propagate_at_launch = true
    }
}

data "aws_availability_zones" "all" {}

# load balancer 
resource "aws_elb" "elb_example" {
    name = "elbexample"
    availability_zones = data.aws_availability_zones.all.names
    security_groups = [aws_security_group.elb.id]

    health_check{
        target = "HTTP:${var.server_port}/"
        interval = 30
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }

    listener {
        lb_port = 80
        lb_protocol = "http"
        instance_port = var.server_port
        instance_protocol = "http"
    }
}

# allow requests from load balancer
resource "aws_security_group" "elb" {
    name = "terraform-elb"

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] #specifies range of IP adresses
    }
}

## DATABASE INSTANCE

resource "aws_db_instance" "default" {
  allocated_storage    = 30
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mysqldb"
  username             = "dvpopov"
  password             = "mypassword"
  parameter_group_name = "default.mysql5.7"
}

output "db_instance_endpoint"  {
  value = aws_db_instance.default.endpoint
  description = "DB instance endpoint example output:"
}


output "dns_name" {
    value = aws_elb.elb_example.dns_name
    description = "DNS name"
}





