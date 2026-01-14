#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_OWNER="seanockert"
REPO_NAME="sodeploy"
GITHUB_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/so"
INSTALL_DIR="/usr/local/bin"
INSTALL_PATH="${INSTALL_DIR}/so"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

check_permissions() {
    [[ "$(detect_os)" == "windows" ]] && return 0
    ([[ -w "$INSTALL_DIR" ]] || [[ "$EUID" -eq 0 ]]) && return 0
    mkdir -p "$INSTALL_DIR" 2>/dev/null && [[ -w "$INSTALL_DIR" ]] && return 0
    
    echo -e "${YELLOW}⚠️  Requires sudo. Run: sudo bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/install.sh)\"${NC}"
    exit 1
}

check_curl() {
    command -v curl >/dev/null 2>&1 || {
        echo -e "${RED}❌ curl required${NC}"
        exit 1
    }
}

install_jq() {
    command -v jq >/dev/null 2>&1 && return
    
    local os=$(detect_os)
    echo -e "${YELLOW}📦 Installing jq...${NC}"

    case "$os" in
        darwin)
            command -v brew >/dev/null 2>&1 || {
                echo -e "${RED}❌ Homebrew required: https://brew.sh${NC}"
                exit 1
            }
            brew install jq
            ;;
        linux)
            if command -v apt-get >/dev/null 2>&1; then
                apt-get update -qq && apt-get install -y jq
            elif command -v yum >/dev/null 2>&1; then
                yum install -y jq
            elif command -v dnf >/dev/null 2>&1; then
                dnf install -y jq
            else
                echo -e "${RED}❌ Install jq manually: sudo apt install jq${NC}"
                exit 1
            fi
            ;;
        windows)
            curl -fsSL -o /usr/bin/jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe
            chmod +x /usr/bin/jq.exe
            ;;
        *)
            echo -e "${RED}❌ Unsupported OS${NC}"
            exit 1
            ;;
    esac

    command -v jq >/dev/null 2>&1 || {
        echo -e "${RED}❌ jq installation failed${NC}"
        exit 1
    }
}

install_so() {
    echo -e "${YELLOW}📥 Installing so...${NC}"
    mkdir -p "$INSTALL_DIR"
    curl -fsSL "$GITHUB_URL" -o "$INSTALL_PATH" || {
        echo -e "${RED}❌ Download failed${NC}"
        exit 1
    }
    chmod +x "$INSTALL_PATH"
}

main() {
    echo "🚀 Installing So Deploy..."
    echo
    
    check_curl
    check_permissions
    install_jq
    install_so
    
    echo -e "${GREEN}✅ Installed${NC}"
    echo
    
    if ! command -v so >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Restart terminal or: export PATH=\"${INSTALL_DIR}:\$PATH\"${NC}"
        echo "Then run: so setup"
        return
    fi
    
    echo "🔧 Running setup..."
    set +e
    so setup
    local exit_code=$?
    set -e
    
    [[ $exit_code -eq 0 ]] && echo -e "${GREEN}✅ Ready to deploy!${NC}" || echo -e "${YELLOW}⚠️  Run 'so setup' later to configure${NC}"
    
    echo
    echo "Usage: so | so -d <name> | so list | so teardown"
}

# Run main function
main
