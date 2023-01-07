aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 600735812827.dkr.ecr.us-west-1.amazonaws.com


cd app/


Create a repo in aws ECR name - > django-app


docker build -t 600735812827.dkr.ecr.us-west-1.amazonaws.com/django-app:latest . 


docker push 600735812827.dkr.ecr.us-west-1.amazonaws.com/django-app:latest


Change the file paths in iam.tf and variables.tf file

ssh-keygen -f california-region-key-pair


terraform init 


terraform plan -out terraform.out


terraform apply "terraform.out"



pip install boto3 click


export AWS_ACCESS_KEY_ID="" 


export AWS_SECRET_ACCESS_KEY="" 


export AWS_DEFAULT_REGION="us-west-1" 


python update-ecs.py --cluster=production-cluster --service=production-service

