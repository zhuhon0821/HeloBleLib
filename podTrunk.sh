#!/bin/bash --login

#Verify variable is provided

# if [ "$1" = "" ]; then
#         echo -e "Version number not provide"
#         exit 1
# fi

VERSION="1.0.3"

cd ~/ble-sdk-1/HeloBleLib/Example/HeloBleLib
sed -i "" "s/\"\([0-9]\)\.\([0-9]\)\.\([0-9]\)/\"${VERSION}/g" HeloBleLib.podspec
git add .
git commit -am "${VERSION}" 
git push
git tag ${VERSION}
git push --tags
pod lib lint --allow-warnings
pod trunk push HeloBleLib.podspec
