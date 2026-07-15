output "bucket_arn" {
  description = "El ARN (Amazon Resource Name) del bucket creado"
  value       = aws_s3_bucket.mi_bucket_local.arn
}

output "bucket_domain_name" {
  description = "El nombre de dominio del bucket de S3"
  value       = aws_s3_bucket.mi_bucket_local.bucket_domain_name
}