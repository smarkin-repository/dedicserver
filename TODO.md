[x] prepare structure project
  - [+] create base files
  - [+] implement https://github.com/gruntwork-io/terragrunt-infrastructure-live-example
  - [+] rollout VPC + state bucket
  - [+] SSM rollout

[x] write simple acception tests
  - [+] check cluster
  - [+] check simple server 
  - [+] connect to bastion and run netcat to check connection to the simple-server 

[x] develop remain elements of infrastructure 
  - [+] start up EKS + check
  - [+] rollout dashboard https://github.com/kubernetes/dashboard

[~] rollout simple-server
  - [+] rollout agones https://agones.dev/site/docs/getting-started/create-gameserver/
  - [!] rollout simple-game-server
$ kubectl.exe create -f ./gameserver.yaml
Error from server (InternalError): error when creating "./gameserver.yaml": Internal error occurred: failed calling webhook "mutations.agones.dev": failed to call webhook: Post "https://agones-controller-service.agones-system.svc:443/mutate?timeout=10s": context deadline exceeded
 take a look https://github.com/googleforgames/agones/issues/1196#issuecomment-561015853 
 be sure all requests in from the list (https://agones.dev/site/docs/installation/) are complited

#create-eks-cluster


  - chech simple-game-server
```
nc -u {IP} {PORT}
Hello World !
ACK: Hello World !
EXIT
```

[ ] get successful check

[ ] write checker for xonotic

[ ] rollout xonotic

[ ] get successful check for 
xonotic

[ ] setup public connection for production server
  - add ALB + AWS LoadBalancing Controller + ACM
  - rollout istio + echo server
  - provide access from global

[ ] succesful connect to the xonotic server


[ ] <b>issues</b>:
- My current user or role does not have access to Kubernetes objects on this EKS cluster
  https://docs.aws.amazon.com/eks/latest/userguide/view-kubernetes-resources.html#view-kubernetes-resources-permissions
- no access to AWS resources from k8s dashboard
  https://kubernetes.io/docs/reference/access-authn-authz/authentication/
  roles.rbac.authorization.k8s.io is forbidden: User "system:serviceaccount:kube-system:deployment-controller" cannot list resource "roles" in API group "rbac.authorization.k8s.io" in the namespace "default"