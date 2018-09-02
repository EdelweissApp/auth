#!/bin/bash -e

export DOLLAR='$'
find . -type f -name '*.template' -exec sh -c 'echo "Found template: ${0%.template}"' {} ';'