---
title: Kubernetes Nginx Ingress Controller
geekdocDescription: Enable Ingress resources in your On-Premise Kubernetes Cluster
geekDocHidden: true
geekDocHiddenTocTree: false
weight: 20
---
Here you will find documentation about installing and configuring the [**Nginx Ingress Controller**](https://kubernetes.github.io/ingress-nginx/).

As described in the [**bare-metal section**](https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal), first step is to deploy the controller:
```
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/baremetal/deploy.yaml
```

Once the deployment has finished, you will see the followings resources:
```
$ kubectl -n ingress-nginx get all
NAME                                            READY   STATUS      RESTARTS   AGE
pod/ingress-nginx-admission-create-w4spq        0/1     Completed   0          5d18h
pod/ingress-nginx-admission-patch-7zw79         0/1     Completed   0          5d18h
pod/ingress-nginx-controller-5dbd9649d4-wr2bh   1/1     Running     0          5d18h

NAME                                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
service/ingress-nginx-controller             NodePort    10.233.45.254   <none>        80:32259/TCP,443:31225/TCP   5d18h
service/ingress-nginx-controller-admission   ClusterIP   10.233.12.164   <none>        443/TCP                      5d18h

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           5d18h

...
```

That means that **Nginx Controller is reachable through a NodePort service**. In order to balance the traffic between alll the nodes in the cluster, **we will use an external Nginx** as a Reverse Proxy. Using docker-compose, the needed configuration could be the following:
```
# ./docker-compose.yml
services:
  nginx-proxy:
    image: nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl
```
```
# ./nginx.conf
events {}
http {
  upstream controller {
    server node1:32259 weight=3;
    server node2:32259;
  }

  server {
    listen 80;
    listen 443 ssl;

    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    location / {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_pass http://controller;
    }
  }
}
```
Now that your DNS wildcard (e.g. `*.apps.domain.es`) points to the balancer, docker-compose can be started:
```
$ docker-compose up -d
```
