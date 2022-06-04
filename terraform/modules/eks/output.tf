output "eks" {
    value = {
        arn = module.eks.cluster_arn,
        id = module.eks.cluster_id
    }
}

output "image" {
    value = nonsensitive(data.aws_ssm_parameter.ami.value)
}