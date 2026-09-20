#!/bin/bash

set -e

REPO_OWNER="seanockert"
REPO_NAME="sodeploy"
GITHUB_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/so"

# Override to install without root, e.g. INSTALL_DIR="$HOME/.local/bin"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
INSTALL_PATH="${INSTALL_DIR}/so"

# Colours only when writing to a terminal
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; NC=''
fi

TMP_DOWNLOAD=""
cleanup() {
    [[ -n "$TMP_DOWNLOAD" ]] && rm -f "$TMP_DOWNLOAD"
    return 0
}
trap cleanup EXIT

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

# Run one command as root, only when we are not root already
as_root() {
    if [[ "$EUID" -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        echo -e "${RED}❌ Need root to run: $*${NC}"
        exit 1
    fi
}

check_curl() {
    command -v curl >/dev/null 2>&1 || {
        echo -e "${RED}❌ curl required${NC}"
        exit 1
    }
}

check_install_dir() {
    [[ -w "$INSTALL_DIR" ]] && return 0
    [[ "$EUID" -eq 0 ]] && return 0
    command -v sudo >/dev/null 2>&1 && return 0

    echo -e "${RED}❌ Cannot write to ${INSTALL_DIR}, and sudo is not available${NC}"
    echo "Install somewhere you own instead:"
    echo "  INSTALL_DIR=\"\$HOME/.local/bin\" bash install.sh"
    exit 1
}

install_jq() {
    command -v jq >/dev/null 2>&1 && return

    echo -e "${YELLOW}Installing jq...${NC}"

    case "$(detect_os)" in
        darwin)
            # Homebrew refuses to run as root, so never wrap this in sudo
            command -v brew >/dev/null 2>&1 || {
                echo -e "${RED}❌ Homebrew required: https://brew.sh${NC}"
                exit 1
            }
            brew install jq
            ;;
        linux)
            if command -v apt-get >/dev/null 2>&1; then
                as_root apt-get update -qq
                as_root apt-get install -y jq
            elif command -v dnf >/dev/null 2>&1; then
                as_root dnf install -y jq
            elif command -v yum >/dev/null 2>&1; then
                as_root yum install -y jq
            else
                echo -e "${RED}❌ Install jq manually: sudo apt install jq${NC}"
                exit 1
            fi
            ;;
        windows)
            # Keep jq beside so, not in a different directory
            curl -fsSL -o "${INSTALL_DIR}/jq.exe" \
                https://github.com/jqlang/jq/releases/latest/download/jq-windows-amd64.exe
            chmod +x "${INSTALL_DIR}/jq.exe"
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
    local action="Installing"
    [[ -e "$INSTALL_PATH" ]] && action="Upgrading"
    echo -e "${YELLOW}${action} so...${NC}"

    # Download beside the target when possible, so the final move is a rename
    TMP_DOWNLOAD=$(mktemp "${INSTALL_DIR}/.so.XXXXXX" 2>/dev/null || mktemp)

    curl -fsSL "$GITHUB_URL" -o "$TMP_DOWNLOAD" || {
        echo -e "${RED}❌ Download failed${NC}"
        exit 1
    }

    # Check we got the script, not an error page or a partial transfer
    if [[ "$(head -c 11 "$TMP_DOWNLOAD")" != "#!/bin/bash" ]] \
        || [[ "$(wc -c < "$TMP_DOWNLOAD")" -lt 1000 ]]; then
        echo -e "${RED}❌ Downloaded file is not the so script${NC}"
        exit 1
    fi

    # 755, because mktemp creates 600 and root would own the result
    chmod 755 "$TMP_DOWNLOAD"

    # Put it in place in one step. A failed download cannot break an install.
    if [[ -w "$INSTALL_DIR" ]]; then
        mv "$TMP_DOWNLOAD" "$INSTALL_PATH"
    else
        as_root mv "$TMP_DOWNLOAD" "$INSTALL_PATH"
    fi
    TMP_DOWNLOAD=""
}

run_setup() {
    # setup writes to $HOME. Under sudo that is root's home, not the user's.
    if [[ "$EUID" -eq 0 && -n "${SUDO_USER:-}" ]]; then
        echo -e "${YELLOW}Run setup as yourself, not with sudo:${NC}"
        echo "  so setup"
        return 0
    fi

    local found
    found=$(command -v so 2>/dev/null || true)

    if [[ -z "$found" ]]; then
        echo -e "${YELLOW}⚠️  Restart terminal or: export PATH=\"${INSTALL_DIR}:\$PATH\"${NC}"
        echo "Then run: so setup"
        return 0
    fi

    if [[ "$found" != "$INSTALL_PATH" ]]; then
        echo -e "${YELLOW}⚠️  A different 'so' comes first on your PATH: ${found}${NC}"
    fi

    echo "Running setup..."
    set +e
    so setup
    local exit_code=$?
    set -e

    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}✅ Ready to deploy!${NC}"
    else
        echo -e "${YELLOW}⚠️  Run 'so setup' later to configure${NC}"
    fi
}

main() {
    echo "Installing SO Deploy..."
    echo

    check_curl
    check_install_dir
    install_jq
    install_so

    echo -e "${GREEN}✅ Installed to ${INSTALL_PATH}${NC}"
    echo

    run_setup

    echo
    echo "Usage: so | so -d <name> | so list | so teardown"
}

# Run main function
main
