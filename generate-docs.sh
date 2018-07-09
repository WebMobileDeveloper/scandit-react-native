#!/bin/bash

#doxygen docs/doxygen.conf
#cp -r docs/images public-docs/html/img

doxygen docs/doxygen.conf
rm -rf public-docs/html/img
mkdir public-docs/html/img
cp -r docs/images/* public-docs/html/img
