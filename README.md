# DfE Incident Bot 🤖
Incident management.. all within [Slack](https://slack.com/intl/en-gb/) – `/incident`

<img src="https://user-images.githubusercontent.com/47917431/133457741-3ceb2612-0230-4ce7-bdb9-43fa37c7b9ef.gif" width="70%">


## Local Setup

1. Request an invite to the **Slack Bot Testing Grounds** workspace & a copy of the secrets for your `.env` file
2. Visit https://api.slack.com/apps and select **DfE incident bot (test)**
3. Spin up a ngrok tunnel with `ngrok http 3000` and take a copy of the forwarding URL
4. Navigate to **Interactivity & Shortcuts** and add the following URL to **Request URL**:
- https://example.ngrok.io/api/slack/action
5. Navigate to **Slash Commands** and add the following URL to the four slash commands:
- https://example.ngrok.io/api/slack/command
6. Navigate to **OAuth & Permissions** and add the following URL to **Redirect URLS**:
- https://example.ngrok.io
7. Update your `.env` file with the following URLs:
- `BASE_URL=https://example.ngrok.io`
- `ENV_URL=example.ngrok.io`
8. Launch your rails server and test the connection in Slack with `/ping`

## New App Setup

### Option 1: Create an app using a manifest

1. Go to the [Slack apps page](https://api.slack.com/apps) and select **Create New App**.
2. Choose **From a manifest**.
3. Copy the following manifest into the text area, replacing `{{ngrok-handle}}` with your ngrok handle (the subdomain part of your ngrok URL):

```yaml
display_information:
  name: DfE incident bot (test)
features:
  bot_user:
    display_name: DfE incident bot (test)
    always_online: true
  slash_commands:
    - command: /ping
      url: https://{{ngrok-handle}}.ngrok-free.app/api/slack/command
      description: Simple check to verify bot responsiveness
      should_escape: false
    - command: /incident
      url: https://{{ngrok-handle}}.ngrok-free.app/api/slack/command
      description: Raise a new incident
      usage_hint: "[ open | update | close | help ]"
      should_escape: false
oauth_config:
  redirect_urls:
    - https://{{ngrok-handle}}.ngrok-free.app
  scopes:
    bot:
      - channels:manage
      - channels:read
      - chat:write
      - groups:read
      - incoming-webhook
      - pins:write
      - team:read
      - users:read
      - commands
settings:
  interactivity:
    is_enabled: true
    request_url: https://{{ngrok-handle}}.ngrok-free.app/api/slack/action
  org_deploy_enabled: false
  socket_mode_enabled: false
  token_rotation_enabled: false
```

### Option 2: Create an app manually

**BASE_URL** stands for https://your-slackbot-hosted-domain.com hereafter
1. Create a new app [here](https://api.slack.com/apps?new_app=1)
2. Navigate to the **OAuth & Permissions** page and add the following **Bot Token Scopes**:
- `channels:manage`
- `channels:read`
- `chat:write`
- `commands`
- `group:read`
- `incoming-webhook`
- `pins:write`
- `team:read`
- `users:read`
3. Activate **Interactivity & Shortcuts** and add this url: `BASE_URL/api/slack/action`
4. Activate **OAuth & Permissions** and add `BASE_URL` to the **Redirect URLs**
5. Activate **Slash Commands** add two slash commands, using `BASE_URL/api/slack/command` as the **Request URL**:
- `/ping`
- `/incident` -  add: `[ open | update | close | help ]` to the usage hint field
6. Grab the information needed for .env file from Basic Information section
7. Navigate to the **App Home** page and toggle **Always Show My Bot as Online** (according to your reference)

