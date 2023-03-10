#!/bin/bash

zip lambda.zip hello.py
aws lambda update-function-code --function-name hello --zip-file fileb://lambda.zip

