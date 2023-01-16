{-# LANGUAGE RecordWildCards #-}

module PiMonad.Scratches ( fromScratchOrFocus
                         , triggerScratch
                         , globalKitty
                         , globalTmux
                         , globalScratch
                         , localTmux
                         , term
                         , tmux
                         , tmuxTerm
                         , startsWith
                         , endsWith
                         , contains
                         , projectBrowser'
                         , projectChromium
                         , projectFirefox
                         , ScratchApp (..)
                         )
where

import           Data.List                      (isPrefixOf, isSuffixOf, isInfixOf)
import           PiMonad.Workspaces             (getMainWorkspace, getWorkspaceName)
import           System.FilePath.Posix          ((</>))
import           XMonad
import           XMonad.Actions.DynamicProjects (Project (..), currentProject)
import           XMonad.Actions.WindowGo        (ifWindow)
import           XMonad.Hooks.ManageHelpers     (doRectFloat)
import qualified XMonad.StackSet                as W

data ScratchApp  = ScratchApp
        { commandF :: Project -> String
        , queryF   :: Project -> Query Bool
        , hook     :: Maybe ManageHook
        }

term :: String -> String -> String
term shellCommand cn  =
  "kitty --name " ++ cn ++ " -e " ++ shellCommand

tmux :: String -> String
tmux session = " sh -c \"tmux attach -t " ++ session ++ " || tmux new-session -s " ++ session ++ "\""

tmuxTerm :: String -> String -> String
tmuxTerm shellCommand = term (tmux shellCommand)

globalScratch :: String -> Query Bool -> W.RationalRect -> ScratchApp
globalScratch command query rect = ScratchApp {
    commandF = const command,
    queryF   = const query,
    hook     = Just (query --> doRectFloat rect)
}

globalKitty :: String -> W.RationalRect -> ScratchApp
globalKitty shellCommand = globalScratch command query
  where
    name'   = filter (/= ' ') shellCommand
    command = term shellCommand name'
    query   = appName =? name'

globalTmux :: String -> W.RationalRect -> ScratchApp
globalTmux shellCommand = globalScratch command query
  where
    name'   = filter (/= ' ') shellCommand
    command = term (tmux shellCommand) name'
    query   = appName =? name'

localTmux :: String -> W.RationalRect -> ScratchApp
localTmux suffix rect =
  let session pr =  getMainWorkspace (projectName pr) ++ "_" ++ suffix
  in ScratchApp {
      commandF = \pr -> term (tmux $ session pr) (session pr),
      queryF   = \pr -> appName =? session pr,
      hook     = Nothing
     }

-- query that checks if the provided query ends with the given sequence.
endsWith :: Eq a => Query [a] -> [a] -> Query Bool
endsWith q suffix = isSuffixOf suffix <$> q

-- query that checks if the provided query starts with the given sequence.
startsWith :: Eq a => Query [a] -> [a] -> Query Bool
startsWith q prefix = isPrefixOf prefix <$> q

contains :: Eq a => Query [a] -> [a] -> Query Bool
contains q substring = isInfixOf substring <$> q

triggerScratch :: ScratchApp -> X ()
triggerScratch ScratchApp { .. } = withWindowSet $ \ws -> do
  pr <- currentProject
  let command = commandF pr
  let query   = queryF   pr
  let focused = W.peek ws
  let windowQuery = fromScratchOrFocus query (W.currentTag ws) command
  case focused of
    Just w -> do
      matches <- runQuery query w
      if matches
        then toScratch
        else windowQuery
    Nothing -> windowQuery

-- if the windows' workspace is visible, go there and focus
-- otherwise, bring to current workspace and focus
showOrBring :: WorkspaceId -> ManageHook
showOrBring i = do
  w <- ask
  doF $ showOrBringWindow i w

-- showOrBringWindow :: WorkspaceId -> Window -> W.StackSet -> ManageHook
showOrBringWindow i w ss =
    let (Just currentWS) = W.findTag w ss
        visibleWS = W.tag . W.workspace <$> W.visible ss
    in if currentWS `elem` visibleWS -- the window is visible elsewhere
          then W.focusWindow w $ W.view i ss
          else W.focusWindow w $ W.shiftWin i w ss

toScratch :: X ()
toScratch = windows $ W.shift "NSP"

-- find a window using the given query, focus it on the current workspace or
-- on another, visible workspace. If it doesn't exist, run the command instead.
fromScratchOrFocus :: Query Bool -> WorkspaceId -> String -> X ()
fromScratchOrFocus q i c = ifWindow q (showOrBring i) (spawn c)

projectBrowser' :: ScratchApp
projectBrowser' =
   let command pr = "qutebrowser --qt-arg name " ++ getWorkspaceName  pr ++ " --target window --basedir " ++ (projectDirectory pr </> ".qute")
   in ScratchApp {
     commandF = command,
     queryF   = \pr -> appName =? getWorkspaceName pr,
     hook     = Nothing
   }

projectChromium :: ScratchApp
projectChromium =
   let localName pr = getWorkspaceName pr ++ "_chr"
       command pr = "chromium --class=" ++ localName pr ++
        " --user-data-dir=" ++ (projectDirectory pr </> ".chromium")
   in ScratchApp {
     commandF = command,
     queryF   = \pr -> className =? localName pr,
     hook     = Nothing
   }

-- firefox -P Test --class firefox_test
projectFirefox :: ScratchApp
projectFirefox =
   let localName pr = "firefox_" <> getWorkspaceName pr
       command pr = "firefox -P " <> (getWorkspaceName pr) <> " --class " <>
           (localName pr) <> " --profile " <> (projectDirectory pr </> ".firefox")
   in ScratchApp {
     commandF = command,
     queryF   = \pr -> className =? localName pr,
     hook     = Nothing
   }


