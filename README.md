# OAuth Development Certificates

Development certificates and keys for use with my blog's OAuth code samples.\
Wildcard certificates are used so that there is a single certificate and key to manage.\
Real private keys should of course not be checked into a public repository like this.

## Certification Creation

Certificates for my development computer code samples are created like this:

```bash
./makecerts.sh authsamples-dev
```

Certificates for a more complex Kubernetes local development deployment are created like this:

```bash
./makecerts.sh authsamples-k8s-dev
```

## Further Information

See the [Development SSL Setup](https://apisandclients.com/posts/developer-ssl-setup) blog post for further details on local setups.
