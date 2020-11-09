#!/bin/bash -xe
hugo $@
rm -rf public/favicon/ && mv -v static/favicon public/favicon

