tmux rename-window $(basename $(git root 2>/dev/null && echo $(git root) || echo $(pwd)))
