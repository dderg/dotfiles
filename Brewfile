# vim:ft=ruby

tap "homebrew/bundle"

if OS.mac?
  tap "FelixKratz/formulae"               # For janky borders
  tap "dderg/tap"

  brew "mini-badger"

  # taps
  brew "noti"                          # utility to display notifications from scripts
  brew "trash"                         # rm, but put in the trash rather than completely delete
  brew "borders"                       # add borders to windows

  # Applications
  cask "leader-key"                   # a quick application launcher
  cask "ghostty"                      # a better terminal emulator
  cask "wezterm@nightly"              # a better terminal emulator
  cask "nikitabobko/tap/aerospace"    # a tiling window manager
  cask "dimentium/autoraise/autoraiseapp" # focus-follows-mouse
  cask "docker"
  cask "reflex"                       # so play pause only pauses the music and not youtube
  cask "kap"                          # screen recorder
  cask "aldente"                      # battery tool
  cask "arc"                          # browser I want to go away from
  cask "orion"                        # browser I want to use more
  cask "raycast"                      # a better spotlight

  # Fonts
  cask "font-symbols-only-nerd-font"   # nerd-only symbols font
  cask "font-monaspace"                # Preferred monospace font
elsif OS.linux?
  brew "xclip"                         # access to clipboard (similar to pbcopy/pbpaste)
end

# Latest versions of some core utilities
brew "git"                             # Git version control
brew "vim"                             # Vim editor
brew "bash"                            # bash shell
brew "zsh"                             # zsh shell
brew "grep"                            # grep

# packages
brew "starship"                        # a better prompt
brew "bat"                             # better cat
brew "cloc"                            # lines of code counter
brew "entr"                            # file watcher / command runner
brew "eza"                             # ls alternative
brew "fd"                              # find alternative
brew "fnm"                             # Fast Node version manager
brew "rbenv"                           # Ruby version manager
brew "fzf"                             # Fuzzy file searcher, used in scripts and in vim
brew "gh"                              # GitHub CLI
brew "git-delta"                       # a better git diff
brew "glow"                            # markdown viewer
brew "gnupg"                           # GPG
brew "highlight"                       # code syntax highlighting
brew "btop"                            # a top alternative
brew "jq"                              # work with JSON files in shell scripts
brew "lazygit"                         # a better git UI
brew "neovim"                          # A better vim
brew "python"                          # python (latest)
brew "ripgrep"                         # very fast file searcher
brew "shellcheck"                      # diagnostics for shell sripts
brew "stylua"                          # lua code formatter
brew "tmux"                            # terminal multiplexer
brew "tree"                            # pretty-print directory contents
brew "wdiff"                           # word differences in text files
brew "wget"                            # internet file retriever
brew "zoxide"                          # switch between most used directories
