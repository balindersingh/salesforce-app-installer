#!/bin/bash
# This deploy file uses the ANT to deploy given version of a Salesforce's appexchange installable package to an SF org
#
# sh deploy.sh -u 'scratch-8s6lsler@example.com' -p 'mypass' -st 'mysecuritytoken' -url 'https://business-connect-6940.cs68.my.salesforce.com' -pns 'MyNamespace' -v '1.2'

PACKAGE_NAMESPACE_NAME=''
PACAKGE_VERSION_NUMBER=''
SF_USERNAME=''
SF_PASSWORD=''
SF_SECURITYTOKEN=''
SF_INSTANCE_URL='https://login.salesforce.com'
IS_DEBUG_ON='true'

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -v|--version)
    PACAKGE_VERSION_NUMBER="$2"
    shift # past argument
    shift # past value
    ;;
    -pns|--packagenamespace)
    PACKAGE_NAMESPACE_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--username)
    SF_USERNAME="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--password)
    SF_PASSWORD="$2"
    shift # past argument
    shift # past value
    ;;
    -st|--securitytoken)
    SF_SECURITYTOKEN="$2"
    shift # past argument
    shift # past value
    ;;
    -url|--url)
    SF_INSTANCE_URL="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--debug)
    IS_DEBUG_ON="$2"
    shift # past argument
    shift # past value
    ;;
esac
done

if [ "$SF_USERNAME" == "" ] || [ "$SF_PASSWORD" == "" ] || [ "$SF_INSTANCE_URL" == "" ]
then
    echo "===== aborting package installation. username/password is not provided.========"
    exit 1
fi
echo "Create package metadata file"
bash create-package-metadatafile.sh -pns $PACKAGE_NAMESPACE_NAME -v $PACAKGE_VERSION_NUMBER || exit 1
echo "Username:$SF_USERNAME"
if [ "$IS_DEBUG_ON" == "true" ] 
then
    echo "Password:$SF_PASSWORD"
    echo "Concatinate password + security token"
    
    echo "List of files"
    ls
fi

SF_PASSWORD="$SF_PASSWORD$SF_SECURITYTOKEN"

if [ "$IS_DEBUG_ON" == "true" ] 
then
    echo "Password with security token:$SF_PASSWORD"
fi
echo "Url:$SF_INSTANCE_URL"
echo "Is debugging enabled : $IS_DEBUG_ON"
ant -buildfile build.xml deploy -Dsf.sourcefolder=Source -Dsf.checkOnly=false -Dsf.deployFile=package.xml -Dsf.testLevel=NoTestRun -Dsf.username=$SF_USERNAME -Dsf.password="$SF_PASSWORD" -Dsf.serverurl=$SF_INSTANCE_URL                 