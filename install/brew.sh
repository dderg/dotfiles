#!/bin/sh

if test ! $(which brew); then
    echo "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo -e "\n\nInstalling homebrew packages..."
echo "=============================="

formulas=(
    # flags should pass through the the `brew list check`
    fzf
    git
    diff-so-fancy
    'grep --with-default-names'
    markdown
    neovim/neovim/neovim
    reattach-to-user-namespace
    the_silver_searcher
    tmux
    tree
    wget
    z
    zsh
    zsh-completions
    ripgrep
    mas
)

cask_formulas=(
    iterm2
    telegram
    kawa
    reflex
    docker
    kap
    aldente
    arc
)

for formula in "${formulas[@]}"; do
    if brew list "$formula" > /dev/null 2>&1; then
        echo "$formula already installed... skipping."
    else
        brew install $formula
    fi
done

for formula in "${cask_formulas[@]}"; do
    if brew list "$formula" > /dev/null 2>&1; then
        echo "$formula already installed... skipping."
    else
        brew install --cask $formula
    fi
done
