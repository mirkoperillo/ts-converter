#!/bin/sh

ADDON_NAME="ts-converter"
actual_dir=`pwd`

if [ ! -d "../dist" ] 
then
  mkdir ../dist
fi

if [ -e ../dist/$ADDON_NAME-unsigned.xpi ]
then
 rm ../dist/$ADDON_NAME-unsigned.xpi
fi

cd ../addon

# patch the manifest
mkdir -p ../dist/tmp
if [ $? -eq 0 ]; then
  echo "created tmp folder"
fi

cp -R * ../dist/tmp
if [ $? -eq 0 ]; then
  echo "copy src in tmp folder"
else
  echo "error copying src folder"
  exit -1
fi

sed -i 's/^}/,"applications": {\n\t"gecko": {\n\t\t"id": "ts-converter@owlcode.eu"\n\t}\n}\n}/g' ../dist/tmp/manifest.json
if [ $? -eq 0 ]; then
  echo "editing manifest.json"
else
  echo "error editing manifest"
  exit -1
fi
cd ../dist/tmp
echo "move to folder $(pwd)"
zip -rq ../$ADDON_NAME-unsigned.xpi *
cd ../..
zip -q dist/$ADDON_NAME-unsigned.xpi LICENSE README.md
if [ $? -eq 0 ]; then
  echo "creating xpi file"
else
  echo "error creating xpi file"
fi
rm -Rf dist/tmp
if [ $? -eq 0 ]; then
  echo "delete tmp folder"
else
  echo "error deleting tmp folder"
fi
cd $actual_dir
