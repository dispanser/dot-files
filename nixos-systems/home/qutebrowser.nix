{ pkgs, ... }:
{
  programs.qutebrowser = {
    enable = true;
    enableDefaultBindings = true; # Default
    extraConfig = ''
        config.unbind('<ctrl-p>')
        config.unbind('<ctrl-n>')
        config.unbind('d')
        config.unbind('d')
        '';
    searchEngines = {
      DEFAULT = "https://duckduckgo.com/?q={}";
      ad      = "http://smile.amazon.de/s/ref=nb_sb_noss?__mk_de_DE=%C3%85M%C3%85%C5%BD%C3%95%C3%91&url=search-alias%3Daps&field-keywords={}";
      aur     = "https://aur.archlinux.org/packages/?O=0&SeB=nd&K={}&outdated=&SB=n&SO=a&PP=50&do_Search=Go";
      ed      = "http://www.ebay.de/sch/i.html?_from=R40&_trksid=p2050601.m570.l1313.TR0.TRC0.H0.X%s&_nkw={}&_sacat=0";
      ek      = "http://ebay-kleinanzeigen.de/anzeigen/s-{}/k0";
      gg      = "https://duckduckgo.com/?q=!g {}";
      hg      = "https://hoogle.haskell.org/?hoogle={}";
      crate   = "https://crates.io/search?q={}";
      rg      = "https://doc.rust-lang.org/std/option/enum.Option.html?search={}";
      hack    = "https://hackage.haskell.org/package/{}";
      hs      = "https://hackage.haskell.org/packages/search?terms={}";
      id      = "https://www.idealo.de/preisvergleich/MainSearchProductCategory.html?q={}";
      hp      = "http://www.heise.de/preisvergleich/?fs={}&in=&x=0&y=0";
      leo     = "http://dict.leo.org/ende?search={}";
      cd      = "https://dictionary.cambridge.org/dictionary/english/{}";
      map     = "https://www.openstreetmap.org/search?query={}";
      gmap    = "https://www.google.de/maps/search/{}";
      mvn     = "http://search.maven.org/#search%7Cga%7C1%7C{}";
      osm     = "https://www.openstreetmap.org/search?query={}";
      sg      = "http://www.scala-lang.org/api/current/scala/collection/immutable/List.html?search={}";
      cg      = "https://duckduckgo.com/?sites=cppreference.com&ia=web&q={}";
      wd      = "http://de.wikipedia.org/w/index.php?search={}";
      we      = "http://en.wikipedia.org/w/index.php?search={}";
      yt      = "https://www.youtube.com/results?search_query={}";
      dhl     = "https://nolp.dhl.de/nextt-online-public/set_identcodes.do?lang=en&idc={}&rfn=&extendedSearch=true";
      gh      = "https://github.com/{}";
      red     = "https://www.google.com/search?hl=en&q=site%3Areddit.com%20{}";
      no      = "https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query={}";
      sc      = "https://app.shortcut.com/tenzir/story/{}";
    };
    settings = {
      tabs = {
        background = true;
        last_close = "close";
        show = "switching";
        select_on_remove = "last-used";
      };
      auto_save = {
        session = true;
        interval = 60000;
      };
      editor.command = [ "kitty" "--name" "browser-edit" "-e" "nvim" "{}" ];
      scrolling.smooth = true;
    };
    keyBindings = {
      normal = {
        "sp" = "set-cmd-text :open -t https://getpocket.com/edit?url={url}&tags=";
        "sr" = "open -t https://getpocket.com/edit?url={url}&tags=remarkable";
        "J" = "scroll-page 0 0.7";
        "K" = "scroll-page 0 -0.7";
        "<Ctrl-Space>" = "tab-focus last";
        ">" = "tab-move +";
        "<" = "tab-move -";
        "x" = "tab-close";
        "X" = "undo";
        "u" = "set-cmd-text :undo ";
        ",RR" = "config-source";
        "go" = "set-cmd-text -s :open";
        "t" = "set-cmd-text -s :open -t";
        "T" = "set-cmd-text :open -t {url:pretty}";
        "O" = "set-cmd-text :open {url:pretty}";
        "<Ctrl-o>" = "back";
        "<Ctrl-i>" = "forward";
        "gh" = "open -t qute://history/";
        "gb" = "open -t qute://bookmarks/";
        "ya" = "hint links yank";
        "<Alt-j>" = "tab-prev";
        "<Alt-k>" = "tab-next";
        "W" = "tab-give"; # creates a new window when no win-id given
        "<ctrl-=>" = "zoom-in";
        "<ctrl-->" = "zoom-out";
        ",d" = "tab-close";
        ",b" = "set content.blocking.method both";
        "%" = "scroll-to-perc";
      };
      insert = {
        "<Ctrl-Space>" = "tab-focus last";
        "<Alt-j>" = "tab-prev";
        "<Alt-k>" = "tab-next";
        # https://www.reddit.com/r/qutebrowser/comments/hcn2e5/what_are_your_favorite_custom_qutebrowser/
        # insert mode key bindings to simulate readline bindings
        "<Ctrl-h>" = "fake-key <Backspace>";
        "<Ctrl-a>" = "fake-key <Home>";
        "<Ctrl-e>" = "fake-key <End>";
        "<Ctrl-b>" = "fake-key <Left>";
        "<Mod1-b>" = "fake-key <Ctrl-Left>";
        "<Ctrl-f>" = "fake-key <Right>";
        "<Mod1-f>" = "fake-key <Ctrl-Right>";
        "<Ctrl-p>" = "fake-key <Up>";
        "<Ctrl-n>" = "fake-key <Down>";
        "<Mod1-d>" = "fake-key <Ctrl-Delete>";
        "<Ctrl-d>" = "fake-key <Delete>";
        "<Ctrl-w>" = "fake-key <Ctrl-Backspace>";
        "<Ctrl-u>" = "fake-key <Shift-Home><Delete>";
        "<Ctrl-k>" = "fake-key <Shift-End><Delete>";
        "<Ctrl-i>" = "edit-text";
      };

    };
    quickmarks = {
      gn = "https://github.com/notifications";
      gp = "https://github.com/pulls";
      gr = "https://github.com/pulls/review-requested";
    };
  };
}