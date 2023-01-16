module Debug.Debug (xebug) where

import XMonad

xebug :: String -> X ()
xebug msg = spawn $ "xmessage '" ++ msg ++ "' -default okay"
