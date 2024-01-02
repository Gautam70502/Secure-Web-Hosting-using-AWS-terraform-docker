


# terraform {
#   required_providers {
#     aws = {
        
#     }
#   }
  
# }


# PROVIDER NAME
provider "aws" {
    region = "us-east-1"
}


# TERRAFORM FOR MULTIPLE REGIONS 

# provider "aws" {

#   alias = "region1"
#   region = "us-east-1"
# }

# provider "aws" {

#     alias = "region2"
#     region = "us-west-2"
# }

# USING MULTIPLE REGION PROVIDER FOR ONE EC2 INSTANCES

# resource "aws_instance" "example" {

#     ami         = "ami-079db87dc4c10ac91" 
#     instance_type    = "t2.micro"
#     provider = "aws.region1"
# }

# EC2 INSTANCE CREATION
#WITHOUT VARIABLES
# resource "aws_instance" "example" {

#     ami         = "ami-079db87dc4c10ac91" 
#     instance_type    = "t2.micro"
    
# }

# EC2 INSTANCE CREATION 
#WITH VARIABLES



# AWS EC2 INSTANCE WITH SECUIRTY GROUP 

# resource "aws_instance" "example" {

#     ami = var.ami_id
#     instance_type = var.instance_type
#     key_name = "aws-key-pair"
#     vpc_security_group_ids = [var.security_group_ids]
#     tags = {

#         NAME = "demo_server"
#     }
    
# }

# resource "aws_security_group_rule" "rule_edit" {
    
#     security_group_id =var.security_group_ids
#     type = "ingress"
#     from_port  = 22
#     to_port = 22
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
# }


# resource "aws_instance" "server" {

#     ami = var.ec2_info.ami_id
#     instance_type = var.ec2_info.type

#     tags = {

#         NAME = "server"

#     }

# }


# resource "aws_s3_bucket" "buckets" {

#     count = length(var.s3_list)
#     bucket = "${var.s3_list[count.index]}"

#     tags = {

#         NAME = "${var.s3_list[count.index]}"

#     }


# }



#<----------------------------------------------------------------------------------- # SECURE WEB HOSTING -------------------------------------------------------------------->


 locals {

    bucker_name = "secure-web-hosting-using-terraform"
    s3_key_name = "home.html"
    #private_key_for_ssh = ""
 }



# BUCKET CREATION
resource "aws_s3_bucket" "bucket"{

    bucket = "secure-web-hosting-using-terraform"

    tags = {

        NAME = "bucket for html file"
    }
}

# BUCKET VERSIONING ENABLE
resource "aws_s3_bucket_versioning" "versioning_example" {

  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {

    status = "Enabled"

  }
}

# BUCKET ACL ENABLE
resource "aws_s3_bucket_ownership_controls" "rules" {

    bucket = aws_s3_bucket.bucket.id

    rule {

        object_ownership = "BucketOwnerPreferred"
    }
}

# GIVEN OBJECT PUBLIC ACCESS TO EVERYONE
resource "aws_s3_bucket_public_access_block" "rule_1" {

   bucket = aws_s3_bucket.bucket.id

   block_public_acls       = false
   block_public_policy     = false
   ignore_public_acls      = false
   restrict_public_buckets = false
}


# AS GIVEN ACL ENABLED SO, NOW WE CAN CHANGE ACL TO PUBLIC READ
resource "aws_s3_bucket_acl" "acl_edit" {

    depends_on = [
        aws_s3_bucket_ownership_controls.rules,
        aws_s3_bucket_public_access_block.rule_1,
    ]

    bucket =aws_s3_bucket.bucket.id
    acl = "public-read"
}

# INSIDE BUCKET NOW WE CAN CREATE OBJECT IN IT
resource "aws_s3_bucket_object" "object_create" {

    bucket = aws_s3_bucket.bucket.id
    key = "home.html"
    source = "C:/Users/gautam.rathod/terraform/home.html"
    acl = "public-read"

}

# EC2 INSTANCE CREATION 
resource "aws_instance" "free_host_server" {

    ami = var.ec2_info.ami_id
    instance_type = var.ec2_info.type
    key_name = "aws-key-pair"
    vpc_security_group_ids = [var.security_group_ids]
    iam_instance_profile = "EC2_S3_Role"


     provisioner "remote-exec" {

        inline = [
             "sudo aws configure set aws_access_key_id AKIAYIU4ARJSP3RRSQWW",
             "sudo aws configure set aws_secret_access_key NNUjB9rI4+XvZQTJ9wxkA7S09xt8OoXU79EKfyK",
             "aws s3 ls",
             "aws s3 cp s3://secure-web-hosting-using-terraform/home.html /home/ec2-user/"
        
        ]

        connection {
            type = "ssh"
            user = "ec2-user"
            private_key = file("C:/Users/gautam.rathod/terraform/aws-key-pair.pem")
            #host = aws_instance.free_host_server.public_ip
            host = aws_instance.free_host_server.public_dns
        }
     }
    
    tags = { 

        NAME = "server1"
    }

  
}

# ADDING A PORT TO AN EC2 INSTANCE 
resource "aws_security_group_rule" "rule_edit" {
    
    security_group_id =var.security_group_ids
    type = "ingress"
    from_port  = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
}

# data "aws_s3_bucket" "data_forfile" {

#     bucket = "secure-web-hosting-using-terraform"
    
# }    


# resource "null_resource" "s3_to_ec2" {

#     provisioner "local-exec" {

#         command = "aws s3 cp s3://secure-web-hosting-using-terraform/home.html ec2-user@54.82.126.205:/"

#     }

#     depends_on = [aws_instance.server]
# }

# resource "aws_iam_role_policy" "ec2_policy" {

#     NAME ="ec2_policy"
#     assume_role_policy = <<EOF
#     {

#     }
# }



# resource "null_resource" "s3_object_to_ec2" {

#     depends_on = [aws_instance.free_host_server]

#     provisioner "remote-exec" {

#         inline = [
#              "sudo aws configure set aws_access_key_id AKIAYIU4ARJSP3RRSQWW",
#              "sudo aws configure set aws_secret_access_key NNUjB9rI4+XvZQTJ9wxkA7S09xt8OoXU79EKfyK",
#              "sudo aws s3 cp s3://${local.bucker_name}/${local.s3_key_name} /home/ec2-user"
#             #  "sudo ssh -o StrictHostKeyChecking=no -i private-key-1.ppk ec2-user@${aws_instance.free_host_server.public_ip}",
#             #  "sudo scp index.html ec2-user@${aws_instance.free_host_server.public_ip}:/home/ec2-user/"   
#         ]

#         connection {

#             type = "ssh"
#             user = "ec2-user"
#             private_key = file("C:/Users/gautam.rathod/terraform/aws-key-pair.pem")
#             host = aws_instance.free_host_server.public_ip
#             #host = "${aws_instance.free_host_server.public_ip}.compute-1.amazonaws.com"
#         }
#     }

# } 

# resource "null_resource" "s3_object_to_ec2" {
#   provisioner "local-exec" {
#     command = <<EOT
#         ./run.sh
#     EOT     
#   }

#   depends_on = [aws_instance.free_host_server]
# }






