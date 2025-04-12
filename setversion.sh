#!/bin/bash
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <version>"
  exit 1
fi

version="$1"

sed -i '' "s/\"version\": \".*\",/\"version\": \"$version\",/" package.json
npm install