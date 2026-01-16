resource "aws_instance" "email" {
  ami           = "ami-0220d79f3f480ecf5"
  instance_type = "t3.micro"
  #vpc_security_group_ids = [ aws_security_group.allow_all.id ]
  vpc_security_group_ids = local.sg_id
  user_data = file("data.sh")
  tags = {
    Name = "Email_Template"
  }
}

resource "terraform_data" "email" {
  triggers_replace = [
    aws_instance.email.id
  ]

# -----------------------------
# Connection block (SSH)
# -----------------------------
connection {
  type        = "ssh"
  user        = "ec2-user"
  password = "DevOps321"
  host        = aws_instance.email.public_ip
}

# --------------------------------
# Create directory with permission
# --------------------------------
provisioner "remote-exec" {
  inline = [
    "sudo mkdir -p /opt/email_automation",
    "sudo chown -R ec2-user:ec2-user /opt/email_automation"
  ]
}

# -----------------------------
# Copy Python Script
# -----------------------------
provisioner "file" {
  source      = "send_resume.py"
  destination = "/opt/email_automation/send_resume.py"
}

# -----------------------------
# Copy CSV file
# -----------------------------
provisioner "file" {
  source      = "hr_emails.csv"
  destination = "/opt/email_automation/hr_emails.csv"
}

# -----------------------------
# Copy Email Template
# -----------------------------
provisioner "file" {
  source      = "email_template.html"
  destination = "/opt/email_automation/email_template.html"
}

# -----------------------------
# Copy Resume PDF
# -----------------------------
provisioner "file" {
  source      = "Divya_DevOps_Resume.pdf"
  destination = "/opt/email_automation/Divya_DevOps_Resume.pdf"
}

# -----------------------------
# Run Python Script
# -----------------------------
provisioner "remote-exec" {
  inline = [
    "sudo yum install -y python3-pip",
    "pip3 install pandas",
    "sudo chown -R ec2-user:ec2-user /opt/email_automation",
    "cd /opt/email_automation",
    "python3 send_resume.py"
  ]
}
}


resource "aws_security_group" "allow_all" {
    name        = "allow_all"
    description = "allow all traffic"
  
    ingress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
      Name = "allow_all"

    }
}
 