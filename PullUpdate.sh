#!/bin/bash


repo="https://github.com/cryingcavecat/upload-blank-nfc"
repo_name="upload-blank-nfc/"

echo "/////////////////////////////////////////////////"
echo "INSTALLING ESPTOOL"
echo "/////////////////////////////////////////////////"
pip3 install esptool

cd /home/eden/

echo "/////////////////////////////////////////////////"
echo "CLONING REPO"
echo "/////////////////////////////////////////////////"
git clone $repo

cd $repo_name


echo "/////////////////////////////////////////////////"
echo "RUNNING UPLOAD BLANK SCRIPT ..."
echo "/////////////////////////////////////////////////"
chmod +x UploadBlankNFC.sh

echo "/////////////////////////////////////////////////"
echo "PLEASE PRESS THE ARD_RST BUTTON NOW FOR 2 SECONDS AND RELEASE ..."
echo "/////////////////////////////////////////////////"
sleep 2


bash UploadBlankNFC.sh
