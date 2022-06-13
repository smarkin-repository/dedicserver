- [x] prepare structure project
  - [x] create base files
  - [x] implement https://github.com/gruntwork-io/terragrunt-infrastructure-live-example
  - [x] rollout VPC + state bucket
  - [x] SSM rollout

- [x] write simple acception tests
  - [x] check cluster
  - [x] check simple server 
  - [x] connect to bastion and run netcat to check connection to the simple-server 

- [x] develop remain elements of infrastructure 
  - [x] start up EKS + check
  - [x] rollout dashboard https://github.com/kubernetes/dashboard

- [x] rollout simple-server
  - [x] rollout agones https://agones.dev/site/docs/getting-started/create-gameserver/
  - [x] rollout simple-game-server
  - [x] connect to bastion and run netcat to check connection to the simple-server

- [ ]  prepare simple-server for local kubernternetes
  - [x] [FAILED] rollout simple-game-server Windows + WSL2 + Minikube
! minikube with docker driver doesn't support UDP port, that's why can't to rollout agones https://github.com/kubernetes/minikube/issues/12362
=> try to find other way to do it
  - setup king + kong ingress controller - verification using CoreDNS https://docs.konghq.com/kubernetes-ingress-controller/2.1.x/guides/using-udpingress/
  - setup kong ingress controller for simple-game-server  
  - [x] rollout simple-game-server Windows + minikube
  - [x] rollout Fleet            https://agones.dev/site/docs/getting-started/create-fleet/
  - [x] rollout Fleet Autoscaler https://agones.dev/site/docs/getting-started/create-fleetautoscaler/
  - [x] [SKIP] rollout Webhook Scaler   https://agones.dev/site/docs/getting-started/create-webhook-fleetautoscaler/
  - [x] investigate how it works
  - [ ] prepare autorollout and checking simple-server as base test
  - [ ] automation delete simple-server 
 
- [ ] rollout xonotic
  - [ ] write checker for xonotic
  - [x] implement solution https://github.com/googleforgames/agones/tree/main/examples/xonotic
  - [ ] get successful check for xonotic 
  - [x] succesful connect using localhost client to xonotic server https://xonotic.org/ via kubectl proxy

- [ ] implement workflow for changing GameServer 
  - [ ] implement gitops approuch https://fluxcd.io/legacy/flux/
  - [ ] prepare workflow for changing GameServer https://agones.dev/site/docs/getting-started/edit-first-gameserver-go/
  - [ ] check flow
  - [ ] implement other gameservers for example list 

- [ ] setup public connection to GameServer
  - add ALB + AWS LoadBalancing Controller + ACM
  - rollout istio + echo server
  - provide access from global
  - succesful connect to the xonotic server

- [ ] Matchmaking
  - investigate how it works
  - implement Matchmaking https://github.com/googleforgames/open-match 

- [ ] Implemnet Observability
  - Dashboard with statistic using Prometheus, Grafana or Stackdriver  https://opencensus.io/

<b>issues</b>:
- [x] My current user or role does not have access to Kubernetes objects on this EKS cluster
  https://docs.aws.amazon.com/eks/latest/userguide/view-kubernetes-resources.html#view-kubernetes-resources-permissions
- [x] no access to AWS resources from k8s dashboard
  https://kubernetes.io/docs/reference/access-authn-authz/authentication/
  roles.rbac.authorization.k8s.io is forbidden: User "system:serviceaccount:kube-system:deployment-controller" cannot list resource "roles" in API group "rbac.authorization.k8s.io" in the namespace "default"
- [x] kubectl.exe create -f ./gameserver.yaml
Error from server (InternalError): error when creating "./gameserver.yaml": Internal error occurred: failed calling webhook "mutations.agones.dev": failed to call webhook: Post "https://agones-controller-service.agones-system.svc:443/mutate?timeout=10s": context deadline exceeded
 take a look https://github.com/googleforgames/agones/issues/1196#issuecomment-561015853 
 be sure all requests in from the list (https://agones.dev/site/docs/installation/) are complited

 solution:
  needs to add this policy to the cluster
  TCP	0 - 65535	cidr_blocks
  UDP	0 - 65535	cidr_blocks


- [x] minikube tunnel doesn't appear to support UDP LoadBalancers  
https://github.com/kubernetes/minikube/issues/12362
https://github.com/googleforgames/agones/issues/2471
In macOS and Windows, docker does not expose the docker network to the host. Because of this limitation, containers (including kind nodes) are only reachable from the host via port-forwards, however other containers/pods can reach other things running in docker including loadbalancers.

$ kubectl run udp --image=ubuntu -- bash -c "while true; do sleep 100000; done"
deployment "udp" created
$ kubectl expose deployment udp --port=12345 --protocol=UDP --type=LoadBalancer
service "udp" exposed
```
Then I got the IP from `get svc`.  I used `kubectl exec -ti` to exec into my pod and run `nc -l -p 12345 -u` in one terminal and I sent bytes to it via `netcat -u <public ip> 12345`.

solution:
  rollout minikube on windows host insted of WSL 

 - [ ] don't quete understand how to do 
 spec:
  players:
    initialCapacity: 10

 

<b>useful links</b>:
- https://github.com/MartinHeinz/game-server-operator

- https://developer.redis.com/create/kubernetes/kubernetes-operator/

- https://developer.ibm.com/articles/introduction-to-kubernetes-operators/

- https://habr.com/ru/post/469381/

- https://github.com/comerford/minikube-agones-cluster

- https://aws.amazon.com/ru/blogs/containers/how-to-route-udp-traffic-into-kubernetes/

- Quilkin is a UDP proxy, specifically designed for use with multiplayer dedicated game servers.
   https://markmandel.github.io/quilkin/main/book/introduction.html