# OAuth Development Certificates

Self signed certificates for use with OAuth code samples, created via `makeCerts.sh` scripts.\
In each case a root authority creates a wildcard certificate with multiple subject alternative names.

## Local PC URLs

On the local PC we use certificates with these URLs during Web and API development:

- https://api.mycompany.com
- https://web.mycompany.com
- https://login.mycompany.com

## Docker Compose URLs

In Docker Compose we use NGINX to provide these external URLs:

- https://api.mycompany.com
- https://web.mycompany.com
- https://login.mycompany.com
- https://elastic.mycompany.com
- https://kibana.mycompany.com

Theser internal URLs are used inside the cluster:

- https://api.mycompany.internal:8000
- https://web.mycompany.internal:8000
- https://webproxyapi.mycompany.internal:8000
- https://sampleapi.mycompany.internal:8000
- https://login.mycompany.internal:8443
- https://login.mycompany.internal:6749
- https://elastic.mycompany.internal:9200
- https://kibana.mycompany.internal:5601

## Trusting Certificates in Applications

The [SSL Blog Post](https://authguidance.com/2017/11/11/developer-ssl-setup/) provides further info on trusting the certificates in various tools and technologies.
