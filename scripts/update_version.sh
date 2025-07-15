#!/bin/bash
set -e

VERSION=$1

# Update pubspec.yaml
awk -v ver="$VERSION" '/^version:/ {$2=ver} {print}' pubspec.yaml > pubspec.yaml.tmp && mv pubspec.yaml.tmp pubspec.yaml

# Update build number
BUILD_NUMBER=$(grep "^version:" pubspec.yaml | cut -d'+' -f2 | tr -d '\r')
if [ -z "$BUILD_NUMBER" ]; then
  NEW_BUILD=1
else
  NEW_BUILD=$((BUILD_NUMBER + 1))
fi

awk -v build="$NEW_BUILD" '/^version:/ {$0=$0"+"build} {print}' pubspec.yaml > pubspec.yaml.tmp && mv pubspec.yaml.tmp pubspec.yaml
