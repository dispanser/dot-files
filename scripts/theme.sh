
function dark() {
  tmux set -g window-style fg=colour250,bg='#00252e'
  tmux set -g window-active-style fg=colour250,bg='#001e26'
  tmux set-option -g pane-border-style "fg=colour235 bg=#00252e"
  tmux set-option -g pane-active-border-style "fg=blue bg=#001e26"
  tmux set-window-option -g window-status-style "fg=brightblue bg=colour236 dim"
  tmux set-window-option -g status-style "fg=brightblue bg=colour236 dim"
  tmux set-window-option -g window-status-current-style "fg=orange bg=color0 bright"
}

function light() {
  tmux set -g window-style fg=colour0,bg=color7
  tmux set -g window-active-style fg=colour0,bg=color15
  tmux set-option -g pane-border-style "fg=colour235 bg=color7"
  tmux set-option -g pane-active-border-style "fg=blue bg=color15"
  tmux set-window-option -g status-style "fg=brightblue bg=color7 bright"
  tmux set-window-option -g window-status-style "fg=brightblue bg=color7 bright"
  tmux set-window-option -g window-status-current-style "fg=orange bg=color15 bright"
}

case $1 in
  dark) 
    echo dark
    kitty +kitten themes --reload-in=all Solarized\ Dark
    dark
    ;;
  light) 
    kitty +kitten themes --reload-in=all Solarized\ Light
    light
    ;;
esac
