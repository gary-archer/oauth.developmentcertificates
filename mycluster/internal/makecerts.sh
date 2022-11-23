#!/bin/bash

####################################################################################################
# Creates an internal root CA used by certificate manager, and some particular internal certificates
####################################################################################################

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
# Create the root CA private key
#
ROOT_CERT_FILE_PREFIX='cluster.internal.ca'
ROOT_CERT_DESCRIPTION='Cluster Internal Root CA'
openssl genrsa -out $ROOT_CERT_FILE_PREFIX.key 2048
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the internal Root CA key'
  exit 1
fi

#
# Also create the public key certificate for the Root CA, with a long lifetime
#
openssl req -x509 \
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
  echo '*** Problem encountered creating the internal Root CA'
  exit 1
fi

#
# SSL certificate parameters
#
SSL_CERT_NAME="authorizationserver.internal"
SSL_CERT_PASSWORD='Password1'

#
# Create the root private key
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
# Create the SSL key
#
openssl genrsa -out $SSL_CERT_NAME.key 2048
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the SSL key'
  exit 1
fi

#
# Create the certificate signing request
#
openssl req \
    -new \
    -key $SSL_CERT_NAME.key \
    -out $SSL_CERT_NAME.csr \
    -subj "/CN=$SSL_CERT_NAME"
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the SSL certificate signing request'
  exit 1
fi

#
# Create the SSL certificate, which must have a limited lifetime
#
openssl x509 -req \
    -in $SSL_CERT_NAME.csr \
    -CA $ROOT_CERT_FILE_PREFIX.pem \
    -CAkey $ROOT_CERT_FILE_PREFIX.key \
    -CAcreateserial \
    -out $SSL_CERT_NAME.pem \
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
    -export -inkey $SSL_CERT_NAME.key \
    -in $SSL_CERT_NAME.pem \
    -name $SSL_CERT_NAME \
    -out $SSL_CERT_NAME.p12 \
    -passout pass:$SSL_CERT_PASSWORD
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the PKCS#12 file'
  exit 1
fi

#
# Delete files no longer needed
#
rm "$SSL_CERT_NAME.csr"
echo 'All certificates created successfully'
