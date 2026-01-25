# MLFlow on ECS Fargate


Steps to follow:

1. Initialize the Terraform workspace
```
terraform init
```

2. Plan the changes
```
terraform plan
```

3. Apply the changes
```
terraform apply
```

4. Push the mlflow image to the ECR repository

Push the mlflow image to the ECR repository

Replace <ACCOUNT_ID> with your AWS account id (or run the command as-is and it’ll work if your AWS CLI is configured; you can also aws sts get-caller-identity to see it).

AWS_REGION=us-east-1
REPO_URL=$(terraform output -raw ecr_repo_url)

aws ecr get-login-password --region $AWS_REGION \
  | docker login --username AWS --password-stdin $REPO_URL

cd mlflow-image
docker build -t mlflow-server:latest .

docker tag mlflow-server:latest $REPO_URL:latest
docker push $REPO_URL:latest
```


5. Test the mlflow server
```
"http://<mlflow_alb_dns_name>"
```
