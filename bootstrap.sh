#!/usr/bin/env bash

set -Eeuo pipefail

# --- Colors (minimal, no dependencies) ---
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

info() { printf "${BLUE}ℹ${RESET} %s\n" "$1"; }
success() { printf "${GREEN}✔${RESET} %s\n" "$1"; }
warn() { printf "${YELLOW}⚠${RESET} %s\n" "$1"; }
error() { printf "${RED}✖${RESET} %s\n" "$1" >&2; }

DOTFILES_REPO="git@github.com:dderg/dotfiles.git"
DOTFILES_DIR="$HOME/Developer/dotfiles"

# --- Xcode CLI Tools ---
install_xcode_cli() {
  if xcode-select -p &>/dev/null; then
    success "Xcode CLI tools already installed"
    return
  fi

  info "Installing Xcode CLI tools (needed for git, ssh, etc.)..."
  xcode-select --install

  # Wait for installation to complete
  info "Waiting for Xcode CLI tools installation to finish..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  success "Xcode CLI tools installed"
}

# --- SSH Key Setup ---
setup_ssh() {
  local key="$HOME/.ssh/id_ed25519"

  if [[ -f "$key" ]]; then
    success "SSH key already exists at $key"
  else
    info "Generating a new SSH key..."
    read -rp "Email for SSH key: " email
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$email" -f "$key"
    success "SSH key generated"
  fi

  # Start ssh-agent and add key
  eval "$(ssh-agent -s)" > /dev/null
  ssh-add --apple-use-keychain "$key" 2>/dev/null || ssh-add "$key"

  # Copy public key to clipboard
  if command -v pbcopy &>/dev/null; then
    pbcopy < "${key}.pub"
    success "Public key copied to clipboard"
  else
    warn "Could not copy to clipboard. Here is your public key:"
    cat "${key}.pub"
  fi

  echo ""
  info "Opening GitHub SSH key settings..."
  info "Paste the key (it's already in your clipboard) and save it."
  echo ""
  open "https://github.com/settings/ssh/new" 2>/dev/null || true

  read -rp "Press Enter once you've added the key to GitHub..."

  # Verify the key works
  info "Verifying SSH connection to GitHub..."
  if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    success "GitHub SSH authentication successful"
  else
    warn "Could not verify SSH auth (this is sometimes expected). Continuing..."
  fi
}

# --- Clone Dotfiles ---
clone_dotfiles() {
  if [[ -d "$DOTFILES_DIR" ]]; then
    success "Dotfiles already cloned at $DOTFILES_DIR"
    return
  fi

  info "Cloning dotfiles to $DOTFILES_DIR..."
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  success "Dotfiles cloned"
}

# --- Install Homebrew ---
install_homebrew() {
  if command -v brew &>/dev/null; then
    success "Homebrew already installed"
    return
  fi

  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for the rest of this script
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  success "Homebrew installed"
}

# --- Main ---
main() {
  echo ""
  printf "${BOLD}${BLUE}  Dotfiles Bootstrap${RESET}\n"
  echo ""

  install_xcode_cli
  setup_ssh
  clone_dotfiles
  install_homebrew

  echo ""
  success "Bootstrap complete! Next steps:"
  echo ""
  echo "  cd $DOTFILES_DIR"
  echo ""
  echo "  # Link config files"
  echo "  dot link all"
  echo ""
  echo "  # Install Homebrew packages"
  echo "  dot brew bundle"
  echo ""
  echo "  # Set up git identity"
  echo "  dot git setup"
  echo ""
  echo "  # Configure macOS defaults"
  echo "  dot macos defaults"
  echo ""
  echo "  # Set up shell"
  echo "  dot shell change"
  echo ""
}

main "$@"
