# Development & Contribution Guide

## Prerequisites

This is a [meteor](https://www.meteor.com/) app, so basic knowledge of meteor is required. Meteor is a full stack JavaScript only web application platform. Dealing with technology all my life, and with meteor extensively in the past few years, I have been repetitively proven that meteor significantly cuts web app development time :-)

Since this app uses Slack, GitHub and Trello oauth authorization, you will need to:

1. Create Slack, GitHub and Trello developer applications.

2. Use some kind of http tunneling solution to be able to expose your local app to the Internet so Sign-In with GitHub will work. This guide will provide you instructions on using [ngrok](https://ngrok.com/), but there are other [solutions](http://john-sheehan.com/blog/a-survey-of-the-localhost-proxying-landscape) out there.

Also, if you're a team of developers (and as a rule of thumb in general), I recommend following [The Twelve-Factor App](http://12factor.net/) principles religiously in development environments too, so every developer has it's own completely separate environment, including separate domains, DBs, accounts, services, developer apps, etc.

## Installation & Configuration

### Clone the app's repo

```
git clone git@github.com:hubaaa/hubapp-rutalking2me.git rutalking2me
```

Or using https:

```
https://github.com/hubaaa/hubapp-rutalking2me.git
```

### Init the app's repo submodules

```
cd rutalking2me
git submodule init
git submodule update
```

### Configure ngrok

#### Install

Install the latest v2 ngrok binary from [here](https://ngrok.com/download) and add it to your path.

#### Sign-Up

Create an account at [ngrok](https://dashboard.ngrok.com/user/login).

Once created, I recommend that you get on a paid plan, so you can reserve an http tunneling subdomain under ngrok.io. If not, and if the subdomain you usually use is used by someone else, you will need to change your GitHub developer app URLs. Not a biggy and the URLs update immediately, though.

#### Create the ngrok.yml file

After you signed-in to ngrok for the first time, you will need to add your ngrok authtoken to your development environment. It's a one-time setup. Just copy the command from you dashboard [here](https://dashboard.ngrok.com/). It should be something like:

```
ngrok authtoken yourAuthToken
```

This will create a `ngrok.yml` file at `$HOME/.ngrok2` where your authtoken will be stored.

#### Reserve a sub-domain

If you already have or decided to get on a paid plan, reserve a subdomain for yourself under ngrok.io [here](https://dashboard.ngrok.com/reserved). I usually like to use my github username as this subdomain, so my local app will be accessible at:

https://rbabayoff.ngrok.io/

#### How-to run ngrok

Since meteor runs on port 3000 by default, you will need to start ngrok as follows before starting your app:

```
ngrok http -bind-tls=true -subdomain=mysubdomain 3000
```

Your locally running meteor app will now be accessible from the Internet at: https://*your-subdomain*.ngrok.io/

-bind-tls=true forces ngrok to only listen on https, not http, which is a requirement of oauth.

If you prefer to not specify tunneling related command line arguments every time you run ngrok, you can specify in ngrok's ngrok.yml configuration file a list of predefined tunnels. So, for the tunnel above, edit you your ngrok.yml file and add the following:

```yml
authtoken: your-ngrok-authtoken
# Add this:
tunnels:
  meteor: # This is a name / alias you provide for each tunnel in the file
    proto: http
    addr: 3000
    bind_tls: true
    subdomain: your-ngrok-subdomain
```

Now, to start the meteor tunnel specified in ngrok.yml, just:

```bash
ngrok start meteor
```

To start all tunnels specified in ngrok.yml:

```bash
ngrok start --all
```

### Create your meteor settings file

This app uses the [easy-service-config](https://atmospherejs.com/hubaaa/easy-service-config) meteor package to automatically load all the [loginWith](http://docs.meteor.com/#/full/meteor_loginwithexternalservice) related service configurations it finds in your meteor settings file under `serviceConfigurations` into meteor's `ServiceConfiguration.configurations` collection, so you won't have to configure your developer apps in meteor manually on first time use.

Just copy the sample settings file in this repo and fill it with the info of the developers apps you'll create below:

```bash
# From the repo root
cp samples/sample.settings.json app/settings.json
vi app/settings.json
```

Once filled, run your meteor app as follows:

```bash
cd app
meteor --settings settings.json
```

### Create the Slack developer application

Create a developer app [here](https://api.slack.com/applications).

Choose a unique App Name, for example:

myGithubUsername-rutalking2me

Description can't be empty.

For 'Link to app instructions and support' and Redirect URI(s), specify the ngrok.io public URL you'll use to expose your local app:

https://*your-ngrok-subdomain*.ngrok.io/

### Create the GitHub developer application

To create GitHub developer applications, you need to be on a paid personal or organizational github account.

Create a developer app [here](https://github.com/settings/developers).

Choose a unique application name, for example:

myGithubUsername-rutalking2me

This name will be sent to GitHub's api in the User-Agent header. Save it in the settings file too.

For **Homepage URL**, specify the ngrok.io public URL you'll use to expose your local app:

https://*your-ngrok-subdomain*.ngrok.io/

For **Authorization callback URL**, append `/_oauth/github` to the Homepage URL:

https://*your-ngrok-subdomain*.ngrok.io/_oauth/github

### Create the Trello developer application

Trello supports only one developer application per user, which is automatically created when you go here:

https://trello.com/app-key

### Create your meteor runtime environment file

meteor relies on environment variables such as ROOT_URL, MONGO_URL and EMAIL_URL for it's runtime environment. I recommend creating a file that exports those that you can "bash source" before running meteor. Here too, a sample is already provided, just copy it and modify it for your environment:

```
# From the repo root
cp samples/sample.meteor.env app/meteor.env
vi app/meteor.env
```

## Running the app

Before you run the app, you will need to export your meteor environment variables by sourcing your meteor.env file:

```bash
# From the app folder
source meteor.env
```

Then, just run meteor with your settings file:

```bash
meteor --settings settings.json
```

The app will now be accessible from the internet at:

https://your-ngrok-subdomain.ngrok.io/
