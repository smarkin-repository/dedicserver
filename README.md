# Task

Research https://agones.dev/site/. Deploy agones locally (minikube or docker desktop kubernetes) or in any cloud. AWS is a big plus. Use https://github.com/googleforgames/agones/tree/release-1.18.0/examples/xonotic as dedicated server. Xonotic client should be able to join a dedicated server. Matchmaker or any other automatic fleet management is not required. Fleet could be managed manually with agones rest api. Provide documentation with steps how to reproduce the environment and test the game


# Rollouting

> cd ./aws/eu-north-1/dev/infra
> terragrunt apply

> cd ./aws/eu-north-1/dev/ssm
> terragrunt apply

> cd ./aws/eu-north-1/dev/eks-cluster
> terragrunt apply


