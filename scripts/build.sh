#!/bin/sh

ADDON_NAME="ts-converter"

if [ ! -d "../dist" ] 
then
  mkdir ../dist
fi

if [ -e ../dist/$ADDON_NAME.xpi ]
then
 rm ../dist/$ADDON_NAME.xpi
fi

cd ../addon
zip -r ../dist/$ADDON_NAME.xpi *
cd ..
zip dist/$ADDON_NAME.xpi LICENSE README.md
