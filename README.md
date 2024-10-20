# OAuth Development Certificates

Development certificates and keys for use with my blog's OAuth code samples.\
I use wildcard certificates, so that there is a single certificate and key to manage.\
You should of course not check real private keys into a public repository like this.

## Certification Creation

I create certificates for my development computer like this:

```bash
./makecerts.sh authsamples-dev
```

I create certificates for a local Kubernetes deployment like this:

```bash
./makecerts.sh authsamples-k8s-dev
```

## Further Information

See the [Development SSL Setup](https://github.com/gary-archer/oauth.blog/tree/master/public/posts/developer-ssl-setup.mdx) blog post for further details on local certificate setups.
