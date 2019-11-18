#!/usr/bin/env bash

# Set up output directory in GCP Storage bucket
SERENITY_OUTPUT_PATH=/mnt/$SERENITY_OUTPUT_BUCKET/$JX_PROJECT_NAME/serenity
mkdir /mnt/$SERENITY_OUTPUT_BUCKET
gcsfuse $SERENITY_OUTPUT_BUCKET /mnt/$SERENITY_OUTPUT_BUCKET
if [ -d "$SERENITY_OUTPUT_PATH" ]; then rm -Rf $SERENITY_OUTPUT_PATH; fi
mkdir -p $SERENITY_OUTPUT_PATH

# Start and wait for Xvfb
Xvfb $DISPLAY -screen 0 1920x1080x24 &

MAX_ATTEMPTS=120 # About 60 seconds
COUNT=0
echo -n "Waiting for Xvfb to be ready..."
while ! xdpyinfo -display ${DISPLAY} >/dev/null 2>&1; do
  echo -n "."
  sleep 0.50s
  COUNT=$(( COUNT + 1 ))
  if [ "${COUNT}" -ge "${MAX_ATTEMPTS}" ]; then
    echo "  Gave up waiting for X server on ${DISPLAY}"
    exit 1
  fi
done
echo

# Run tests via gradlew
./gradlew --info test
cp -R ./target/site/serenity/* $SERENITY_OUTPUT_PATH