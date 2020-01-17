#!/bin/bash

MAJOR=$(cut -d. -f1 version.txt)
MINOR=$(cut -d. -f2 version.txt)
BUILD=$(cut -d. -f3 version.txt)
NEVERSION=$(($BUILD+1))

echo "$MAJOR.$MINOR.$NEVERSION" > version.txt
#echo "$MAJOR.$MINOR.$NEVERSION"
