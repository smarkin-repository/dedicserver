output "aws_availability_zones" {
    value = data.aws_availability_zones.available
}

output "caller" {
  value =  {
      id = data.aws_caller_identity.current.account_id,
      arn = data.aws_caller_identity.current.arn
      user_id =  data.aws_caller_identity.current.user_id
    }
}
