#!/bin/sh
set -eu

sed "s/GIT_COMMIT/${GIT_COMMIT}/g" ops/$ENVIRONMENT_NAME/app.json \
    | jq '{"Parameters": .Parameters, "Tags": .Tags, "StackPolicy": .StackPolicy}' \
    > app.json

# Create the build artifact.
zip -r ops.zip .

# Copy the artifacts to S3.
aws s3 cp ops.zip s3://$SOURCE_BUCKET/kedge-web-$ENVIRONMENT_NAME/
aws s3 cp ops.zip s3://$SOURCE_BUCKET/kedge-web-$ENVIRONMENT_NAME/_archive/$BITBUCKET_COMMIT/
