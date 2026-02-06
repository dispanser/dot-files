{ config, pkgs, editor, ... }:

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

  sops = {
    secrets.anthrophic_api_key = { };
    secrets.mistral_api_key = { };
    secrets.openrouter_api_key = { };
  };

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
        ed    = ''nvim -d'';
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
      gfa     = "git fetch --all";
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
      gapp    = "git apply -p0";
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
      c4c = ''TABLE='s3://cgx-eng-env-coralogix-euprod2-data/cx/parquet/v1/team_id=4000017' \
        dpctl query \
        --path $TABLE \
        # --query-server http://api-sandbox-dataprime-query-engine.default.svc.cluster.local:8080 \
        --start 2025-09-10:00:00:00 --end 2025-09-12:00:00:00 \
        # --from-file ../wip/query_sampling_rum_aggregations.dql \
        # --query "source logs "
        # --output stats \
        '';
    } // editor_abbrevations;
    shellAliases = {
      cdp     = "cd $PROJECT_DIR";
      gcm  = "git rev-parse --verify main && git switch main || git switch master";
      tree = "eza -Tl --git";
      ls   = "eza --git";
      lt   = "ls -l --sort newest";
      l    = "ls -laF";
      ",c" = "clear; ${pkgs.tmux}/bin/tmux clear-history";
    };
    functions = {
      gdt.body   = ''nvim "+DiffviewOpen $argv"'';
      gdc.body   = ''nvim "+DiffviewOpen $argv[1]^1..$argv[1]"'';
      gdh.body   = ''nvim "+DiffviewOpen HEAD^1"'';
      epoch.body = "date --date=@$argv[1] --iso-8601=seconds -u";
      epochns.body = "date --date=@(echo $Rrgv[1] / 1000000000| bc) --iso-8601=seconds -u";
      ",rh"      = ''echo (echo "$argv[1] / 3600 * 3600" | bc)'';
      depochi    = ''date -u -d "$argv[1]" +%s'';
      depoch     = ''date -u -d (string replace ":" " " $argv[1]) +%s'';
      vw.body    = "nvim (which $argv)";
      rlfw.body  = "readlink -f (which $argv)";
      rlft.body  = "tmux setb (readlink -f $argv | tr -d '\n')";
      vrg.body   = "${editor} (rg -l --hidden $argv| fzf --multi)";
      vgf.body   = "${editor} (git ls-files | fzf)";
      vgr.body   = "${editor} (git ls-files (git root) | fzf)";
      rcd.body   = "tmux rename-window (basename (git root 2>/dev/null && echo (git root) || echo (pwd)))";
      k9d.body   = ''kubectl config get-contexts -o name | fzf --query "$argv[1]" -1 | xargs k9s -c deploy --context'';
      k9p.body   = ''kubectl config get-contexts -o name | fzf --query "$argv[1]" -1 | xargs k9s -c pods --context'';
      k9c.body   = ''kubectl config get-contexts -o name | fzf --query "$argv[1]" -1 | xargs kubectl config use-context'';
      unidle     = ''
        systemctl --user stop xidlehook.service
        sleep $argv;
        systemctl --user start xidlehook.service
      '';
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
      set -gx EDITOR ${editor}
      # this is picked up by vim.
      set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow --glob "!.git/*"'
      set fzf_fd_opts --hidden --exclude=.git # for fzf.fish
      set --global --export FZF_DEFAULT_OPTS '--cycle --layout=reverse --border --height=90% --preview-window=wrap --info=inline --pointer="▶" --marker="✗" --bind "?:toggle-preview"  --bind "ctrl-a:select-all"'
      # --bind "ctrl-y:execute-silent(echo {+} | xargs tmux setb)" --bind "ctrl-e:execute(echo {+} | xargs -o nvim)"
      # note that a later incarnation of this command overwrites everything, even unmentioned
      fzf_configure_bindings --git_status=\e\cg --git_log=\e\cl --directory=\co --processes=\e\cp
      bind --mode insert \cz fg
      set -gx ANTHROPIC_API_KEY (cat ${config.sops.secrets.anthrophic_api_key.path})
      set -gx MISTRAL_API_KEY (cat ${config.sops.secrets.mistral_api_key.path})
      set -gx OPENROUTER_KEY (cat ${config.sops.secrets.openrouter_api_key.path})
      set -gx OPENROUTER_API_KEY (cat ${config.sops.secrets.openrouter_api_key.path})

      set -gx LLM_USER_PATH "$HOME/projects/personal/llm"
      fish_add_path --move $HOME/.cargo/bin
      fish_add_path --move $HOME/bin
      '' + (if pkgs.stdenv.isDarwin then ''
        fish_add_path --move {$HOME}/go/bin
        fish_add_path --move {$HOME}/darwin/bin
        fish_add_path --move {$HOME}/src/github/coralogix/scripts
        for p in (string split " " $NIX_PROFILES)
          fish_add_path --prepend --move $p/bin
        end
        /opt/homebrew/bin/brew shellenv | source
        # under test
        /usr/bin/ssh-add --apple-use-keychain ~/.ssh/coralogix-github
      '' else ''
        set PROJECT (${pkgs.wmctrl}/bin/wmctrl -d | grep '\*' | cut -b 33- | cut -f 1 -d_)
        set PROJECT_DIR ~/projects/$PROJECT
        fish_add_path {$HOME}/bin/linux
      '');
  };
}
