# Aliases partilhados (ficheiro único no repositório).
# O instalador zsh faz: ln -sf este ficheiro em ~/.aliases.zsh e acrescenta
#   [[ -f ~/.aliases.zsh ]] && source ~/.aliases.zsh
# no ~/.zshrc (depois do Oh My Zsh). Reexecutar o instalador atualiza o symlink.
# Depois de editar aqui: refresh-zsh (ou abre um novo terminal).

# APT / caminhos
alias upgrade="sudo apt update -y && sudo apt upgrade"
alias projects="cd ~/projects"
alias refresh-zsh="source ~/.zshrc"
alias aliases='${EDITOR:-nano} ~/.aliases.zsh'

# Docker
alias docker-stop-all="docker ps -q | xargs -r docker stop"
alias dps="docker ps"
alias dimg="docker images"
alias dc="docker compose"

# Sistema
alias ports="ss -tulpn"
alias disk="df -h"
alias mem="free -h"

# Git
alias gs="git status"
alias glog="git log --oneline -n 20"

# GitHub CLI
alias gh-repos="gh repo list"
alias copilot="gh copilot"
