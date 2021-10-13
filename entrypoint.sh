#!/bin/bash

REPO_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"
TOKEN_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/registration-token"

echo "Getting registration token from ${TOKEN_URL}"

# get registration token for this runnner
RUNNER_TOKEN="$(curl -sS --request POST --url "${TOKEN_URL}" --header "authorization: Bearer ${GITHUB_TOKEN}"  --header 'content-type: application/json' | jq -r .token)"

# configure runner
export RUNNER_ALLOW_RUNASROOT=1
/runner/config.sh \
  --name $(hostname) \
  --unattended \
  --replace \
  --work "/tmp" \
  --url "$REPO_URL" \
  --token "$RUNNER_TOKEN" \
  --labels k8s-runner

# start runner
# https://github.com/actions/runner/issues/246#issuecomment-615293718
/runner/bin/runsvc.sh