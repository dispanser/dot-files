{ pkgs, editor, ... }:

{
  # home.packages = with pkgs.fishPlugins; [ fzf-fish done ];
  programs.fish.plugins = [
    {
      name = "fzf-fish";
      src = pkgs.fetchFromGitHub {
        owner = "PatrickF1";
        repo = "fzf.fish";
        rev = "dfdf69369bd3a3c83654261f90363da2aa1db8c9";
        sha256 = "sha256-x/q7tlMlyxZ1ow2saqjuYn05Z1lPOVc13DZ9exFDWoU=";
      };
    }
  ];

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
        ed    = ''nvim -d -c "colorscheme solarized8_dark_flat"'';
        se    = "sudo nvim";
        e     = "nvim";
        es    = "nvim -O";
        eh    = "nvim -o";
        ehist = "nvim /home/pi/.local/share/fish/fish_history";
      };
    in {
      cdc     = "cd ~/configs";
      tf      = "tail -f";
      fm      = "free -m";
      dum     = "du -sm";
      sc      = "sudo cat";
      grep    = "rg --color=auto";
      mkp     = "mkdir -p";
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
      # gdt     = "git difftool --no-prompt";
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
      nsf     = "nix-shell --run fish -p ";
      ndf     = "nix develop --command fish";
      tl      = "tmux list-sessions";
      nixq    = "nix search nixpkgs";
      t       = "${pkgs.time}/bin/time";
    } // editor_abbrevations;
    shellAliases = {
      cdp     = "cd $PROJECT_DIR";
      restloc = "restic -r sftp:backup-zerotier:/fs/thomas_stuff/backup --password-file /home/data/backup/secret";
      restb2  = "restic -r b2:yukon-backup:/backup/yukon/home --password-file /home/data/backup/secret";
      gcm  = "git branch | rg main && git switch main || git switch master";
      tree = "eza -Tl --git";
      ls   = "eza --git";
      lt   = "ls -l --sort newest";
      l    = "ls -laF";
      ",c" = "clear; ${pkgs.tmux}/bin/tmux clear-history";
    };
    functions = {
      gdt.body   = ''nvim -c "colorscheme solarized8_dark_flat" "+DiffviewOpen $argv"'';
      gdc.body   = ''nvim -c "colorscheme solarized8_dark_flat" "+DiffviewOpen $argv[1]^1..$argv[1]"'';
      gdh.body   = ''nvim -c "colorscheme solarized8_dark_flat" "+DiffviewOpen HEAD^1"'';
      epoch.body = "date --date=@$argv[1]";
      vw.body    = "nvim (which $argv)";
      rlfw.body  = "readlink -f (which $argv)";
      rlft.body  = "tmux setb (readlink -f $argv | tr -d '\n')";
      vrg.body   = "${editor} (rg -l --hidden $argv| fzf --multi)";
      vgf.body   = "${editor} (git ls-files | fzf)";
      vgr.body   = "${editor} (git ls-files (git root) | fzf)";
      rcd.body   = "tmux rename-window (basename (git root 2>/dev/null && echo (git root) || echo (pwd)))";
      k9d.body   = "kubectl config get-contexts -o name | fzf | xargs k9s -c deploy $argv --context";
      k9p.body   = "kubectl config get-contexts -o name | fzf | xargs k9s -c pods $argv --context";
    } // (if pkgs.stdenv.isLinux then {
        rlfs.body  = "readlink -f $argv[1] | tr -d '\n' | xclip -in -selection clipboard";
        rlfp.body  = "readlink -f $argv[1] | tr -d '\n' | xclip -in -selection primary";
      } else {
        rlfs.body  = "readlink -f $argv[1] | tr -d '\n' | pbcopy";
        # same command as the distinction between primary and secondary does not exist on MacOS
        rlfp.body  = "readlink -f $argv[1] | tr -d '\n' | pbcopy";
      });
    interactiveShellInit = ''
      fish_hybrid_key_bindings
      set -x EDITOR ${editor}
      # this is picked up by vim.
      set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow --glob "!.git/*"'
      set fzf_fd_opts --hidden --exclude=.git # for fzf.fish
      set --global --export FZF_DEFAULT_OPTS '--cycle --layout=reverse --border --height=90% --preview-window=wrap --info=inline --pointer="▶" --marker="✗" --bind "?:toggle-preview"  --bind "ctrl-a:select-all"'
      # --bind "ctrl-y:execute-silent(echo {+} | xargs tmux setb)" --bind "ctrl-e:execute(echo {+} | xargs -o nvim)"
      # note that a later incarnation of this command overwrites everything, even unmentioned
      fzf_configure_bindings --git_status=\e\cg --git_log=\e\cl --directory=\co --processes=\e\cp
      bind --mode insert \cz fg
      '' + (if pkgs.stdenv.isDarwin then ''
        fish_add_path --move {$HOME}/bin
        fish_add_path --move {$HOME}/go/bin
        fish_add_path --move {$HOME}/darwin/bin
        fish_add_path --move {$HOME}/.cargo/bin
        for p in (string split " " $NIX_PROFILES)
          fish_add_path --prepend --move $p/bin
        end
        /opt/homebrew/bin/brew shellenv | source
        # under test
        /usr/bin/ssh-add --apple-use-keychain ~/.ssh/coralogix-github
      '' else ''
        set PROJECT (${pkgs.wmctrl}/bin/wmctrl -d | grep '\*' | cut -b 33- | cut -f 1 -d_)
        set PROJECT_DIR ~/projects/$PROJECT
        set PATH $HOME/bin:$HOME/bin/linux:$PATH
      '');
  };
}
