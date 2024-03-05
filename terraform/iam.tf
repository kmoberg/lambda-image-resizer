resource "aws_iam_role" "thumbgenerator_lambda_role" {
  name = "LambdaThumbgeneratorRole"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17",
      Statement = [
        {
          Action = "sts:AssumeRole",
          Effect = "Allow",
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        }
      ]
    }
  )
}

resource "aws_iam_policy" "thumbgenerator_lambda_policy" {
  name = "LambdaThumbgeneratorPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:*"
        ],
        Effect = "Allow",
        Resource = [
          aws_s3_bucket.lambda_thumbgenerator_bucket.arn,
          "${aws_s3_bucket.lambda_thumbgenerator_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "thumbgenerator_basic_execution" {
  role       = aws_iam_role.thumbgenerator_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "thumbgenerator_lambda_policy_attachment" {
  role       = aws_iam_role.thumbgenerator_lambda_role.name
  policy_arn = aws_iam_policy.thumbgenerator_lambda_policy.arn
}