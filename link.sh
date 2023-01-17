#/usr/bin/env fish
mkdir ~/.xmonad
ln -s (readlink -f xmonad-config/xmonad/xmonad.hs) ~/.xmonad/
ln -s (readlink -f xmonad-config/src) ~/.xmonad/lib
