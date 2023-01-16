-- vim:fdm=marker
{-# LANGUAGE DeriveDataTypeable #-}

-- imports {{{
import XMonad
import XMonad.Operations
import qualified XMonad.StackSet as W
import XMonad.ManageHook
import qualified Data.Map as M
import qualified XMonad.Prompt as P
import XMonad.Prompt
import Data.List
import Data.Maybe (fromMaybe)
import Data.Ratio ((%))
import Text.Regex.Posix ((=~))

import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Util.NamedWindows
import XMonad.Util.Run
import XMonad.Util.Themes
import XMonad.Util.WindowProperties

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook hiding (args)
import XMonad.Prompt.Shell
import XMonad.Prompt.Theme
import XMonad.Prompt.Window
import XMonad.Prompt.Workspace

-- import XMonad.Layout.BoringWindows
import XMonad.Layout.Decoration
import XMonad.Layout.Combo
import XMonad.Layout.Groups.Helpers
-- import XMonad.Layout.Groups.Examples
import XMonad.Layout.IM
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.NoBorders
import XMonad.Layout.OneBig
import XMonad.Layout.PerWorkspace (onWorkspace)
import XMonad.Layout.Reflect -- (REFLECTX)
import XMonad.Layout.SimpleFloat
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation

import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS
import XMonad.Actions.FloatSnap
import XMonad.Actions.FloatKeys
import XMonad.Actions.GridSelect
import XMonad.Actions.GroupNavigation;
import XMonad.Actions.UpdatePointer
import XMonad.Actions.SpawnOn
import XMonad.Actions.TagWindows
import XMonad.Actions.TopicSpace hiding (topicAction)
import XMonad.Actions.WindowGo

-- imports from lib/
import ResizableTallGroup
import Tagging2
import Commands

-- }}}

-- basic config definitions {{{
myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount >> updatePointer (0.5, 0.5) (0, 0) >> historyHook
    where
      fadeAmount = 0.90

myTerminal :: String
myTerminal = "urxvt"

browser :: String
browser = "vimb"

myConfig = def { terminal    = myTerminal
               , startupHook = setWMName "LG3D"
               , workspaces  = myTopicNames
               , manageHook  = manageSpawn <+> manageDocks <+> myManageHook <+> namedScratchpadManageHook scratchpads
               , layoutHook  = myLayoutHook
               , logHook = myLogHook
               , modMask     = mod5Mask
               , borderWidth = 1
               , keys        = \c -> mkKeymap c $ ezKeys c
               , focusFollowsMouse  = False
               , normalBorderColor  = normalBorderColor'
               , focusedBorderColor = focusedBorderColor'
               } `additionalKeys` extraKeys

main = xmonad $ withUrgencyHook LibNotifyUrgencyHook $ myConfig

myTiledTabsConfig = def { tabsTheme = myTheme }

myLayoutHook = noBorders
        . smartSpacing 1
        . mkToggle (NOBORDERS ?? NBFULL ?? EOT)
        . mkToggle (single REFLECTX)
        . skypeWorkspace
        $ tiled
        where
            tiled   = tallTabs myTiledTabsConfig
            nmaster = 1
            ratio   = 3/5
            delta   = 5/100
            skypeLayout = withIM (1%7) skypeMainWindow tiled
            skypeMainWindow = And (ClassName "Skype") (Title  "dispanser - Skype™" )
            skypeWorkspace = onWorkspace "communication" skypeLayout

-- }}}

-- managehook: float around {{{
myManageHook :: ManageHook
myManageHook = composeAll [ role =? "vimperator" --> doRectFloat lowerRightCornerRect
                          , className =? "Skype" --> doShift "11:comm"
                          , title =? "xmessage" --> doRectFloat smallCenteredRect
                          , title =? "mutt" --> doShift "11:comm"
                          ]
    where role = stringProperty "WM_WINDOW_ROLE"

toggleFloat = withFocused (\windowId -> do
                              { floats <- gets (W.floating . windowset);
                                if windowId `M.member` floats
                                then withFocused $ windows . W.sink
                                else float windowId })

-- }}}
q ~? x = fmap (=~ x) q

-- topic spaces {{{
data TopicType = TopicType  { topicName    :: Topic
                            , topicDir     :: Dir
                            , topicAction  :: X()
                            }

xmonadT = TopicType { topicName = "xmonad", topicDir = "~/configs/xmonad/.xmonad", topicAction = spawnShell >*> 2 }
confT = TopicType { topicName = "conf", topicDir = "configs", topicAction = spawnShell >*> 2 }
dashboardT = TopicType { topicName = "dashboard", topicDir = "~", topicAction = spawnShell >*> 2 }
commT = TopicType { topicName = "communication", topicDir = "~",
                    topicAction = spawn "venom" >> spawn "urxvt -e mutt" >> spawn "skype" >>
                                  spawn (browserWindow "https://mymail.intershop.de https://twitter.com") }
-- scalaT = TopicType { topicName = "scala", topicDir = "/fs/data/projects/scala_functional_programming/", topicAction =
--  spawnShell >>
--  spawn browserWindow "https://class.coursera.org/progfun-005" }
plT = TopicType { topicName = "pl", topicDir = "/fs/data/projects/programming_languages",
                  topicAction = spawnShell >> spawn (browserWindow "https://class.coursera.org/proglang-003") }
readT = TopicType { topicName = "read", topicDir = "/fs/data/books/",
                    topicAction = spawn (browserWindow "https://getpocket.com") >> spawnShell }
blogT = TopicType { topicName = "blog", topicDir = "/fs/data/projects/blogging/",
                    topicAction = spawn (browserWindow "https://getpocket.com") >> spawnShell}
fpT = TopicType { topicName = "fp101x", topicDir = "/fs/data/projects/fp101x/",
                  topicAction = spawn (browserWindow "https://courses.edx.org/courses/DelftX/FP101x/3T2014/info")
                                >> spawnShell}
servicesT = TopicType { topicName = "services", topicDir = "~", topicAction = spawnShell}
tpT = TopicType { topicName = "thinkpad", topicDir = "/fs/data/projects/thinkpad", topicAction = spawnShell}

myTopics :: [TopicType]
myTopics = [dashboardT, commT, confT, xmonadT, readT, plT, blogT, fpT, servicesT, tpT]

-- }}}
-- topic space helpers {{{

myTopicNames :: [Topic]
myTopicNames = map topicName myTopics

myTopicConfig :: TopicConfig
myTopicConfig = def { topicDirs = myTopicDirs
                    , defaultTopicAction = const $ spawnShell >*> 3
                    , defaultTopic = head myTopicNames
                    , topicActions = myTopicActions
                    }
    where
      myTopicDirs :: M.Map Topic Dir
      myTopicDirs = M.fromList . zip myTopicNames $ map topicDir myTopics
      myTopicActions :: M.Map Topic (X())
      myTopicActions = M.fromList . zip myTopicNames $ map topicAction myTopics

spawnShell :: X ()
spawnShell = Main.currentTopicDir myTopicConfig >>= spawnShellIn
-- | Returns the directory associated with current topic returns the empty string otherwise.
currentTopicDir :: TopicConfig -> X Dir
currentTopicDir tg = do
  topic <- gets (W.tag . W.workspace . W.current . windowset)
  let dir = fromMaybe "~" . M.lookup topic $ topicDirs tg
  return dir

spawnShellIn :: Dir -> X ()
spawnShellIn dir = spawn $ shellDirCommand dir

shellDirCommand :: String -> String
shellDirCommand "" = myTerminal
shellDirCommand dir = term ["-cd", absDir]
    where
      absDir = mkAbsDir dir

term :: [String] -> String
term args = buildCommand myTerminal args

buildCommand :: String -> [String] -> String
buildCommand cmd args = foldl (++) [] $ cmd:map (' ':) args


gotoTopic :: Topic -> X ()
gotoTopic = switchTopic myTopicConfig

promptedGoto :: X ()
promptedGoto = workspacePrompt myXPConfig gotoTopic

promptedShift :: X ()
promptedShift = workspacePrompt myXPConfig $ windows . W.shift

-- }}}

-- float rects {{{
clockRect = W.RationalRect (14/16) 0 (2/16) (2/9)
centeredRect = W.RationalRect 0.2 0.2 0.6 0.6
smallCenteredRect = W.RationalRect 0.4 0.4 0.2 0.2
lowerRightCornerRect = W.RationalRect 0.6 0.6 0.4 0.4
upperRightCornerRect = W.RationalRect 0.5 0.0 0.5 0.4
rightSideBarRect = W.RationalRect 0.6 0.0 0.4 1.0
leftSideBarRect = W.RationalRect 0.0 0.0 0.4 1.0
upperBarRect = W.RationalRect 0.0 0.0 1.0 0.5
-- }}}
-- scratchpads {{{
scratchpads =
    [ NS "htop" "urxvt -e htop" (title =? "htop") (customFloating $ centeredRect )
    , NS "vim_cc" "urxvt -fn 'xft:Inconsolata:pixelsize=20' -e vim_cc" (title =? "vim_cc") (customFloating $ lowerRightCornerRect )
    , NS "logs" "urxvt -name light -fn 'xft:Inconsolata:pixelsize=16' -e logs" (title =? "logs") (customFloating $ upperRightCornerRect )
    , NS "clock" "xclock" (title =? "xclock") (customFloating $ clockRect)
    , NS "ghci" "urxvt -fn 'xft:Inconsolata:pixelsize=20' -e ghci" (title =? "ghci") $ customFloating centeredRect] ++
    concat [ topicBasedScratchpads t | t <- myTopics ]
        where
          role = stringProperty "WM_WINDOW_ROLE"
-- }}}
-- scratchpad helpers {{{
-- data Direction = N | NE | E | SE | S | SW | W | NW deriving (Read, Show, Eq)
data WindowDirection = North | East | West | Centre deriving (Read, Show, Eq, Enum)

-- map window location to some predefined rectangle.
windowLocation :: WindowDirection -> W.RationalRect
windowLocation North = upperBarRect
windowLocation West  = leftSideBarRect
windowLocation East  = rightSideBarRect
windowLocation Centre= centeredRect

browserWindow :: String -> String
browserWindow = chromiumWindow

chromiumWindow = ("chromium --new-window " ++)
firefoxWindow = ("firefox -new-window " ++)

-- defines scratchpads common to all topics: terminal overlays + todo + notes.
topicBasedScratchpads :: TopicType -> [NamedScratchpad]
topicBasedScratchpads topic = [leftScratch, rightScratch, todoScratch, notesScratch]
    where
      leftScratch  = scratchTerm "left" topic West
      rightScratch = scratchTerm "right" topic East
      todoScratch  = todoTerm topic
      notesScratch = notesOverlay topic

-- given a topic and a direction, create a scratch pad with a termainal at the given location.
topicTerm :: String -> TopicType -> WindowDirection -> Maybe String -> NamedScratchpad
topicTerm tag topic dir cmd = namedScratchPad (termName term) term $ windowLocation dir
    where
      term = Term { termDir = Just $ topicDir topic
                  , termName = scratchName tag $ topicName topic
                  , termCmd = cmd
                  }

scratchTerm :: String -> TopicType -> WindowDirection -> NamedScratchpad
scratchTerm tag topic dir  = topicTerm tag topic dir Nothing

todoTerm :: TopicType -> NamedScratchpad
todoTerm topic = topicTerm "todo" topic Centre cmd
    where
      td  = topicDir topic
      cmd = Just $ "todotxt-machine " ++ td ++ "/todo.txt"

notesOverlay :: TopicType -> NamedScratchpad
notesOverlay topic = namedScratchPad sn vi $ windowLocation Centre
    where
      tn = topicName topic
      td = topicDir topic
      sn = scratchName "notes" tn
      vi = GVim { vimDir   = td
                , vimFiles = []
                , vimRole  = sn
                , vimArgs  = Nothing
                }

namedScratchPad :: (IdentifiableCommand a) => String -> a -> W.RationalRect -> NamedScratchpad
namedScratchPad name cmd rect = NS name (command cmd) (Commands.query cmd) $ customFloating rect

termWithNameAndDir :: String -> String -> String
termWithNameAndDir name dir = concat [myTerminal, " -name ", name, " -cd ", dir]

loadWorkspaceScratchpad :: String -> X()
loadWorkspaceScratchpad tag = do
  ws <- gets (W.currentTag . windowset)
  namedScratchpadAction scratchpads $ scratchName tag ws

scratchName :: String -> WorkspaceId -> String
scratchName tag ws = "_sp_" ++ ws ++ "_" ++ tag

-- }}}

-- keys {{{
-- required because I'm unable to express comma / period with ezconfig
extraKeys = [((mod5Mask, xK_period), focusUrgent)]

ezKeys conf =
    [
    -- unsorted
    ("M-t", spawnShell)
    , ("M-S-t", spawn $ myTerminal ++ " -name light" )
    , ("M-S-w", spawnHere browser )
    , ("M-b", shellPromptHere myXPConfig)
    , ("M-S-b", windowPromptGoto myXPConfig)
    , ("M-M1-S-r", restart "xmonad" True)
    , ("M-o", nextMatch History (return True))
    , ("M-S-c", kill1)

    , ("M-z", decreaseNMasterGroups)
    , ("M-x", increaseNMasterGroups)

    , ("M-S-d", moveToGroupDown True)
    , ("M-S-u", moveToGroupUp True)
    , ("M-C-p", moveToNewGroupUp)
    , ("M-C-n", moveToNewGroupDown)

    -- focus changes inside the inner layout
    , ("M-n", focusUp)
    , ("M-p", focusDown)

    -- focus changes / moves between groups
    , ("M-u", focusGroupUp)
    , ("M-d", focusGroupDown)
    , ("M-<Return>", focusGroupMaster)
    , ("M-C-u", swapGroupUp)
    , ("M-C-d", swapGroupDown)
    , ("M-C-<Return>", swapGroupMaster)

    -- resizing master pane
    , ("M-S-h", shrinkMasterGroups)
    , ("M-S-l", expandMasterGroups)

    , ("M-S-g", goToSelected def)

    -- topic prompts
    -- , ("M-v", currentTopicAction myTopicConfig)
    , ("M-S-v", promptedGoto)
    , ("M-C-v", promptedShift)
    -- focussing specific apps
    -- (ClassName "Skype") `And` (Not (Title "Options")) `And` (Not (Role "Chats")) `And` (Not (Role "CallWindow
    -- , (("M-S-w"), runOrRaiseNext "firefox" (className =? "Firefox"))
    , ("M-S-k", runOrRaiseNext "kepler" (className =? "Eclipse"))
    -- , (("M-S-s"), runOrCopy "skype" (className =? "Skype" <&&> role =? "ConversationsWindow"))
    -- , [ className =? "Skype" -?> doRectFloat skypeChatRect ]
    -- , (("M-S-m"), raiseMaybe (runInTerm "-title mutt" "mutt") (title =? "mutt"))

    -- layouts: toggles + switches
    -- , ("M-space", sendMessage NextLayout)
    , ("M-f", sendMessage $ Toggle NBFULL)
    -- , ("M-C-<Space>", sendMessage $ Toggle REFLECTX)

    -- next / previous workspace + movement
    , (("M-e"), nextScreen)
    , (("M-S-e"), shiftNextScreen)
    , (("M-w"), prevScreen)
    -- , (("M-S-w"), shiftPrevScreen)
    , (("M-r"), toggleWS' ["NSP"])

    -- floating window handling: movements + sinking
    , (("M-M1-s"), toggleFloat)
    , (("M1-C-<Left>" ), withFocused $ keysResizeWindow (-50, 0) (0, 0))
    , (("M1-C-<Right>"), withFocused $ keysResizeWindow (50, 0) (0, 0))
    , (("M1-C-<Up>"   ), withFocused $ keysResizeWindow (0, -50) (0, 0))
    , (("M1-C-<Down>" ), withFocused $ keysResizeWindow (0, 50) (0, 0))
    -- , (("M1-C-<Left>" ), withFocused $ snapShrink R Nothing)
    -- , (("M1-C-<Right>"), withFocused $ snapGrow R Nothing)
    -- , (("M1-C-<Up>"   ), withFocused $ snapShrink D Nothing)
    -- , (("M1-C-<Down>" ), withFocused $ snapGrow D Nothing)
    , (("M1-S-<Left>" ), withFocused $ snapMove L Nothing)
    , (("M1-S-<Right>"), withFocused $ snapMove R Nothing)
    , (("M1-S-<Up>"   ), withFocused $ snapMove U Nothing)
    , (("M1-S-<Down>" ), withFocused $ snapMove D Nothing)

    -- default scratchpads
    , (("M-M1-S-p"), namedScratchpadAction scratchpads "htop")
    , (("M-M1-S-v"), namedScratchpadAction scratchpads "vim_cc")
    , (("M-M1-S-o"), namedScratchpadAction scratchpads "ghci")
    , (("M-M1-S-m"), namedScratchpadAction scratchpads "notes")
    , (("M-M1-S-l"), namedScratchpadAction scratchpads "logs")
    , (("M-M1-S-c"), namedScratchpadAction scratchpads "clock")
    , (("M-M1-S-t"), namedScratchpadAction scratchpads "todo")
    , (("M-<Space>"), loadWorkspaceScratchpad "right")
    , (("M-S-<Space>"), loadWorkspaceScratchpad "left")
    , (("M-M1-t"), loadWorkspaceScratchpad "todo")
    , (("M-M1-m"), loadWorkspaceScratchpad "notes")

    -- rotate inside a tag group
    , (("M-j"), withFocused focusCurrentTagUp)
    , (("M-k"), withFocused focusCurrentTagDown)

    -- jump to selected topics directly
    , (("M-v x"), gotoTopic "xmonad")
    , (("M-v t"), gotoTopic "thinkpad")
    , (("M-v c"), gotoTopic "communication")
    , (("M-v i"), gotoTopic "ish_main")
    , (("M-v j"), gotoTopic "ish_side")
    , (("M-v d"), gotoTopic "dashboard")
    , (("M-v r"), gotoTopic "read")
    , (("M-v s"), gotoTopic "scala")
    , (("M-v p"), gotoTopic "pl")
    , (("M-v f"), gotoTopic "fp101x")
    , (("M-v b"), gotoTopic "blog")
    , (("M-v 0"), gotoTopic "services")
    ]
    ++
    -- these tags are meant to be assigned to a single window,
    -- but of course it's possible to assign the same to 2-3 windows
    -- and rotate via M-j / M-k.
    -- use M-0 .. M-9 to jump to a tag,
    -- M-S-[0..9] to set a tag
    [(("M-" ++ [d]), focusUpTaggedGlobal (show d)) | d <- digits]
    ++
    [(("M-S-" ++ [d]), withFocused $ setTags $ [show d]) | d <- digits]
    ++
    [(("M-C-0"), withFocused $ unTag)]
    --jumping to tags: a..z with M-g <char>
    -- [
    -- (("M-g " ++ [k]), focusUpTaggedGlobal (show k)) | k <- tags
    -- ]
    -- ++
    -- [
    -- -- assigning tags: a..z with M-a <char>
    -- (("M-m " ++ [k]), withFocused $ setTags $ [show k]) | k <- tags
    -- ]
    -- ++
    -- [ (("M-" ++ [k]), switchNthLastFocused myTopicConfig i)
    -- | (i, k) <- zip [1..] ['1'..'9'] ]
    -- [ ((modm, k), switchNthLastFocused myTopicConfig i)
    --  | (i, k) <- zip [1..] workspaceKeys]
        where
          digits = ['0'..'9']
-- }}}

-- prompt theme {{{
-- some solarized colors for the command prompt
myXPConfig = def
    { font  = xftFont
        , fgColor = (M.findWithDefault "" "blue" solarized)
        , bgColor = (M.findWithDefault "" "base02" solarized)
        , bgHLight = (M.findWithDefault "" "base02" solarized)
        , fgHLight = (M.findWithDefault "" "yellow" solarized)
        , position = Bottom
        , height = 22
        , historySize = 512
        , showCompletionOnTab = True
        , historyFilter = deleteConsecutive
    }
-- }}}

-- tags config {{{
tags :: [Char]
tags = ['a'..'z']
-- }}}
-- tag config helpers {{{
-- extract current tag, and use it to call focusUpTaggedGlobal
focusCurrentTagUp :: Window -> X()
focusCurrentTagUp w = executeOnTag w focusGroupUp focusUpTaggedGlobal'

focusCurrentTagDown :: Window -> X()
focusCurrentTagDown w = executeOnTag w focusGroupDown focusDownTaggedGlobal'

-- execute something on existence of tags, something else otherwise
executeOnTag :: Window -> X() -> ([String] -> X()) -> X()
executeOnTag w fnotags ftags= do
  tags <- getTags w
  case tags of
    [] -> fnotags
    _  -> ftags tags

-- }}}

-- color definitions {{{
-- solarized colors
solarized :: M.Map String String
solarized = M.fromList [
    ("base03",   "#002b36"),
    ("base02",   "#073642"),
    ("base01",   "#586e75"),
    ("base00",   "#657b83"),
    ("base0",    "#839496"),
    ("base1",    "#93a1a1"),
    ("base2",    "#eee8d5"),
    ("base3",    "#fdf6e3"),
    ("yellow",   "#b58900"),
    ("orange",   "#cb4b16"),
    ("red",      "#dc322f"),
    ("magenta",  "#d33682"),
    ("violet",   "#6c71c4"),
    ("blue",     "#268bd2"),
    ("cyan",     "#2aa198"),
    ("green",    "#859900")]

normalBorderColor', focusedBorderColor' :: String
normalBorderColor'  =  M.findWithDefault "" "base0" solarized
focusedBorderColor' =  M.findWithDefault "" "yellow" solarized
-- }}}

-- tab theme {{{
xftFont = "xft: inconsolata-10"

myTheme =
    Theme { activeColor       = base03
          , inactiveColor       = base03
          , urgentColor         = base03
          , activeBorderColor   = yellow
          , inactiveBorderColor = base0
          , urgentBorderColor   = red
          , activeTextColor     = yellow
          , inactiveTextColor   = base0
          , urgentTextColor     = red
          , fontName            = xftFont
          , decoWidth           = 200
          , decoHeight          = 20
          , windowTitleAddons   = []
          , windowTitleIcons    = []
          }
                where
                    base03  = "#002b36"
                    base02  = "#073642"
                    base01  = "#586e75"
                    base00  = "#657b83"
                    base0   = "#839496"
                    base1   = "#93a1a1"
                    base2   = "#eee8d5"
                    base3   = "#fdf6e3"
                    yellow  = "#b58900"
                    orange  = "#cb4b16"
                    red     = "#dc322f"
                    magenta = "#d33682"
                    violet  = "#6c71c4"
                    blue    = "#268bd2"
                    cyan    = "#2aa198"
                    green   = "#859900"
-- }}}

-- urgency hook {{{
-- notify-send: copied from http://pbrisbin.com/posts/using_notify_osd_for_xmonad_notifications/
data LibNotifyUrgencyHook = LibNotifyUrgencyHook deriving (Read, Show)

instance UrgencyHook LibNotifyUrgencyHook where
    urgencyHook LibNotifyUrgencyHook w = do
        name     <- getName w
        Just idx <- fmap (W.findTag w) $ gets windowset
        notify (show name) $ Just $ "workspace " ++ idx

notify :: String -> Maybe String -> X()
notify summary body = safeSpawn "notify-send" [summary, fromMaybe "" body]

message :: [String] -> X()
message msgs = do let msg = separateWith "\n" msgs
                  spawn $ "echo -e " ++ msg ++ " | xmessage -file -"
-- }}}
