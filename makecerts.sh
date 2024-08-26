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
# Require OpenSSL 3 so that up to date syntax can be used
#
OPENSSL_VERSION_3=$(openssl version | grep 'OpenSSL 3')
if [ "$OPENSSL_VERSION_3" == '' ]; then
  echo 'Please install openssl version 3 or higher before running this script'
fi

#
# The domain is 'authsamples-dev' or 'authsamples-k8s-dev' 
#
DOMAIN="$1"
if [ "$DOMAIN" != 'authsamples-dev' -a "$DOMAIN" != 'authsamples-k8s-dev' ]; then
  echo "Supply the domain as a command line parameter: 'authsamples-dev' or 'authsamples-k8s-dev'"
  exit 1
fi
if [ ! -d "$DOMAIN" ]; then
  echo "The $DOMAIN folder does not exist"
  exit 1
fi
cd "$DOMAIN"

#
# Create the root private key
#
openssl ecparam -name prime256v1 -genkey -noout -out $DOMAIN.ca.key
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
    -key $DOMAIN.ca.key \
    -out $DOMAIN.ca.crt \
    -subj "/CN=Development CA for $DOMAIN.com" \
    -addext 'basicConstraints=critical,CA:TRUE' \
    -days 3650
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the Root CA'
  exit 1
fi

#
# Create the SSL key
#
openssl ecparam -name prime256v1 -genkey -noout -out $DOMAIN.ssl.key
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the SSL key'
  exit 1
fi

#
# Create the SSL certificate, which must have a limited lifetime
#
openssl req \
    -x509 \
    -new \
    -CA $DOMAIN.ca.crt \
    -CAkey $DOMAIN.ca.key \
    -key $DOMAIN.ssl.key \
    -out $DOMAIN.ssl.crt \
    -subj "/CN=*.$DOMAIN.com" \
    -days 365 \
    -addext 'basicConstraints=critical,CA:FALSE' \
    -addext 'extendedKeyUsage=serverAuth' \
    -addext "subjectAltName=$(cat ./subjectalternativenames.txt)"
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the SSL certificate'
  exit 1
fi

#
# Export it to a deployable PKCS#12 file that is password protected
#
openssl pkcs12 \
    -export \
    -inkey $DOMAIN.ssl.key \
    -in $DOMAIN.ssl.crt \
    -name "*.$DOMAIN.com" \
    -out $DOMAIN.ssl.p12 \
    -passout pass:Password1
if [ $? -ne 0 ]; then
  echo '*** Problem encountered creating the PKCS#12 file'
  exit 1
fi

#
# Indicate success
#
echo 'All certificates created successfully'
