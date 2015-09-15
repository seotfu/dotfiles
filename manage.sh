#!/usr/bin/env bash


readonly USAGE_STR="Usage: ./manage.sh {install|uninstall}"

readonly INSTALL_CMD="install"
readonly UNINSTALL_CMD="uninstall"

readonly VUNDLE_GIT_URL="https://github.com/gmarik/Vundle.vim.git"
readonly VUNDLE_PARTIAL_PATH=".vim/bundle"
readonly VUNDLE_COMPLETE_PATH="$VUNDLE_PARTIAL_PATH/Vundle.vim"


function main() {
  local argc="$1"
  local arg="$2"

  if [[ "$argc" == 1 ]]; then
    case "$arg" in
      "$INSTALL_CMD")
        install_dotfiles
        ;;
      "$UNINSTALL_CMD")
        uninstall_dotfiles
        ;;
      *)
        echo "$USAGE_STR"
        exit 1
        ;;
    esac
  else
    echo "$USAGE_STR"
    exit 1
  fi
  exit 0
}

function install_dotfiles() {
  git --version &> /dev/null
  if [[ "$?" != 0 ]]; then
    echo "Installing git..."
    sudo apt-get install -y git > /dev/null
  fi

  if [[ ! -d "$VUNDLE_DIR" ]]; then
    echo "Installing Vundle..."
    git clone --quiet "$VUNDLE_GIT_URL" "$VUNDLE_COMPLETE_PATH"
  fi

  echo "Symlinking dotfiles..."
  for dotfile in $(find . -maxdepth 1 -name ".[^.]*" -exec basename {} \; | \
                   grep -vE ".git(ignore)?$"); do
    local dotfile_path="$PWD/$dotfile"
    local symlink_path="$HOME/$dotfile"

    if [[ -h "$symlink_path" ]]; then
      rm "$symlink_path"
    fi
    ln -s "$dotfile_path" "$symlink_path"
  done

  echo "Preparing to install Vim plugins..."
  sleep 3
  vim +PluginInstall +qall

  echo "Dotfiles successfully installed."
}

function uninstall_dotfiles() {
  echo "Removing symlinks to dotfiles..."
  for dotfile in $(find . -maxdepth 1 -name ".[^.]*" -exec basename {} \; | \
                   grep -vE ".git(ignore)?$"); do
    local symlink_path="$HOME/$dotfile"

    if [[ -h "$symlink_path" ]]; then
      rm "$symlink_path"
    fi
  done

  echo "Uninstalling Vim plugins..."
  rm -rf "$VUNDLE_PARTIAL_PATH"

  echo "Dotfiles successfully uninstalled."
}

if [[ $(uname) == "Linux" ]]; then
  main "$#" "$1"
else
  echo "Dotfiles were NOT installed. Linux only for now."
fi
