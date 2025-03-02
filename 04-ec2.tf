resource "aws_instance" "web" {
  instance_type = "t2.micro"
  ami           = "ami-02ddb77f8f93ca4ca"

  key_name               = "newkey"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = data.aws_subnet.default.id
  root_block_device {
    encrypted = true

  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              
              # Create a simple index.html
              cat <<'EOT' > /var/www/html/index.html
              <!DOCTYPE html>
              <html lang="en">
              <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>One Page Website</title>
              <style>
                 * {
              margin: 0;
              padding: 0;
              box-sizing: border-box;
              font-family: Arial, sans-serif;
              }
              body {
              display: flex;
              justify-content: center;
              align-items: center;
              height: 100vh;
              background-color: #f4f4f4;
              }
              .container {
              text-align: center;
              background: white;
              padding: 50px;
              border-radius: 10px;
              box-shadow: 0 4px 8px rgba(0,0,0,0.1);
              }
               h1 {
              color: #333;
              }
               p {
              color: #666;
              margin-top: 10px;
              }
             </style>
             </head>
             <body>
             <div class="container">
             <h1>Welcome to My One Page Website</h1>
             <p>This is a simple one-page website using HTML and CSS.</p>
             </div>
             </body>
             </html>
             EOT

           # Set proper permissions
             chown -R apache:apache /var/www/html
             chmod -R 755 /var/www/html
             EOF

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Security group for web servers"
  vpc_id      = data.aws_vpc.default.id # Use the default VPC
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ec2_sg"
  }

}

output "public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP of the EC2 instance"
}

resource "aws_key_pair" "imported_key" {
  provider   = aws.secondary
  key_name   = "my-key-west"
  public_key = data.aws_key_pair.existing_key.public_key
}

#resource "aws_key_pair" "imported_key" {
#  key_name   = "my-key-west"
# public_key = file("~/.ssh/newkey.pub")
#}
data "aws_vpc" "default" {
  default = true
}

data "aws_key_pair" "existing_key" {
  key_name = "newkey"
}

#data "aws_subnet_ids" "default" {
# filter {
#    name   = "vpc-id"
#    values = [data.aws_vpc.default.id]
#  }
#}

data "aws_subnet" "default" {
  vpc_id = data.aws_vpc.default.id

  filter {
    name   = "availability-zone"
    values = ["us-east-1a"]  # Change this to your preferred AZ
  }
}


