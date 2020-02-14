#!/bin/sh

set -e

ENVIRONMENT=$1

case $ENVIRONMENT in
    test)
        ENVIRONMENT_ID="Test"
        ENVIRONMENT_TYPE="testing"
        ;;
    staging)
        ENVIRONMENT_ID="Staging"
        ENVIRONMENT_TYPE="staging"
        ;;
    prod)
        ENVIRONMENT_ID="Production"
        ENVIRONMENT_TYPE="production"
        ;;
esac

# Get issue keys for Jira from git log
ISSUE_KEYS=$(git log ${GITHUB_SHA}^..${GITHUB_SHA} --pretty=oneline \
| cut -d ' ' -f2 | grep '[a-zA-Z]*-[0-9]*' \
| sort -u | awk -v q="\"" '{print q $1 q}')

if [[ $(echo $ISSUE_KEYS | grep -c '[a-zA-Z]*-[0-9]*') -ne 1 ]]; then
    ISSUE_KEYS=$(echo $ISSUE_KEYS | awk '{printf t $1""$2} {t=","}')
fi

# Get Bearer token for Jira
CLIENT_ID="${JIRA_CLIENT_ID}"
CLIENT_SECRET="${SECRET}"
ACCESS_TOKEN=$(curl --request POST \
  --url 'https://api.atlassian.com/oauth/token' \
  --header 'Content-Type: application/json' \
  --data '{
            "audience": "api.atlassian.com",
            "grant_type":"client_credentials",
            "client_id": "'${CLIENT_ID}'",
            "client_secret": "'${CLIENT_SECRET}'"
        }' | jq -r .access_token)

# POST Release Tracking information to Jira
PROJECT_NAME=$(echo ${GITHUB_REPOSITORY} | cut -d '/' -f2)
ACTION_URL="https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
PIPELINE_URL="https://github.com/${GITHUB_REPOSITORY}/actions?query=workflow%3A${{ env.PROJECT }}"
TIME_STAMP=$(date +"%Y-%m-%dT%H:%M:%SZ")

curl --request POST \
  --url 'https://api.atlassian.com/jira/deployments/0.1/cloud/'${JIRA_CLOUD_ID}'/bulk' \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --data '{
  "deployments": [
    {
      "deploymentSequenceNumber": '${GITHUB_RUN_NUMBER}',
      "updateSequenceNumber": '${GITHUB_RUN_NUMBER}',
      "issueKeys": [
        '${ISSUE_KEYS}'
      ],
      "displayName": "'${GITHUB_RUN_NUMBER}'",
      "url": "'${ACTION_URL}'",
      "description": "Release done",
      "lastUpdated": "'${TIME_STAMP}'",
      "state": "successful",
      "pipeline": {
        "id": "'${PROJECT_NAME}'",
        "displayName": "'${PROJECT_NAME}'",
        "url": "'${PIPELINE_URL}'"
      },
      "environment": {
        "id": "'${ENVIRONMENT_ID}'",
        "displayName": "'${ENVIRONMENT_ID}'",
        "type": "'${ENVIRONMENT_TYPE}'
      },
      "schemaVersion": "1.0"
    }
  ]
}'