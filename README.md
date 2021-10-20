# DfE Incident Bot 🤖
Incident management.. all within [Slack](https://slack.com/intl/en-gb/) – `/incident`

<img src="https://user-images.githubusercontent.com/47917431/133457741-3ceb2612-0230-4ce7-bdb9-43fa37c7b9ef.gif" width="70%">


## Local Setup

1. Request an invite to the **Slack Bot Testing Grounds** workspace & a copy of the secrets for you `.env` file
2. Visit https://api.slack.com/apps and select **DfE incident bot (test)**
3. Spin up a ngrok tunnel with `ngrok http 3000` and take a copy of the forwarding URL
4. Navigate to **Interactivity & Shortcuts** and add the following URL to **Request URL**:
- https://example.ngrok.io/api/slack/action
5. Navigate to **Slash Commands** and add the following URL to the three slash commands:
- https://example.ngrok.io/api/slack/command
6. Navigate to **OAuth & Permissions** and add the following URL to **Redirect URLS**:
- https://example.ngrok.io
7. Update your `.env` file with the following URLs:
- `BASE_URL=https://example.ngrok.io`
- `ENV_URL=example.ngrok.io`
8. Launch your rails server and test the connection in Slack with `/ping`
## New App Setup
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
5. Activate **Slash Commands** adding three slash commands:
- `/ping`
- `/incident`
- `/closeincident`
and use this url as the **Request URL**: `BASE_URL/api/slack/command`
6. Grab the infomation needed for .env file from Basic Information section
7. Navigate to the **App Home** page and toggle **Always Show My Bot as Online** (according to your reference)

