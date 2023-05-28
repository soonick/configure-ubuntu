# Aliases
alias c="clear"
alias ga="git add"
alias gc="git commit"
alias gd="git diff"
alias gl="git lg"
alias gpom="git push origin master"
alias gpr="git pull --rebase"
alias gs="git status"
alias kb="kubectl"
alias kgp="kubectl get pods"
alias vim="nvim"

# Configurations
set -o vi

# Functions

# Creates a new branch that tracks origin/master
function gcb {
  local branch_name="$1"
  git checkout -b "$branch_name"
  git branch --set-upstream-to origin/master
}
