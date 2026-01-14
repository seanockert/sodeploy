# SO Deploy

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

- A domain hosted on Cloudflare
- macOS, Linux, or Windows (Git Bash)

## Quick Start

### 1. Install

**macOS/Linux** (requires sudo):
```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/seanockert/sodeploy/main/install.sh)"
```

**Or via Homebrew** (macOS):
```bash
brew install seanockert/sodeploy/sodeploy
```

The installer will automatically run `so setup` to configure your Cloudflare credentials.

### 2. Configure Cloudflare

Before running setup, create an API token in your [Cloudflare dashboard](https://dash.cloudflare.com/profile/api-tokens) with these permissions:
- Account: Worker Scripts: Edit
- Zone: Zone: Edit
- Zone: DNS: Edit
- Zone: Workers Routes: Edit

During setup, you'll need:
- API Token (the one you just created)
- Account ID (found in account home settings)
- Zone ID (found in domain settings)
- Base domain (e.g., `mydomain.com`)

If you skipped setup during installation, run `so setup` anytime.

## Manual Installation

If you prefer to install manually:

```bash
# Download the script
curl -fsSL https://raw.githubusercontent.com/seanockert/sodeploy/main/so -o so

# Install to /usr/local/bin
sudo mv so /usr/local/bin/
sudo chmod +x /usr/local/bin/so

# Install dependencies
# macOS:
brew install jq

# Linux (Ubuntu/Debian):
sudo apt install jq

# Linux (CentOS/RHEL):
sudo yum install jq
```

## Usage

```bash
so                    # Deploy current folder
so -d <name>          # Deploy with custom subdomain
so list               # List all deployed sites
so teardown           # Delete current folder's site
so teardown <name>    # Delete specific site
so setup              # Configure Cloudflare credentials
```

## Windows Support

Works on Windows via Git Bash. The installer will automatically download `jq` for Windows during installation.
