#!/bin/bash
#
# Setting symlinks to dotfiles and keybase repos
#
DOTFILES_PATH=~/projects/dotfiles
KEYBASE_ZSH=~/projects/zshrc
KEYBASE_KUBE=~/projects/kube

ln -s ${DOTFILES_PATH}/tmux/.tmux.conf .tmux.conf
ln -s ${DOTFILES_PATH}/zsh/omer.zsh-theme ~/.oh-my-zsh/themes/omer.zsh-theme
ln -s ${DOTFILES_PATH}/vim/.vimrc ~/.vimrc
ln -s ${KEYBASE_ZSH}/.zshrc ~/.zshrc
ln -s ${KEYBASE_KUBE} ~/.kube

