// aligned configuration. default bindings of one browser are intentionally left blank
// to keep the alignmend straight
// config.load_autoconfig()

api.map('J', 'd')
api.map('K', 'u')
api.map('<Ctrl-Space>', '<Ctrl-6>')
api.map('>', '>>')
api.map('<', '<<')
// config.bind("x", "tab-close")
// config.bind("X", "undo")

// config.bind(",RR", "config-source")
// config.bind("go", "set-cmd-text -s :open")
// config.bind("t", "set-cmd-text -s :open -t")
api.map('gt', 'T')
api.map('T', ';u')
api.map('O', ';U')
api.map('F', 'af')
api.map(',d', 'x')
api.map('<Ctrl-h>', 'S')
api.map('<Ctrl-l>', 'D')

// config.bind("gh", "open -t qute://history/")
// config.bind("gb", "open -t qute://bookmarks/")

// config.bind("ya", "hint links yank")
// omnibar mappings: Ctrl-N doesn't work because Ctrl-N is captured by chromium
api.cmap('<Alt-j>', '<Shift-Tab>');
api.cmap('<Alt-k>', '<Tab>');
api.map('<Alt-j>', 'E');
api.map('<Alt-k>', 'R');

// // scrolling: note that this is a half-page, so f / b are not correct
//api.map('<Ctrl-b>', 'e')
//api.map('<Ctrl-d>', 'd')
//api.map('<Ctrl-u>', 'e')


//api.map('T', ';u')

//api.map('<Ctrl-o>', 'S')
//api.map('<Ctrl-i>', 'D')
//api.map('<Ctrl-o>', 'S')
//api.map('<Ctrl-i>', 'D')

api.addSearchAlias('dc', 'dremio confluence', 'https://dremio.atlassian.net/wiki/search?text=');
api.addSearchAlias('hp', 'heise preisvergleich', 'http://www.heise.de/preisvergleich/?in=&x=0&y=0&fs=');
api.addSearchAlias('ad', 'amazon deu', 'http://smile.amazon.de/s/ref=nb_sb_noss?__mk_de_DE=%C3%85M%C3%85%C5%BD%C3%95%C3%91&url=search-alias%3Daps&field-keywords=');
api.addSearchAlias('ed', 'ebay deu', 'https://www.ebay.de/sch/i.html?_from=R40&_trksid=p2380057.m570.l1313&_sacat=0&_nkw=');
api.addSearchAlias('map', 'open streetmap', 'https://www.openstreetmap.org/search?query=');
api.addSearchAlias('gmap', 'google maps', 'https://www.google.de/maps/search/');
api.addSearchAlias('gh', 'github', 'https://github.com/');
api.addSearchAlias('aur', 'arch user repo', 'https://aur.archlinux.org/packages/?O=0&SeB=nd&outdated=&SB=n&SO=a&PP=50&do_Search=Go&K=');
api.addSearchAlias('hg', 'hoogle', 'https://hoogle.haskell.org/?hoogle=');
api.addSearchAlias('cg', 'cppref', 'https://duckduckgo.com/?sites=cppreference.com&ia=web&q=');
api.addSearchAlias('crate', 'crates.io', 'https://crates.io/search?q={}');
api.addSearchAlias('rd', 'rust docs', 'https://doc.rust-lang.org/std/option/enum.Option.html?search=');
api.addSearchAlias('hack', 'hackage', 'https://hackage.haskell.org/package/');
api.addSearchAlias('id', 'idealo', 'https://www.idealo.de/preisvergleich/MainSearchProductCategory.html?q=');
api.addSearchAlias('leo', 'dict', 'http://dict.leo.org/ende?search=');
// api.addSearchAlias('dhl', 'dhl paket', 'https://nolp.dhl.de/nextt-online-public/set_identcodes.do?lang=en&rfn=&extendedSearch=true&idc=');
api.addSearchAlias('dhl', 'dhl paket', 'https://www.dhl.de/en/privatkunden/pakete-empfangen/verfolgen.html?piececode=');
api.addSearchAlias('no', 'nixos options', 'https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=');
api.addSearchAlias('yt', 'youtube', 'https://www.youtube.com/results?search_query=');
api.addSearchAlias('sd', 'scala docs', 'http://www.scala-lang.org/api/current/scala/collection/immutable/List.html?search=');

settings.tabsThreshold = 3;
settings.defaultSearchEngine = 'd';
settings.focusFirstCandidate = true;

// set theme
settings.theme = `
.sk_theme {
    font-family: Input Sans Condensed, Charcoal, sans-serif;
    font-size: 16pt;
    background: #24272e;
    color: #abb2bf;
}
.sk_theme tbody {
    color: #fff;
}
.sk_theme input {
    color: #d0d0d0;
}
.sk_theme .url {
    color: #61afef;
}
.sk_theme .annotation {
    color: #56b6c2;
}
.sk_theme .omnibar_highlight {
    color: #528bff;
}
.sk_theme .omnibar_timestamp {
    color: #e5c07b;
}
.sk_theme .omnibar_visitcount {
    color: #98c379;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
    background: #303030;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
    background: #3e4452;
}
#sk_status, #sk_find {
    font-size: 36pt;
}`;

