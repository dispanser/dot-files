{ pkgs, editor, ... }:

{
  home.packages = with pkgs.fishPlugins; [ fzf-fish done ];
  programs.fish = {
    enable = true;
    shellAbbrs = let 
      editor_abbrevations = if editor == "hx" then {
        ed    = "nvim -d"; # helix doesn't have diff mode AFAIK
        se    = "sudo hx";
        e     = "hx";
        es    = "hx --vsplit";
        eh    = "hx --hsplit";
        ehist = "hx /home/pi/.local/share/fish/fish_history";
      } else {
        ed    = "nvim -d";
        se    = "sudo nvim";
        e     = "nvim";
        es    = "nvim -O";
        eh    = "nvim -o";
        ehist = "nvim /home/pi/.local/share/fish/fish_history";
      };
    in {
      cdc     = "cd ~/configs";
      cdp     = "cd $PROJECT_DIR";
      tf      = "tail -f";
      fm      = "free -m";
      dum     = "du -sm";
      restloc = "restic -r sftp:backup-zerotier:/fs/thomas_stuff/backup --password-file /home/data/backup/secret";
      restb2  = "restic -r b2:yukon-backup:/backup/yukon/home --password-file /home/data/backup/secret";
      sc      = "sudo cat";
      grep    = "rg --color=auto";
      mkp     = "mkdir -p";
      sysctl  = "sudo systemctl";
      fn      = "find -name";
      RBT     = "RUST_BACKTRACE=1";
      rmr     = "rm -r";
      recsync = "rsync -aH --info=progress2 --stats";
      rgh     = "rg -S --hidden";
      rgl     = "rg -S -l";
      rghl    = "rg -S --hidden -l";
      rglh    = "rg -S --hidden -l";
      reb     = "sudo systemctl reboot";
      sus     = "sudo systemctl suspend";
      gd      = "git diff";
      gdf     = "git diff --name-status";
      grv     = "git remote -v";
      gl      = "git pull";
      gp      = "git push";
      gco     = "git checkout";
      gsw     = "git switch";
      gcp     = "git cherry-pick";
      gbr     = "git branch";
      gba     = "git branch -a";
      gcip    = "git commit --interactive --patch";
      gaip    = "git add --interactive --patch";
      grip    = "git restore --patch";
      gvl     = "git log --pretty=format:\"[%h] %ae, %ar: %s\" --stat";
      gvd     = "git difftool --tool=vimdiff --no-prompt";
      gdt     = "git difftool --no-prompt";
      gdtc    = "git difftool --cached --no-prompt";
      ga      = "git add";
      gst     = "git status";
      gc      = "git commit";
      grs     = "git restore";
      gr      = "cd (git root)";
      grcb    = "git rebase --continue";
      cm      = "/usr/bin/cmake";
      cat     = "bat";
      k       = "kubectl";
      nsf     = "nix-shell --run fish";
      ndf     = "nix develop --command fish";
      tl      = "tmux list-sessions";
      nixq    = "nix search nixpkgs";
      t       = "${pkgs.time}/bin/time";
    } // editor_abbrevations;
    shellAliases = {
      gcm  = "git branch | rg main && git switch main || git switch master";
      tree = "exa -Tl --git";
      ls   = "exa --git";
      lt   = "ls -t modified";
      l    = "ls -laF";
    };
    functions = {
      epoch.body = "date --date=@$argv[1]";
      vw.body    = "nvim (which $argv)";
      rlfw.body  = "readlink -f (which $argv)";
      rlfs.body  = "readlink -f $argv[1] | tr -d '\n' | xclip -in -selection clipboard";
      rlft.body  = "tmux setb (readlink -f $argv | tr -d '\n')";
      rlfp.body  = "readlink -f $argv[1] | tr -d '\n' | xclip -in -selection primary";
      vrg.body   = "${editor} (rg -l --hidden $argv| fzf --multi)";
      vgf.body   = "${editor} (git ls-files | fzf)";
      vgr.body   = "${editor} (git ls-files (git root) | fzf)";
      rcd.body   = "tmux rename-window (basename (git root 2>/dev/null && echo (git root) || echo (pwd)))";
      fish_greeting = {
        description = "Greeting to show when starting a fish shell";
        body = "";
      };
    };
    interactiveShellInit = ''
      fish_hybrid_key_bindings
      set -x EDITOR nvim
      set PROJECT (${pkgs.wmctrl}/bin/wmctrl -d | grep '\*' | cut -b 33- | cut -f 1 -d_)
      set PROJECT_DIR ~/projects/$PROJECT
      # this is picked up by vim.
      set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow --glob "!.git/*"'
      set fzf_fd_opts --hidden --exclude=.git # for fzf.fish
      set --global --export FZF_DEFAULT_OPTS '--cycle --layout=reverse --border --height=90% --preview-window=wrap --info=inline --pointer="▶" --marker="✗" --bind "?:toggle-preview"  --bind "ctrl-a:select-all"'
      # --bind "ctrl-y:execute-silent(echo {+} | xargs tmux setb)" --bind "ctrl-e:execute(echo {+} | xargs -o nvim)"
      # note that a later incarnation of this command overwrites everything, even unmentioned
      fzf_configure_bindings --git_status=\e\cg --git_log=\e\ch --directory=\co --processes=\e\ci
      bind --mode insert \cz fg
    '';
  };
}
