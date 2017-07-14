#!/bin/sh

echo y | fly -t home set-pipeline -p concourse-bbr-boshrelease -c pipeline.yml -l credentials.yml