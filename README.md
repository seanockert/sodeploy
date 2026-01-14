# SO Deploy

Deploy a website from a local folder to your Cloudflare domain with one command:

```bash
cd my-app
so
# It's live!
```

https://github.com/user-attachments/assets/191e9d84-3788-4c12-8491-020274947d54


## What and why

I use [surge.sh](https://surge.sh/) to quickly deploy web projects for sharing and testing. SO Deploy does the same on your own domain.

Run the `so` command in a local folder. It creates a new public subdomain (eg. `https://my-folder.my-domain.com`) and deploys the contents of that folder to it in seconds.

To remove it, run `so teardown`.

## Requirements

- A domain hosted on Cloudflare

## Quick Start

### 1. Install

**macOS/Linux**:
```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/seanockert/sodeploy/main/install.sh)"
```

**Or via Homebrew** (macOS):
```bash
brew install seanockert/sodeploy/sodeploy
```

**Or via Git Bash** (Windows)

The installer will automatically run `so setup` to configure your Cloudflare credentials.

### 2. Configure Cloudflare

Before running setup, create an API token in your [Cloudflare dashboard](https://dash.cloudflare.com/profile/api-tokens) with these permissions:
- `Account: Worker Scripts: Edit`
- `Zone: Zone: Edit`
- `Zone: DNS: Edit`
- `Zone: Workers Routes: Edit`

During setup, you'll need:
- API Token (the one you just created)
- Account ID (found in account home settings)
- Zone ID (found in domain settings)
- Base domain (e.g., `mydomain.com`)

If you skipped setup during installation, run `so setup` anytime.

## Usage

```bash
so                    # Deploy current folder
so -d <name>          # Deploy with custom subdomain
so list               # List all deployed sites
so teardown           # Delete current folder's site
so teardown <name>    # Delete specific site
so setup              # Configure Cloudflare credentials
```
