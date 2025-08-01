{ pkgs, ... }:
{
  programs.tmux.tmuxinator.enable = true;
  programs.tmux = {
    enable        = true;
    prefix        = "C-Space";
    sensibleOnTop = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.extrakto
      tmuxPlugins.jump
      {
        plugin = tmuxPlugins.tmux-thumbs;
        extraConfig = ''
          set -g @thumbs-key m
          # gives shorter hints closer to the curser; evaluate
          set -g @thumbs-reverse enabled
          set -g @thumbs-unique enabled
          set -g @thumbs-fg-color blue
          set -g @thumbs-hints-fg-color red
          set -g @thumbs-contrast 1
          set -g @thumbs-osc52 0
          # set -g @thumbs-bg-color
          # bind-key -n C-M-t thumbs-pick
          
          set -g @thumbs-command 'tmux set-buffer -- {} && echo -n {} | pbcopy && tmux display-message \"tyx/Copied {}\"'
          # set -g @thumbs-command 'tmux set-buffer -- {} && tmux display-message \"Copied {}\"'
        '';
      }
      {
        plugin = tmuxPlugins.tmux-colors-solarized;
        extraConfig = "set -g @colors-solarized 'dark'";
      }
      {
        plugin = tmuxPlugins.open;
        extraConfig = "set -g @open-O 'https://www.duckduckgo.com/?q='";
      }
    ];
      # TODO: test what happens on logout (true: default)
      secureSocket = true;
      extraConfig = 
      let 
        # termOption = if pkgs.stdenv.isDarwin then "screen-256color" else "tmux-256color";
        termOption = "tmux-256color";
      in ''
          bind C-Space send-prefix
          set-option -sa terminal-overrides ",*:Tc"
          set -ga terminal-overrides ",alacritty:Tc"
          set -g default-terminal "${termOption}"
          set-option -g set-titles on
          set-option -g set-titles-string "#S"
          set-option -g status on
          set-option -g allow-rename off
          set -g focus-events on # recommended by gitgutter

          # set window list colors - red for active and cyan for inactive
          set-window-option -g window-status-style "fg=brightblue bg=colour236 dim"
          set-window-option -g window-status-current-style "fg=orange bg=color0 bright"
          set-window-option -g window-status-separator " | "

          # slightly darker (higher contrast) background for active pane.
          set -g window-style fg=colour250,bg='#00252e'
          set -g window-active-style fg=colour250,bg='#001e26'

          # background color matching pane background for active and inactive panes
          set-option -g pane-border-style "fg=colour235 bg=#00252e"
          set-option -g pane-active-border-style "fg=blue bg=#001e26"

          bind -n C-M-c clear-history # clear local pane buffer.

          bind-key C-Space last-window
          bind-key -n C-M-Space last-window
          bind-key -n C-M-h popup
          bind-key -n C-M-[ copy-mode
          bind-key -n C-M-c copy-mode
          bind-key -n C-M-] paste
          bind-key -n C-M-p copy-mode \; send-keys -X search-backward "╰─" \; send-keys -l n
          bind-key -n C-M-r copy-mode \; send-keys -X search-backward "Compiling"
          bind-key -n C-M-o copy-mode \; send-keys -X search-backward "tyx/"
          bind-key -n C-M-e copy-mode \; send-keys -X search-backward "FAILED"
          bind-key -n C-M-x copy-mode \; send-keys -X search-again
          bind-key -n C-M-s copy-mode \; command-prompt -p "(search up)" "send -X search-backward \"%%%\""

          bind -n M-§ select-window -t :=0
          bind -n M-` select-window -t :=0
          bind -n M-Tab select-window -t :=0
          bind -n M-0 select-window -t :=0
          bind -n M-1 select-window -t :=1
          bind -n M-2 select-window -t :=2
          bind -n M-3 select-window -t :=3
          bind -n M-4 select-window -t :=4
          bind -n M-5 select-window -t :=5
          bind -n M-6 select-window -t :=6
          bind -n M-7 select-window -t :=7
          bind -n M-8 select-window -t :=8
          bind -n M-9 select-window -t :=9

          bind-key -n M-C-f resize-pane -Z

          bind-key -r ^J resize-pane -D 5
          bind-key -r ^K resize-pane -U 5
          bind-key -r ^H resize-pane -L 5
          bind-key -r ^L resize-pane -R 5

          bind-key -n C-M-j previous-window
          bind-key -n C-M-k next-window

          bind-key / split-window -h
          bind-key - split-window

          set-window-option -g mode-keys vi
          bind-key -T copy-mode-vi 'v' send -X begin-selection

          bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard"
          bind-key -T copy-mode-vi 'Y' send-keys -X copy-pipe-and-cancel "xclip -in -selection primary"

          bind p run "xclip -o -selection clipboard  | tmux load-buffer - ; tmux paste-buffer"
          bind P run "xclip -o -selection primary | tmux load-buffer - ; tmux paste-buffer"
        '';
    };
  }

