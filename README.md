# Awesome Code

[ ![Codeship Status for
xinminlabs/awesomecode.io](https://codeship.com/projects/4dd93ee0-8870-0132-512f-523596b2e83f/status?branch=master)](https://codeship.com/projects/59433)

[ ![AwesomeCode Status for
xinminlabs/awesomecode.io](https://awesomecode.io/projects/1/status)](https://awesomecode.io/projects/1)

## Requirements

*  Ruby 2.1.3
*  Rails 4.1.4+
*  Redis
*  MySQL

## Setup

### Prerequisites

#### Installing git-flow

OSX (use Homebrew)

```
brew install git-flow
```

Linux (Ubuntu or Debian)
```
apt-get install git-flow
```

see more information on [installation](https://github.com/nvie/gitflow/wiki/Installation)

### Install

```
git clone git@github.com:xinminlabs/awesomecode.io.git
cd awesomecode.io
bundle install
rake bower:install
```

### Copy Config Files

```
cp config/database.yml.example config/database.yml # change it
cp config/secrets.yml.example config/secrets.yml # change it
cp config/redis.yml.example config/redis.yml # change it
cp config/application.yml.example config/application.yml # change it
cp config/email.yml.example config/email.yml # change it
```

### Set hook_url and domain_url in application.yml

1. Get your own ngork url from administrator, development.ngrok.com for example.
2. Replace hook_url with http://development.ngrok.com/projects/project_id/builds.
3. Replace domain_url with http://development.ngrok.com

### Setup ngrok

[ngrok](https://ngrok.com/usage) lets you expose a locally running web service to the internet.

Start ngrok with your own ngrok url.

```
ngrok -hostname development.ngrok.com
```

```
ngork
Tunnel Status                 online
Version                       1.7/1.6
Forwarding                    http://development.ngrok.com -> 127.0.0.1:3000
Forwarding                    https://development.ngrok.com -> 127.0.0.1:3000
Web Interface                 127.0.0.1:4040
# Conn                        0
Avg Conn Time                 0.00ms
```

When you run ngrok, it will display a UI in your terminal with the current status of the tunnel. This includes the public URL it has allocated to you which will forward to your local web service: https://development.ngrok.com -> 127.0.0.1:3000.

### Checkout develop branch

```
git checkout -b develop origin/develop
```

### Setup Database

```
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake rubocop:sync
```

### Start Server

```
bundle exec guard
```

## Deployment

```
bundle exec cap production deploy
```

## Additional

### Add hooks on Bitbucket/Github manually

Normally it will add hooks on Bibutcket/Github automatically, but when you have to do it manually, here is how:

* [POST hook management](https://confluence.atlassian.com/display/BITBUCKET/POST+hook+management)
* [Creating Webhooks](https://developer.github.com/webhooks/creating/)

Take coding_style_guide for example(This assume you have already imported projects from bitbucket and have a project with id:

1. Visit https://bitbucket.org/xinminlabs/coding_style_guide/admin/hooks.
2. Find the select box with text 'Select a hook'. Select POST and click 'Add hook' button.
3. Fill in the 'URL' with https://development.ngrok.com/projects/5/builds (It is the hook_url in the application.yml and its project_id is replaced with the real project id.)
4. Create a test branch and push to remote to see whether you local server receives the commit data from Bitbucket.

### Some guidelines

1.  Do not push code to master branch directly.
2.  Try not to push code to develop branch directly unless it is urgent or get approved.
3.  Use a seperate feature branch to work on your own feature and create a pull request after your pushed your feature branch to remote.

## How to upgrade ruby

1. update on codeship.io
2. update on linode-ops
3. update .ruby-version
4. update cap config
