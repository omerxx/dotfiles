#!/bin/bash
cd ~/dotfiles       
brew bundle dump --file=~/dotfiles/Brewfile --force
tar -cf - github-copilot raycast | openssl enc -aes-256-cbc -pbkdf2 -e -out archive.tar.gz
cd zed
tar -cf - conversations prompts | openssl enc -aes-256-cbc -pbkdf2 -e -out archive.tar.gz
cd ~/dotfiles       
git add .         
git commit -m "My dotfiles synced from remote machines"
git push origin main
echo "✅ Complete!"
