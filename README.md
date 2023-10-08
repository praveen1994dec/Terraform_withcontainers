PREREQUISIITE -  Create a repo in aws ECR with name - > django-app 

IMPORTANT - Once the repo is create change the 600735812827.dkr.ecr.us-west-1.amazonaws.com IN COMMANDS TO THE REPO OF YOURS

1) Change the docker_image_url_django in VARIABLES.TF file with <YOUR ECR REPO URL>

2) Change the policy file paths in iam.tf and variables.tf file

3) aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin <YOUR ECR REPO URL>

4) cd app/

5) docker build -t <YOUR ECR REPO URL>/django-app:latest .

6) docker build --platform=linux/amd64 -t 240910715551.dkr.ecr.us-west-1.amazonaws.com/django-app:latest .


6)docker push 240910715551.dkr.ecr.us-west-1.amazonaws.com/django-app:latest

7) Go to terraform folder and hit this below command 

ssh-keygen -f california-region-key-pair


terraform init 


terraform plan -out terraform.out


terraform apply "terraform.out"



8) pip install boto3 click


9) export AWS_ACCESS_KEY_ID="" 


10) export AWS_SECRET_ACCESS_KEY="" 


11) export AWS_DEFAULT_REGION="us-west-1" 


12 ) cd deploy folder 

Run command in deploy folder - python3 update-ecs.py --cluster=production-cluster --service=production-service


13 ) terraform destroy

