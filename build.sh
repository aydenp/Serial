#!/bin/bash
export LC_CTYPE=C 
export LANG=C

appName=Serial

project=${appName}.xcodeproj
schemeName=${appName}


rm -rf Archives/
rm -rf deb/Applications/*
mkdir Archives

# Create archive
xcodebuild -project ${project} -scheme ${schemeName} -sdk iphoneos \
-configuration Release build CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO build \
-archivePath 'Archives/Build.xcarchive' \
archive

# Isolate application folder
mkdir Archives/Payload
cp -R Archives/Build.xcarchive/Products/Applications/${appName}.app Archives/Payload/
rm -rf Archives/Build.xcarchive

# Clean out files
cd Archives/Payload
find . -name '*.DS_Store' -type f -delete
find . -name '*embedded.mobileprovision' -type f -delete
find . -name '*_CodeSignature' -type f -delete
cd ../..

# Create IPA
cd Archives
zip -r -X Sideload.ipa Payload
cd ..

# Move application payload to deb source
mv Archives/Payload/* deb/Applications/

# Remove Swift libraries from deb source (since we have libswift for that)
rm -rf deb/Applications/*.app/Frameworks/libswift*

# Clean up .DS_Store files in deb folder
cd deb
find . -name '*.DS_Store' -type f -delete
cd ..

# Fake-sign app
ldid -S deb/Applications/*.app/${appName}
ldid -S deb/Applications/*.app/Frameworks/*.framework/*
ldid -S deb/Applications/*.app/${appName}/PlugIns/*.appex/*
ldid -S deb/Applications/*.app/${appName}/PlugIns/*.appex/Frameworks/*.framework/*

# Create deb
dpkg-deb -Zgzip -b deb
mv deb.deb Archives/Jailbreak.deb

# Clean up
rm -rf Archives/Payload
rm -rf deb/Applications/*

# Show in Finder
open Archives/

echo Done! The files are ready for distribution.
