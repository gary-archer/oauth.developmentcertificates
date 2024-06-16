# OAuth Development Certificates

Development certificates and keys for use with my blog's OAuth code samples.\
Wildcard certificates are used so that there is a single certificate and key to manage.\
Real private keys should of course not be checked into a public repository like this.

## Certification Creation

Certificates and keys can be recreated when required by specifying the base domain:

```bash
./makecerts.sh authsamples-dev
./makecerts.sh authsamples-k8s-dev
```

## *.authsamples-dev.com

Domains and subdomains that run on the local computer during development:

![authsamples-dev certificate](./doc/authsamples-dev.png)

## *.authsamples-k8s-dev.com

Domains and subdomains in a KIND cluster on a local computer when testing deployments:

![authsamples-k8s-dev certificate](./doc/authsamples-k8s-dev.png)

## Further Information

See the [Development SSL Setup](https://apisandclients.com/posts/developer-ssl-setup) blog post for further details on local setups.
