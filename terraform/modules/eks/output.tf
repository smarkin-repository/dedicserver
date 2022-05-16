output "eks" {
    value = {
        arn = module.eks.cluster_arn,
        id = module.eks.cluster_id
    }
}