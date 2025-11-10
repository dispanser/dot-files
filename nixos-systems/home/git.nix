{ pkgs, ... }:

{
  programs.gh.enable = true;

  programs.git = {
    enable    = true;

    settings = {
      user = {
        name  = "Thomas Peiselt";
        email = "pi@kulturguerilla.org";
      };
      alias = {
        dt          = "difftool";
        mt          = "mergetool";
        lsum        = "log -n 1 --pretty=format:'%s'";
        lmsg        = "log -n 1 --pretty=format:'%s%n%n%b'";
        sdt         = "!f(){ if [ -z $1 ]; then c='HEAD'; else c=$1; fi; git difftool -y $c~..$c; }; f";
        root        = "rev-parse --show-toplevel";
        pr-base-sha = "!gh api repos/:owner/:repo/pulls | jq -re --arg head $(git rev-parse HEAD) '.[] | select(.head.sha == $head).base.sha'";
        pr-rebase   = "!git rebase $(git merge-base $(git pr-base-sha) HEAD)";
      };
      core = {
        # sshCommand = "ssh -i ~/.ssh/id_ed25519_personal";
      };
      # user.signingkey = "0xF38D81D949BDD26C";
      diff.tool = "vimdiff";
      diff.noprefix = true;
      difftool.vimdiff.path = "nvim";
      pull.rebase = true;
      rebase.updateRefs = true;
      push.default = "current";
    };

    ignores = [
      "/target" "/.envrc" "/.direnv/" ".abbr" ".nvim.lua" "/.devenv/" "/.tp/"
    ];
  };
  programs.delta = {
    enable                 = true;
    options = {
      features               = "side-by-side line-numbers decorations";
      whitespace-error-style = "22 reverse";

      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-style              = "bold yellow ul";
        file-decoration-style   = "none";
      };
    };
  };
}

