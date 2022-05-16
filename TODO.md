[+] prepare structure project
  + create base files
  + implement https://github.com/gruntwork-io/terragrunt-infrastructure-live-example
  + rollout VPC + state bucket
  + SSM rollout
[+] write simple acception tests
  + check cluster
  + check simple server 
  + connect to bastion and run netcat to check connection to the simple-server 
[+] develop remain elements of infrastructure 
  + start up EKS + check
  ? rollout dashboard https://github.com/kubernetes/dashboard
[] rollout simple-server
[] get successful check
[] write checker for xonotic
[] rollout xonotic
[] get successful check for xonotic
[] setup public connection for production server
  - add ALB + AWS LoadBalancing Controller + ACM
  - rollout istio + echo server
  - provide access from global
[] succesful connect to the xonotic server


[] issues:
- My current user or role does not have access to Kubernetes objects on this EKS cluster
  https://docs.aws.amazon.com/eks/latest/userguide/view-kubernetes-resources.html#view-kubernetes-resources-permissions
- no access to AWS resources from k8s dashboard
  https://kubernetes.io/docs/reference/access-authn-authz/authentication/
  roles.rbac.authorization.k8s.io is forbidden: User "system:serviceaccount:kube-system:deployment-controller" cannot list resource "roles" in API group "rbac.authorization.k8s.io" in the namespace "default"