#!/bin/bash

: "${REPO_OWNER:?REPO_OWNER is required}"
: "${REPO_NAME:?REPO_NAME is required}"
: "${GH_TOKEN:?GH_TOKEN is required}"

cleanup() {
  echo "Removing runner..."
  local REMOVE_TOKEN
  REMOVE_TOKEN=$(curl -s -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GH_TOKEN}" \
    "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/remove-token" \
    | jq -r '.token')
  ./config.sh remove --token "${REMOVE_TOKEN}"
}

trap cleanup SIGTERM SIGINT

# Auto-generate a fresh registration token using the GitHub PAT
RUNNER_TOKEN=$(curl -s -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GH_TOKEN}" \
  "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/actions/runners/registration-token" \
  | jq -r '.token')

if [ -z "$RUNNER_TOKEN" ] || [ "$RUNNER_TOKEN" = "null" ]; then
  echo "ERROR: Failed to generate registration token"
  exit 1
fi

EXTRA_ARGS=()
if [ "${RUNNER_EPHEMERAL:-false}" = "true" ]; then
  EXTRA_ARGS+=(--ephemeral)
fi

./config.sh --unattended \
  --url "https://github.com/${REPO_OWNER}/${REPO_NAME}" \
  --token "${RUNNER_TOKEN}" \
  --name "${RUNNER_NAME_PREFIX:-gh-runner}-${HOSTNAME}" \
  --labels "${RUNNER_LABELS:-self-hosted,linux}" \
  --replace \
  "${EXTRA_ARGS[@]}"

./run.sh &
wait $!
