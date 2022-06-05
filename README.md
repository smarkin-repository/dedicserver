# Task

Research https://agones.dev/site/. Deploy agones locally (minikube or docker desktop kubernetes) or in any cloud. AWS is a big plus. Use https://github.com/googleforgames/agones/tree/release-1.18.0/examples/xonotic as dedicated server. Xonotic client should be able to join a dedicated server. Matchmaker or any other automatic fleet management is not required. Fleet could be managed manually with agones rest api. Provide documentation with steps how to reproduce the environment and test the game


# Rollouting
```
 cd ./aws/eu-north-1/dev/infra
 terragrunt apply
```
```
cd ./aws/eu-north-1/dev/ssm
terragrunt apply
```
```
cd ./aws/eu-north-1/dev/eks-cluster
terragrunt apply
```




Once ready you can create your first GameServer using our examples https://agones.dev/site/docs/getting-started/create-gameserver/ .

Finally don't forget to explore our documentation and usage guides on how to develop and host dedicated game servers on top of Agones:

 - Create a Game Server (https://agones.dev/site/docs/getting-started/create-gameserver/)
 - Integrating the Game Server SDK (https://agones.dev/site/docs/guides/client-sdks/)
 - GameServer Health Checking (https://agones.dev/site/docs/guides/health-checking/)
 - Accessing Agones via the Kubernetes API (https://agones.dev/site/docs/guides/access-api/)