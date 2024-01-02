

# Define variable for ec2 instance type

# variable "instance_type" {

#     description = "EC2 instance type"
#     type = string
#     #default = "t2.micro"
#     #but we don't won't default value ,so we will use tfvars file instead 
# }


# Define variable for ec2 ami id

# variable "ami_id" {

#     description = "EC2 ami id"
#     type = string
#     default = "ami-079db87dc4c10ac91"
# }

variable "security_group_ids" {

    description = "security group id"
    type = string
    default = "sg-070779ab71828ed15"
    
}

variable "ec2_info" {

  description = "All EC2 configuration."
  type = object({
    ami_id = string
    type = string

  })

  default = {
    ami_id = "ami-079db87dc4c10ac91"
    type = "t2.micro"
  }

}


variable "s3_list" {
 
 type = list(string)
 default = ["s3-bucket-demo-terraform-1-example","s3-bucket-demo-terraform-2-example","s3-bucket-demo-terraform-3-example"]

}

# output "s3_object_uri" {
#     value = 
# }

# Define output variable for getting ip 

output "public_ip_dns" {

  value = aws_instance.free_host_server.public_dns
}

