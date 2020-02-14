# LeanIX Jira Action

This repository helps you to publish release tracking information to Jira tickets. Only Jira Cloud is supported.

## Prerequisites

The action requires that the following environment variables are present in the workflow.

- JIRA_CLIENT_ID
- JIRA_CLIENT_SECRET

Both `JIRA_CLIENT_ID` and `JIRA_CLIENT_SECRET` are the Jira OAuth credentials.

- JIRA_CLOUD_ID

The `JIRA_CLOUD_ID` can be retrieved by calling `https://<your-jira-instance>.atlassian.net/_edge/tenant_info`.

## Use Action

To publish release tracking information, just use the following action in any of your workflows:

```yaml
- uses: leanix/jira-action@master
  with:
    environment: 'prod'
```
