# OAuth Development Certificates

Development certificates and keys for use with my blog's OAuth code samples.\
Wildcard certificates are used so that there is a single certificate and key to manage.\
Real private keys should of course not be checked into a public repository like this.

## Certification Creation

Certificates and keys can be recreated when required with one of these commands:

```bash
./makecerts.sh mycompany
./makecerts.sh authsamples-dev
./makecerts.sh mycluster
```

## *.mycompany.com

These are my default local computer domains for testing of early SPA and API code samples:

![mycompany certificate](./doc/mycompany.png)

## *.authsamples-dev.com

A setup where the web subdomain runs locally and API subdomains are deployed components in AWS:

![authsamples-dev certificate](./doc/authsamples-dev.png)

## *.mycluster.com

A setup where components are deployed to a local Kubernetes cluster:

![mycluster certificate](./doc/mycluster.png)

## Further Information

See the [Development SSL Setup](https://authguidance.com/2017/11/11/developer-ssl-setup/) blog post for further details on local setups.
