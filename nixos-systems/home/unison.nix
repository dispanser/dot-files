{ lib, pkgs, isServer, ... }:

{
  services.unison =
    let
      # ~/.pi/agent is a symlink into this project dir, so pi's agent state
      # physically lives inside the synced tree and must be addressed here.
      piAgent = "projects/coralogix/src/agentic/pi";
      ignores = [
      "Name *.o"
      "Name *.hi"
      "Name xmonad-x86_64-linux"
      "Name *.class"
      "Name *.jar"
      "Name .password-store/.git"
      "Name personal/diary/.git"
      "Name src/github/dispanser/dot-files"
      "Name src/github/dispanser/partition-index/.git"
      "Name target"
      "Name targets"
      "Name build"
      "Name debug"
      "Name .gradle"
      "Name .cache"
      "Name .chromium"
      "Name .stack-work"
      "Name .qute/cache"
      "Name .qute/data"
      "Name .qute/runtime"
      "Name *.log"
      "Name .direnv"
      "Name .devenv"
      "Name _internal.abi3.so"
      "Name __pycache__"
      "Name src/github/NixOS"
      "Name .local"

      # pi: per-machine caches and scratch state, never portable.
      "Name ${piAgent}/tmp"
      "Name ${piAgent}/mcp-cache.json"
      "Name ${piAgent}/web-search-cache"

      # git: derived caches. Git regenerates these on demand; syncing them can
      # leave one side with a chain/MIDX referencing a file that only exists on
      # the other side (e.g. "warning: unable to find all commit-graph files").
      "Name .git/objects/info/commit-graph"
      "Name .git/objects/info/commit-graphs"
      "Name .git/objects/info/multi-pack-index"
      "Name .git/objects/info/multi-pack-index-*"
      "Name .git/objects/pack/multi-pack-index"
      "Name .git/objects/pack/multi-pack-index-*"

      # git: transient locks and per-machine refs.
      "Name .git/*.lock"
      "Name .git/FETCH_HEAD"
      "Name .git/ORIG_HEAD"

      # git: mid-operation state — never sync a half-finished merge/rebase/etc.
      "Name .git/MERGE_HEAD"
      "Name .git/CHERRY_PICK_HEAD"
      "Name .git/REVERT_HEAD"
      "Name .git/REBASE_HEAD"
      "Name .git/AUTO_MERGE"
      "Name .git/BISECT_*"
      "Name .git/rebase-merge"
      "Name .git/rebase-apply"
      "Name .git/sequencer"

      # NOTE: .git/index is intentionally NOT ignored so `git status` is clean
      # on the other machine; core.checkStat=minimal (git.nix) keeps it stable
      # across OSes. If it ever churns, ignore it and run `git reset` on arrival.
    ];
    paths = [
      "projects"
      "src"
      ".password-store"
      ".mail"
    ];
    ssh_script = "${pkgs.writeShellScript "ssh_unison.sh" ''
      exec 2> /tmp/unison.err.log
      exec ${pkgs.openssh}/bin/ssh "$@"
    ''}";
  in {
    enable = lib.mkIf pkgs.stdenv.hostPlatform.isLinux true;
    pairs = {
      tiny_sync = {
        roots = [
          "/home/pi/"
          (if isServer then 
            "/home/data/sync/home/pi/"
          else
            "ssh://tiny//home/data/sync/home/pi/")
        ];
        commandOptions = {
          ignore = ignores;
          path = paths;
          prefer = "newer";
          auto = "true";
          batch = "true";
          log = "false";
          repeat = "watch";
          sshcmd = "${ssh_script}";
          ui = "text";
        };
      };
    };
  };
}
