#!/bin/bash
# This file create metadata file for package to be installed with a file name as namespace.installedPackage
#
# sh create-package-metadatafile.sh -pns '<ManagedPackageNameSpace>' -v '4.22'

PACKAGE_NAMESPACE_NAME=''
PACAKGE_VERSION_NUMBER=''

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -pns|--packagenamespace)
    PACKAGE_NAMESPACE_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -v|--version)
    PACAKGE_VERSION_NUMBER="$2"
    shift # past argument
    shift # past value
    ;;
esac
done

if [ "$PACAKGE_VERSION_NUMBER" == "" ] || [ "$PACKAGE_NAMESPACE_NAME" == "" ] 
then
    echo "===== aborting metadata file creation for package. package version number or namespace is not provided. ========"
    exit 1
fi
echo " PACAKGE_VERSION_NUMBER : $PACAKGE_VERSION_NUMBER"
mkdir -p Source/installedPackages
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
  <InstalledPackage xmlns=\"http://soap.sforce.com/2006/04/metadata\">
    <versionNumber>"$PACAKGE_VERSION_NUMBER"</versionNumber>
    <activateRSS>true</activateRSS>
 </InstalledPackage>" > Source/installedPackages/$PACKAGE_NAMESPACE_NAME.installedPackage || exit 1