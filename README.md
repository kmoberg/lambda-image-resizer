# Lambda Image Resizer

## Description
This is a simple image resizer that uses AWS Lambda to resize images that are uploaded to S3. Set a bucket event to 
trigger when uploads are added to the bucket and the lambda function will resize the image and save it to a new 
directory.

## Terraform
The project is set up to use Terraform to deploy the lambda function and the S3 bucket. 
The terraform files are located in the `terraform` directory.

## Usage
### Terraform
1. Navigate to the `terraform` directory
2. Make sure your AWS credentials or profile are set up.
3. Add a `terraform.tfvars` file to the `terraform` directory. Use the `terraform.tfvars.sample` file as a template.
4. Run `terraform init`
5. Run `terraform apply`

### Lambda
It should be automatically set up to trigger when an image is uploaded to the S3 bucket.
Make sure the trigger is set up in the AWS console.