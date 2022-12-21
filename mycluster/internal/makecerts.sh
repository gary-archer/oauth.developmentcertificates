#!/bin/bash

#####################################################################################################
# Creates an internal root CA used by certificate manager, and some authorization server certificates
#####################################################################################################

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
# Require OpenSSL 3 to create P12 files, which prevents problems on Node.js 17+
# https://github.com/nodejs/node/issues/40672
#
OPENSSL_VERSION_3=$(openssl version | grep 'OpenSSL 3')
if [ "$OPENSSL_VERSION_3" == '' ]; then
  echo 'Please install openssl version 3 or higher before running this script'
fi

#
# Create the root CA
#
ROOT_CERT_FILE_PREFIX='cluster.internal.ca'
ROOT_CERT_DESCRIPTION='Cluster Internal Root CA'
openssl genrsa -out $ROOT_CERT_FILE_PREFIX.key 2048
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the internal Root CA key'
  exit 1
fi

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
# Certificate parameters
#
SSL_CERT_NAME="authorizationserver.internal.ssl"
SSL_CERT_PASSWORD='Password1'
SIGNING_CERT_NAME="authorizationserver.internal.signing"
SIGNING_CERT_PASSWORD='Password1'

#
# Create the SSL resources
#
openssl genrsa -out $SSL_CERT_NAME.key 2048
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the SSL key'
  exit 1
fi

openssl req \
    -new \
    -key $SSL_CERT_NAME.key \
    -out $SSL_CERT_NAME.csr \
    -subj "/CN=$SSL_CERT_NAME"
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the SSL certificate signing request'
  exit 1
fi

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

openssl pkcs12 \
    -export -inkey $SSL_CERT_NAME.key \
    -in $SSL_CERT_NAME.pem \
    -name $SSL_CERT_NAME \
    -out $SSL_CERT_NAME.p12 \
    -passout pass:$SSL_CERT_PASSWORD
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the SSL PKCS#12 file'
  exit 1
fi

#
# Create the token signing resources
#
openssl genrsa -out $SIGNING_CERT_NAME.key 2048
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the signing key'
  exit 1
fi

openssl req \
    -new \
    -key $SIGNING_CERT_NAME.key \
    -out $SIGNING_CERT_NAME.csr \
    -subj "/CN=$SIGNING_CERT_NAME"
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the signing CSR'
  exit 1
fi

openssl x509 -req \
    -in $SIGNING_CERT_NAME.csr \
    -CA $ROOT_CERT_FILE_PREFIX.pem \
    -CAkey $ROOT_CERT_FILE_PREFIX.key \
    -CAcreateserial \
    -out $SIGNING_CERT_NAME.pem \
    -sha256 \
    -days 365
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the SSL certificate'
  exit 1
fi

openssl pkcs12 \
    -export -inkey $SIGNING_CERT_NAME.key \
    -in $SIGNING_CERT_NAME.pem \
    -name $SIGNING_CERT_NAME \
    -out $SIGNING_CERT_NAME.p12 \
    -passout pass:$SIGNING_CERT_NAME
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the signing PKCS#12 file'
  exit 1
fi

#
# Delete files no longer needed
#
rm *.csr
echo 'All certificates created successfully'
