# 注意， =两边是没有空格的，因为 alias 是一个 shell 命令，它只接受一个参数
alias gitlog="git log --graph --pretty=format:'%Cred%h%Creset - %Cblue%an%Creset %C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias du='du -hd1'
alias weather='curl wttr.in/shanghai'
alias temperature='sudo powermetrics --samplers smc'
alias help='tldr'
alias printh='print %x' //转换成16进制
alias rm='rm -i'
alias ls='eza'
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'
alias cd='zoxide'
alias cat='bat'

# If you come from bash you might have to change your $PATH.
#export PATH="$HOME/bin:/usr/local/bin:$PATH"

ulimit -n 200000

export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="random"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting sudo wakatime zsh-vi-mode)

source $ZSH/oh-my-zsh.sh

# export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
# source /Users/tesla/tesla/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# export HOMEBREW_INSTALL_FROM_API=1
# export HOMEBREW_API_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api"
# export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
# export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git"
# export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
