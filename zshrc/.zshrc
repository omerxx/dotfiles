# Modular zsh configuration - auto-source all .zsh files in order
ZSH_CONFIG_DIR="${0:A:h}"

for config in "$ZSH_CONFIG_DIR"/*.zsh; do
  # Skip the main .zshrc file itself
  [[ "$config" != "$0" ]] && [ -r "$config" ] && source "$config"
done
