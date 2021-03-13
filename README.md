# OAuth Development Certificates

Self signed certificates for use with OAuth code samples

## Local PC URLs

On the local PC we use certificates with these URLs:

- https://api.mycompany.com
- https://web.mycompany.com
- https://login.mycompany.com

The following wildcard certificate is used:

![Local Cert](images/localcert.png)

The makeCerts.sh script was used to invoke openssl to create the certificates:

![Script](images/script.png)

## Kubernetes Ingress URLs

In Kubernetes Minikube we expose these ingress URLs:

- https://api.mycluster.com
- https://web.mycluster.com
- https://login.mycluster.com

The following wildcard certificate is used:

![Cluster Cert](images/clustercert.png)

## Kubernetes Base Setup

The script at ./kubernetes/deploy-base.sh is used to deploy the Kubernetes SSL base setup.\
This includes use of SSL certificates both inside and outside the cluster.

## Trusting Certificates in Applications

The [SSL Blog Post](https://authguidance.com/2017/11/11/developer-ssl-setup/) provides further info on trusting the certificates in various tools and technologies