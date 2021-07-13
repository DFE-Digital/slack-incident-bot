# DFE incident bot
Incident management within Slack.

<img src="https://user-images.githubusercontent.com/47917431/125347757-38394480-e353-11eb-92de-879f0d23632a.png" width="500" />

## Setup
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
4. Add the `BASE_URL` to **Redirect URLs** under **Interactivity & Shortcuts**
3. Activate **Interactivity & Shortcuts** and add this url: `BASE_URL/api/slack/action` 
4. Activate **Slash Commands** adding three slash commands:
- `/ping`
- `/incident`
- `/closeincident`  
and use this url as the **Request URL**: `BASE_URL/api/slack/command`
6. Grab the infomation needed for .env file from Basic Information section
7. Navigate to the **App Home** page and toggle **Always Show My Bot as Online** (according to your reference)
## TODO

- [ ] Finish specs
- [ ] Linting
- [ ] Add incident close functionality
- [ ] Add incident update functionality
- [ ] Handle different incident levels
- [ ] Setup database to log incidents
