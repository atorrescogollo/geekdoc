---
title: Kubernetes RBAC
geekdocDescription: Regulating access to computer or network resources based on the roles of individual users within your organization
geekDocHidden: true
geekDocHiddenTocTree: false
weight: 10
---
Here you will find some recipies for [**configuring RBAC (Role Based Access Control)**](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) in your Kubernetes clusters.

## Requisites
You should have administrative access to your cluster.

## General concepts
* **Namespaces**: Virtual clusters backed by the same physical cluster. They work as resource pools.
* Accounts: Every request needs authentication or it is considered as the anonymous user. There are two types of users:
    * **User Accounts**: Combinations of IDs and **certificates** signed by the cluster CA. Click [here](https://kubernetes.io/docs/reference/access-authn-authz/authentication/) for more info.
    * **Service Accounts**: **Token** authentication. Click [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/) for more info.
* Policies: It defines permissions for the RBAC engine. There are two types of policies:
    * **Roles**: Permissions within a particular **namespace**. Click [here](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole) for more info.
    * **ClusterRoles**: Permissions within the cluster (**non-namespaced**). Click [here](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole) for more info.
* Bindings: links Users with Policies. There are two types of bindings:
    * **RoleBindings**: It binds any Role or ClusterRole to the same **namespace**. Click [here](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding) for more info.
    * **ClusterRoleBindings**: It binds any ClusterRole to **all the namespaces** in the cluster. Click [here](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding) for more info.
* **Contexts**: Cluster-namespace-user relationship. It only makes sense on the client's side.

## Creating User Accounts and Roles
1. Create **CSR (Certificate Signing Request)**:
```bash
$ openssl genrsa -out my-user.key 4096
$ openssl req -new -key my-user.key -out my-user.csr -subj "/CN=my-user/O=my-organisation/DC=domain/DC=es"
```
> Note that *my-user* is the CN (Common Name) of the signed certificate. The other fields are not necessary but convenient.

2. **Sign the CSR** with the cluster CA (Certification Authority):
```bash
$ openssl x509 -req -in my-user.csr -CA /etc/kubernetes/ssl/ca.crt -CAkey /etc/kubernetes/ssl/ca.key -CAcreateserial -out my-user.crt -days 356
```
3. **Create a Role** for the User Account:
```bash
# Suggestion: Deployer
$ kubectl -n my-namespace create role deployer --verb=create,get,delete,list,update,watch,patch --resource=deployments,replicasets,statefulsets,configmaps,pods,secrets,ingresses
# Suggestion: Developer
$ kubectl -n my-namespace create role developer --verb=get,list,watch --resource=*
```
4. Create the **RoleBindings**:
```bash
# For User Accounts
$ kubectl -n my-namespace create rolebinding deployer --user=my-user --role=deployer
$ kubectl -n my-namespace create rolebinding developer --user=my-user --role=developer
```

5. Configure a **Context** for kubectl:
* Retrieve cluster CA certificate:
```bash
# From cluster admin
$ kubectl -n kube-system get configmaps extension-apiserver-authentication -o jsonpath='{.data.client-ca-file}' > ca.crt

# Test from client
$ curl --cacert ca.crt https://<CLUSTER_IP>:6443/
{
  "kind": "Status",
...
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
...
}
```

* Create the Context in your kubeconfig:
```bash
# Create the Cluster
$ kubectl config --kubeconfig=$HOME/.kube/my-cluster.config set-cluster my-cluster --server=https://<CLUSTER_IP>:6443 --certificate-authority=/path/to/my-cluster.ca.crt
# Create the Credencials
$ kubectl config --kubeconfig=$HOME/.kube/my-cluster.config set-credentials my-user --client-certificate=/path/to/my-user.crt --client-key=/path/to/my-user.key
# Create the Context & Switch to the context
$ kubectl config --kubeconfig=$HOME/.kube/my-cluster.config set-context my-cluster-my-user --cluster=my-cluster --user=my-user --namespace=my-ns
$ kubectl config --kubeconfig=$HOME/.kube/my-cluster.config use-context my-cluster-my-user
```
> In order to make use of this configuration files, it might be useful to add these lines to `.bashrc`:
> ```bash
> echo 'export KUBECONFIG="$HOME/.kube/config:"$(find "$HOME/.kube" -name "*.config" | paste -s -d ":")' >> ~/.bashrc
> ```

## Creating Service Accounts and ClusterRoles
1. Create the **Service Account** and save the **generated token**.
```bash
$ kubectl -n my-ns create serviceaccount admin
$ kubectl -n my-ns describe serviceaccounts admin
...
Tokens:              admin-token-7vpn5
...
$ kubectl -n some-ns get secret admin-token-7vpn5 -o jsonpath='{.data.token}' | base64 -d > admin-token.txt
```
2. Create the **ClusterRoleBinding**.
```bash
$ kubectl create clusterrolebinding admin --clusterrole=cluster-admin --serviceaccount=my-ns:admin
```
3. Configure the **Context**.
```bash
# Create the Cluster
$ kubectl config --kubeconfig=$HOME/.kube/my-cluster.config set-cluster my-cluster --server=https://<CLUSTER_IP>:6443 --certificate-authority=/path/to/my-cluster.ca.crt
# Create the Credential
$ kubectl config --kubeconfig=$HOME/.kube/my-cluster.config set-credentials admin --token="$(cat admin-token.txt)"
# Create the Context & Switch to the context
$ kubectl config --kubeconfig=$HOME/.kube/my-cluster.config set-context my-cluster-admin --cluster=my-cluster --user=admin --namespace=my-ns
$ kubectl config --kubeconfig=$HOME/.kube/my-cluster.config use-context my-cluster-admin
```
