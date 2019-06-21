#!/bin/bash

jekyll build

rm -rf /var/www/html/*
cp -ra _site/* /var/www/html
chmod -R 545 /var/www/html/*
