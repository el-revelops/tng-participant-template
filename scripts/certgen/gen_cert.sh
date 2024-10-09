#!/bin/zsh
# This script generates all certificates and keys for the SCA, TLS, and upload
# All certificates are self-signed
# The DN is taken from the configuration file passed as argument

# SCA is valid for 4 years
export OSSL_COUNTRY_NAME="US"
export OSSL_STATE_NAME="Ny"
export OSSL_LOCALITY_NAME="TEST"
export OSSL_ORGANIZATION_NAME="WHO"
export OSSL_ORGANIZATIONAL_UNIT_NAME="R&D"
DAYS_CA=1461

# TLS is valid for 1 year
DAYS_TLS=365

# Upload Cert is valid for 1 year
DAYS_UPLOAD=365

if [ $# -ne 1 ]; then
    echo "Usage: $0 DN configuration"
    exit 1
fi

source $1

# Generate a new directory for each run
subdir=${OSSL_COUNTRY_NAME}_$(date +%Y%m%d%H%M%S)
mkdir -p ${subdir}

# Generate the certificates and keys for the SCA, TLS, and upload
openssl req -x509 -new -days ${DAYS_CA} -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -extensions ext -keyout ${subdir}/SCA.key -nodes -out ${subdir}/SCA.pem -config sca.conf
openssl req -x509 -new -days ${DAYS_TLS} -newkey ec:<(openssl ecparam -name prime256v1) -extensions ext -keyout ${subdir}/TLS.key -nodes -out ${subdir}/TLS.pem -config TLSClient.conf
openssl req -x509 -new -days ${DAYS_UPLOAD} -newkey ec:<(openssl ecparam -name prime256v1) -extensions ext -keyout ${subdir}/UP.key -nodes -out ${subdir}/UP.pem -config uploadCert.conf

# Special case to only place CA.pem file for self-signed TLS cert as a copy
cat ${subdir}/TLS.pem > ${subdir}/CA.pem

