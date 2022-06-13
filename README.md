# Task

Research https://agones.dev/site/. Deploy agones locally (minikube or docker desktop kubernetes) or in any cloud. AWS is a big plus. Use https://github.com/googleforgames/agones/tree/release-1.18.0/examples/xonotic as dedicated server. Xonotic client should be able to join a dedicated server. Matchmaker or any other automatic fleet management is not required. Fleet could be managed manually with agones rest api. Provide documentation with steps how to reproduce the environment and test the game


# Rollouting to AWS Cloud
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

# start local cluster with minikube
```
> minikube start --nodes=1 --memory=8000m --disk-size=10000m -p gameserver

> helm install demo-1.0.0 --namespace agones-system --create-namespace agones/agones
> kubectl apply -f apps/xonotic/fleet.yaml
> kubectl apply -f apps/xonotic/fleetautoscaler.yaml
> kubectl create -f apps/xonotic/gameserverallocation.yaml
> kubectl get gs 
```

Get the listed GameServers from the previous step, and connect to the IP and port of the Xonotic server via the "Multiplayer > Address" field in the Xonotic client in the format of {IP}:{PORT}.

You should now be playing a game of Xonotic against 4 bots!

# Additional information
Once ready you can create your first GameServer using our examples https://agones.dev/site/docs/getting-started/create-gameserver/ .

Finally don't forget to explore our documentation and usage guides on how to develop and host dedicated game servers on top of Agones:

 - Create a Game Server (https://agones.dev/site/docs/getting-started/create-gameserver/)
 - Integrating the Game Server SDK (https://agones.dev/site/docs/guides/client-sdks/)
 - GameServer Health Checking (https://agones.dev/site/docs/guides/health-checking/)
 - Accessing Agones via the Kubernetes API (https://agones.dev/site/docs/guides/access-api/)

