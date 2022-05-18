#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Point to the OpenSSL configuration file for the platform
#
case "$(uname -s)" in

  # Mac OS
  Darwin)
    export OPENSSL_CONF='/System/Library/OpenSSL/openssl.cnf'
 	;;

  # Windows with Git Bash
  MINGW64*)
    export OPENSSL_CONF='C:/Program Files/Git/usr/ssl/openssl.cnf';
    export MSYS_NO_PATHCONV=1;
	;;

  # Linux
  Linux*)
    export OPENSSL_CONF='/usr/lib/ssl/openssl.cnf';
	;;
esac

#
# Root certificate parameters
#
ORGANIZATION='authsamples-dev'
ROOT_CERT_FILE_PREFIX="$ORGANIZATION.ca"
ROOT_CERT_DESCRIPTION="Self Signed CA for $ORGANIZATION.com"

#
# SSL certificate parameters
#
SSL_CERT_FILE_PREFIX="$ORGANIZATION.ssl"
SSL_CERT_PASSWORD='Password1'
WILDCARD_DOMAIN_NAME="*.$ORGANIZATION.com"

#
# Create the root public + private key
#
openssl genrsa -out $ROOT_CERT_FILE_PREFIX.key 2048
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Root CA key'
  exit 1
fi

#
# Create the root certificate file, which has a long lifetime
#
openssl req \
    -x509 \
    -new \
    -nodes \
    -key $ROOT_CERT_FILE_PREFIX.key \
    -out $ROOT_CERT_FILE_PREFIX.pem \
    -subj "/CN=$ROOT_CERT_DESCRIPTION" \
    -reqexts v3_req \
    -extensions v3_ca \
    -sha256 \
    -days 3650
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Root CA'
  exit 1
fi

#
# Create the SSL keypair
#
openssl genrsa -out $SSL_CERT_FILE_PREFIX.key 2048
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the SSL key'
  exit 1
fi

#
# Create the certificate signing request for the SSL certificate
#
openssl req \
    -new \
    -key $SSL_CERT_FILE_PREFIX.key \
    -out $SSL_CERT_FILE_PREFIX.csr \
    -subj "/CN=$WILDCARD_DOMAIN_NAME"
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the SSL certificate signing request'
  exit 1
fi

#
# Create the SSL certificate, which must have a limited lifetime
#
openssl x509 -req \
    -in $SSL_CERT_FILE_PREFIX.csr \
    -CA $ROOT_CERT_FILE_PREFIX.pem \
    -CAkey $ROOT_CERT_FILE_PREFIX.key \
    -CAcreateserial \
    -out $SSL_CERT_FILE_PREFIX.pem \
    -sha256 \
    -days 365 \
    -extfile server.ext
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the SSL certificate'
  exit 1
fi

#
# Export it to a deployable PKCS#12 file that is password protected
#
openssl pkcs12 \
    -export -inkey $SSL_CERT_FILE_PREFIX.key \
    -in $SSL_CERT_FILE_PREFIX.pem \
    -name $WILDCARD_DOMAIN_NAME \
    -out $SSL_CERT_FILE_PREFIX.p12 \
    -passout pass:$SSL_CERT_PASSWORD
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the PKCS#12 file'
  exit 1
fi

#
# Delete files no longer needed
#
rm "$ORGANIZATION.ssl.csr"
rm "$ORGANIZATION.ca.srl"
echo 'All certificates created successfully'
