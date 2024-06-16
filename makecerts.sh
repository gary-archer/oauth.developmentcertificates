#!/bin/bash

##################################################################################################
# Creates a development root CA, then issues wildcard certificates for a domain and its subdomains
##################################################################################################

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
# Require OpenSSL 3 to create P12 files
#
OPENSSL_VERSION_3=$(openssl version | grep 'OpenSSL 3')
if [ "$OPENSSL_VERSION_3" == '' ]; then
  echo 'Please install openssl version 3 or higher before running this script'
fi

#
# The base domain is 'authsamples-dev' or 'authsamples-k8s-dev' 
#
BASEDOMAIN="$1"
if [ "$BASEDOMAIN" != 'authsamples-dev' -a "$BASEDOMAIN" != 'authsamples-k8s-dev' ]; then
  echo "Supply the base domain as a command line parameter: 'authsamples-dev' or 'authsamples-k8s-dev'"
  exit 1
fi
if [ ! -d "$BASEDOMAIN" ]; then
  echo "The $BASEDOMAIN folder does not exist"
  exit 1
fi
cd "$BASEDOMAIN"

#
# Root certificate parameters
#
ROOT_CERT_FILE_PREFIX="$BASEDOMAIN.ca"
ROOT_CERT_DESCRIPTION="Development CA for $BASEDOMAIN.com"

#
# SSL certificate parameters
#
SSL_CERT_FILE_PREFIX="$BASEDOMAIN.ssl"
SSL_CERT_PASSWORD='Password1'
WILDCARD_DOMAIN_NAME="*.$BASEDOMAIN.com"

#
# Create the root private key
#
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 -out $ROOT_CERT_FILE_PREFIX.key
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
    -key $ROOT_CERT_FILE_PREFIX.key \
    -out $ROOT_CERT_FILE_PREFIX.pem \
    -subj "/CN=$ROOT_CERT_DESCRIPTION" \
    -addext 'basicConstraints=critical,CA:TRUE' \
    -days 3650
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Root CA'
  exit 1
fi

#
# Create the SSL key
#
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 -out $SSL_CERT_FILE_PREFIX.key
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the SSL key'
  exit 1
fi

#
# Create the certificate signing request for a wildcard certificate
#
openssl req \
    -new \
    -key $SSL_CERT_FILE_PREFIX.key \
    -out $SSL_CERT_FILE_PREFIX.csr \
    -subj "/CN=$WILDCARD_DOMAIN_NAME" \
    -addext 'basicConstraints=critical,CA:FALSE'
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
    -out $SSL_CERT_FILE_PREFIX.pem \
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
    -export \
    -inkey $SSL_CERT_FILE_PREFIX.key \
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
rm "$BASEDOMAIN.ca.srl"
rm "$BASEDOMAIN.ssl.csr"
echo 'All certificates created successfully'
