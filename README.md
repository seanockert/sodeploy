# So Deploy

Deploy a website from a local folder to your Cloudflare domain with one command:

```bash
cd my-app
so
```

https://github.com/user-attachments/assets/191e9d84-3788-4c12-8491-020274947d54




## What and why

I use [surge.sh](https://surge.sh/) to quickly deploy web projects for sharing and testing. SO Deploy does the same but using your own domain. I made it to scratch my own itch.

When you run the `so` command in a local folder, it creates a new public subdomain (eg. `https://my-folder.my-domain.com`) and deploys the contents of that folder to it within seconds.

To remove the site and subdomain, simply run `so teardown`

## Requirements

A domain hosted on Cloudflare.

## Install

### Via Homebrew:

```bash
brew install seanockert/sodeploy/sodeploy
```

### Or download the `so` file from this repo:

```bash
# Install the script by moving it to /usr/local/bin/ 
sudo mv so /usr/local/bin/

# Give it the right permissions
chmod +x /usr/local/bin/so

# Install dependencies: curl (probably have already) and jq
brew install jq curl
```

## Setup

### 1. Create an API token with the following permissions: 
  - Account: Worker Scripts: Edit
  - Zone: Zone: Edit
  - Zone: DNS: Edit
  - Zone: Workers Routes: Edit

### 2. Run setup

```bash
# Run the setup
so setup
```

You'll need the following Cloudflare credentials:

1. The API token you just created
2. Account ID (account home settings -> Copy account ID)
3. Zone ID (domain settings -> Copy zone ID)
4. Base domain (eg. mydomain.com)

## Available commands

```bash
# Deploy current folder
so

# Deploy with custom subdomain
so -d <name> 

# List all deployed sites
so list

# Delete current folder's site
so teardown

# Delete specific site
so teardown <name>

# Configure Cloudflare credential
so setup
```

## Windows support

Not tested on Windows yet but it should work fine. Runs via Git Bash. 

When you run the `./so setup` command it will prompt you to install the `jq` dependency.
