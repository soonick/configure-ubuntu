# Env variables
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64/"
export EDITOR=nvim

# Start tmux by default when openning a terminal
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux
fi

# Aliases
alias beep="spd-say 'beep beep beep'"
alias c="clear"
alias ga="git add"
alias gc="git commit"
alias gd="git diff"
alias gl="git lg"
alias gpom="git push origin master"
alias gpr="git pull --rebase"
alias gs="git status"
alias kb="kubectl"
alias kcc="kubectl config current-context"
alias kgd="kubectl get deployments"
alias kgg="kubectl get gateways"
alias kgig="kubectl get istio-gateways"
alias kgp="kubectl get pods --sort-by=.metadata.creationTimestamp"
alias kgs="kubectl get services"
alias kgv="kubectl get vs"
alias klc="kubectl config get-contexts"
alias kuc="kubectl config use-context"
alias vim="nvim"

# Configurations
set -o vi

# Functions

## Create github branch that tracks origin/master
## 1 - Branch name
gcb() {
  git checkout -b "$1"
  git branch --set-upstream-to=origin/master $1
}

## Find and replace in folder
## 1 - Text to find
## 2 - Text it will be replaced with
frif() {
  find . -type f -exec sed -i "s/$1/$2/g" {} \;
}
