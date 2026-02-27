export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
plugins=(git)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

if [ -f "$HOME/.zsh/peacock.sh" ]; then
  source "$HOME/.zsh/peacock.sh"
fi

if [ -f "$HOME/.zsh/aliases.zsh" ]; then
  source "$HOME/.zsh/aliases.zsh"
fi

if [ -d "$HOME/.zsh/aliases.d" ]; then
  for alias_file in "$HOME"/.zsh/aliases.d/*.zsh; do
    if [ -f "$alias_file" ]; then
      source "$alias_file"
    fi
  done
fi
