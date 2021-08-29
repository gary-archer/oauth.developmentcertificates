#!/bin/bash

##################################################################################
# A script to use OpenSSL to create the root CA certificate for inside the cluster
# This is then used by the cert-manager tool to issue certificates for services
##################################################################################

#
# Fail on first error
#
set -e

#
# Point to the OpenSsl configuration file for the platform
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
esac

#
# Root certificate parameters
#
ROOT_CERT_FILE_PREFIX='svc.default.cluster.local.ca'
ROOT_CERT_DESCRIPTION='Self Signed CA for svc.default.cluster.local'

#
# Create the root certificate public + private key protected by a passphrase
#
openssl genrsa -out $ROOT_CERT_FILE_PREFIX.key 2048
echo '*** Successfully created Root CA key'

#
# Create the public key root certificate file
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
            -days 365
echo '*** Successfully created Root CA'
