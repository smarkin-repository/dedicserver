output "security_group_id" {
  value       = aws_security_group.this.id
  description = "The ID of the SSM Agent Security Group."
}

output "launch_template_id" {
  value       = aws_launch_template.this.id
  description = "The ID of the SSM Agent Launch Template."
}

output "autoscaling_group_id" {
  value       = aws_autoscaling_group.this.id
  description = "The ID of the SSM Agent Autoscaling Group."
}

output "role_id" {
  value       = aws_iam_role.this.id
  description = "The ID of the SSM Agent Role."
}
