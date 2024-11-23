import qualified XMonad.Layout.Groups                as G
import qualified XMonad.Layout.Groups.Helpers        as GH
import           XMonad.Prompt                       (XPConfig(..), XPPosition(CenteredAt),
                                                     defaultXPKeymap')
import qualified XMonad.Prompt.Pass                  as XP

-- regular
import           Data.Char                           (isAlpha)
import           Data.List                           (isSubsequenceOf)
import           Data.Maybe                          (catMaybes)
import qualified Data.Map                            as M
import           Data.Maybe                          (fromMaybe)

import           XMonad
import qualified XMonad.StackSet                     as W

import           XMonad.Actions.CycleWS              (nextScreen,
                                                      shiftNextScreen,
                                                      toggleWS')
import           XMonad.Actions.DynamicProjects      (changeProjectDirPrompt,
                                                      dynamicProjects,
                                                      shiftToProjectPrompt,
                                                      switchProjectPrompt)
import           XMonad.Actions.FloatKeys            (keysResizeWindow)
import           XMonad.Actions.FloatSnap            (Direction2D (..),
                                                      snapGrow, snapMove,
                                                      snapShrink)
import           XMonad.Actions.GridSelect           (bringSelected,
                                                      goToSelected)
import           XMonad.Actions.Promote              (promote)
import           XMonad.Actions.Submap               (submap)
import           XMonad.Actions.TagWindows           (addTag, delTag,
                                                      focusUpTagged, hasTag)
import           XMonad.Actions.UpdatePointer        (updatePointer)
import           XMonad.Actions.WindowGo             (raiseMaybe)


import           XMonad.Hooks.EwmhDesktops           (ewmh)
import           XMonad.Hooks.ManageHelpers          (doRectFloat)
import           XMonad.Hooks.ManageDocks            as MD
import           XMonad.Hooks.SetWMName              (setWMName)
import           XMonad.Hooks.UrgencyHook            (UrgencyHook(..), focusUrgent, withUrgencyHook)
-- import           XMonad.Hooks.RefocusLast            (refocusLastEventHook,
--                                                       refocusLastLogHook, shiftRL)

import           XMonad.Layout.Accordion             (Accordion (..))
import           XMonad.Layout.Decoration
import           XMonad.Layout.MultiToggle
import           XMonad.Layout.MultiToggle.Instances
import           XMonad.Layout.NoBorders             (noBorders)
import           XMonad.Layout.NoFrillsDecoration
import           XMonad.Layout.ResizableTile
import           XMonad.Layout.Simplest
import qualified XMonad.Layout.Spacing               as XS
import           XMonad.Layout.Tabbed
import           XMonad.Layout.WindowNavigation

import           XMonad.Util.NamedWindows            (getName)
import           XMonad.Util.Run                     (safeSpawn)
import qualified PiMonad.Scratches                   as S
import           PiMonad.Workspaces                  (getOtherWorkspace,
                                                      projectFile, projects,
                                                      shiftToOtherWorkspace,
                                                      toggleSideWorkspace)

type Tag = Char

myWorkspaces :: [WorkspaceId]
myWorkspaces = ["NSP"]

myTerminal, myBrowser, myEditor, myQute :: String
myBrowser  = "vimb"
myQute     = "qutebrowser --backend webengine --qt-arg name global_qute"
myEditor   = "emacsclient -c"
myTerminal = "alacritty"

-- for word-level edit operations, split at each non-alpha char
wordSeparator :: Char -> Bool
wordSeparator = not . isAlpha

-- TODO: when 0.16 hits, use sorter = FuzzyMatch.fuzzySort for prioritized search
-- result order. Also, could use FuzzyMatch.fuzzyMatch, which is a case-insensitive
-- variant of @isSubsequenceOf@
myPromptConfig :: XPConfig
myPromptConfig = def
    { font = myFont 24
    , bgColor = base03
    , fgColor = base1
    , fgHLight = yellow
    , bgHLight = base03
    , borderColor = base00
    , promptKeymap = defaultXPKeymap' wordSeparator
    , position    = CenteredAt (1/8) (3/4)
    , height = 32
    , maxComplRows = Just 16
    , searchPredicate = isSubsequenceOf
    }

-- list of scratchpads. Maybe the biggest downside compared to the NamedScratchpad
-- is the lack of a global scratchpad lookup place. We create top-level bindings
-- and reference them where needed.
journal, htop, confT, obsidian :: S.ScratchApp
journal     = S.globalScratchTerm "journalctl -xf" centeredRect
htop        = S.globalScratchTerm "htop" centeredRect
confT       = S.globalTmux  "config" leftBarRect
obsidian    = S.globalScratch "obsidian" (className =? "obsidian") centeredRect
anki        = S.globalScratch "anki" (className =? "Anki") centeredRect
chromium    = S.globalScratch "chromium" (className `S.contains` "hromium") leftBarRect
firefox     = S.globalScratch "firefox " (className =? "Navigator") leftBarRect
pavucontrol = S.globalScratch "pavucontrol" (className =? "Pavucontrol") smallCentered

-- this place is neecssary to have their hooks registered
-- hacky: we skip chromium, firefox so they don't get floated. there's a better
-- way, but not today.
scratches :: [S.ScratchApp]
scratches = [ journal, htop, confT, obsidian, pavucontrol, anki]

myManageHook :: ManageHook
myManageHook = composeAll (catMaybes $ S.hook <$> scratches)
  <+> composeAll
  [ title     =?           "xmessage"             --> doRectFloat centeredRect
  , appName   `S.endsWith`   "_overlay"           --> doRectFloat rightBarRect
  , appName   `S.endsWith`   "_scratch"           --> doRectFloat centeredRect
  , appName   `S.endsWith`   "_org"               --> doRectFloat centeredRect
  -- title: WM_NAME / _NET_WM_NAME
  , title      =?          "Slack Call Minipanel" --> doRectFloat (W.RationalRect (17/20) (9/10) (fullWidth / 5) (2*fullHeight / 18))
  , title `S.startsWith` "Slack"                  --> addTagHook "m"
  , title `S.startsWith` "Signal"                 --> addTagHook "m"
  , className =?           "Slack"                --> addTagHook "m"
  , className =?           "Onboard"              --> doRectFloat upperBarRect
  , className =?           "TelegramDesktop"      --> addTagHook "m"
  , className =?           "Franz"                --> addTagHook "m" >> doRectFloat centeredRect
  , className  =?          "Pinentry"             --> doRectFloat smallCentered
  , className =?           "Vimb"                 --> addTagHook "b"
  , className `S.startsWith` "firefox"            --> addTagHook "b"
  , appName   `S.contains` "hromium"              --> addTagHook "b"
  , className =?           "qutebrowser"          --> addTagHook "b"
  , className =?           "Emacs"                --> addTagHook "e"
  , className =?           "Gvim"                 --> addTagHook "v"
  , appName   =?           "browser-edit"         --> addTagHook "v"
  , className =?           "Apvlv"                --> addTagHook "v"
  , className =?           "Zathura"              --> addTagHook "v"
  , className =?           "jetbrains-idea-ce"    --> addTagHook "i"
  , className =?           "R_x11"                --> addTagHook "i"
  , className =?           "URxvt"                --> addTagHook "u"
  , className =?           "kitty"                --> addTagHook "u"
  , appName   =?           "Alacritty"            --> addTagHook "u"
  , className =?           "Spotify"              --> doRectFloat rightBarRect
  , appName   =?           "browser-edit"         --> doRectFloat lowerRightRect
  ]

role :: Query String
role = stringProperty "WM_WINDOW_ROLE"

-- add a tag to a window via ManageHook
addTagHook :: String -> ManageHook
addTagHook tag = do
  w <- ask
  liftX $ addTag tag w
  idHook

-- outdated: using the pidgin-window-merge plugin, no message window / contact list separation
isPidginContactList, isPidginMessageWindow, isPidginClass, isBuddy :: Query Bool
isPidginContactList   = isPidginClass <&&> isBuddy
isPidginMessageWindow = isPidginClass <&&> notQ isBuddy
isPidginClass = className =? "Pidgin"
isBuddy = title =? "Buddy List"

notQ :: Query Bool -> Query Bool
notQ q = not <$> q

x, y, gapSize, fullWidth, fullHeight, left, up :: Rational
x          = 1920
y          = 1080

gapSize    = 10
fullWidth  = ( x - 2*gapSize ) / x
fullHeight = ( y - 2*gapSize ) / y
left = gapSize / x
up   = gapSize / y

centeredRect, smallCentered, upperBarRect, rightBarRect, leftBarRect, contactBarRect, lowerRightRect :: W.RationalRect
centeredRect   = W.RationalRect 0.2 0.2 0.6 0.6
smallCentered  = W.RationalRect 0.35 0.4 0.3 0.2
upperBarRect   = W.RationalRect left up fullWidth (1 / 3)
rightBarRect   = W.RationalRect (1/2) up (fullWidth / 2) fullHeight
leftBarRect    = W.RationalRect left up (fullWidth / 2) fullHeight
contactBarRect = W.RationalRect 0.9 up 0.1 fullHeight
lowerRightRect = W.RationalRect (1/2) (1/2) (fullWidth / 2) (fullHeight / 2)

-- explicit list of tags
tags :: [Tag]
tags = [ 'b' -- browsers
       , 'e' -- editor / emacs (auto-assigned to emacs instances)
       , 'v' -- vim instance, pdf / document readers (d is already in use elsewhere)
       , 'x' -- assign freely, 'extended'
       , 'i' -- IDEs: idea, eclipse
       , 'u' -- urxvt / terminals
       , 'm' -- assigned to known messengers
       ]

keyToCode :: M.Map Char KeySym
keyToCode = M.fromList $ zip (['a' .. 'z'] ++ ['0' .. '9']) ([xK_a .. xK_z] ++ [xK_0 .. xK_9])

resizeStepSize :: Int
resizeStepSize = 120

myModMask, myShiftMask, myControlMask, myAltMask, tagToggleMask, workspaceMask :: ButtonMask
myModMask           = mod5Mask
myShiftMask         = myModMask .|. shiftMask
myControlMask       = myModMask .|. controlMask
myAltMask           = myModMask .|. mod1Mask
tagToggleMask       = myModMask .|. mod4Mask
workspaceMask       = myModMask

main :: IO ()
main = do
  ps <- projects
  xmonad $ MD.docks $ ewmh $ withUrgencyHook LibNotifyUrgencyHook $ dynamicProjects ps def
    { borderWidth        = 1
    , modMask            = myModMask
    , terminal           = myTerminal
    , workspaces         = myWorkspaces
    , layoutHook         = myLayoutHook
    , startupHook        = setWMName "LG3D"
    , manageHook         = myManageHook
    , logHook            = updatePointer (0.5, 0.5) (0, 0) -- <+> refocusLastLogHook
    , keys               = myKeys
    , normalBorderColor  = "#cccccc"
    , focusedBorderColor = "#cd8b00" }

myLayoutHook =
    noBorders
    . MD.avoidStruts
    . windowNavigation
    -- . trackFloating
    -- . useTransientFor
    . addTopBar
    . addTabs shrinkText myTabTheme
    . XS.spacingRaw True (XS.Border 10 10 10 10) True (XS.Border 10 10 10 10) True
    . mkToggle (FULL ?? MIRROR ?? EOT)
    $ groupLayout

  where
    groupLayout = (G.group innerLayout outerLayout)
    innerLayout = Simplest  ||| Accordion
    tallLayout    = ResizableTall nmaster resizeDelta masterRatio slaveRatios
    -- tallLayout    = Tall nmaster resizeDelta masterRatio
    -- subs          = subLayout [] innerLayout $ boringWindows outerLayout
    addTopBar     = noFrillsDeco shrinkText topBarTheme
    outerLayout   = tallLayout
    nmaster       = 1
    resizeDelta   = 5/100
    masterRatio   = 3/6
    -- -- the ratios seem to contain the master window in the computation. if first and
    -- -- second entry are identical, a third window will have size 0.
    -- -- the current setting makes the second window twice the size of the third (if there
    -- -- are only three)
    slaveRatios   = [1.6, 1.3]

-- submaps for less common window operations
windowSubmap :: M.Map ( ButtonMask, KeySym ) ( X () )
windowSubmap = M.fromList
  [ ( (0, xK_s),         withFocused $ windows . W.sink)
  , ( (0, xK_f),         withFocused float)
  , ( (0, xK_l),         sendMessage NextLayout)
  , ( (shiftMask, xK_l), sendMessage $ G.ToFocused $ SomeMessage NextLayout)
  , ( (0, xK_g),         sendMessage $ G.Modify G.splitGroup)
  , ( (0, xK_i),         sendMessage $ IncMasterN 1)
  , ( (0, xK_d),         sendMessage . IncMasterN $ -1)
  , ( (0, xK_k),         kill)
  , ( (0, xK_slash),     sendMessage $ Toggle MIRROR)
  ]

-- submap to trigger / start applications
appSubmap :: M.Map ( ButtonMask, KeySym ) ( X () )
appSubmap = M.fromList
  [ ( (0, xK_x), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi")
  , ( (0, xK_t), spawn myTerminal)
  , ( (0, xK_b), spawn myBrowser)
  , ( (0, xK_e), spawn myEditor)
  , ( (0, xK_v), spawn "gvim")
  , ( (0, xK_h), S.triggerScratch htop)
  , ( (0, xK_l), S.triggerScratch journal)
  ]

-- submaps for various prompt-based actions
promptSubmap :: M.Map ( ButtonMask, KeySym ) ( X () )
promptSubmap = M.fromList
  [ ( (0, xK_c), spawn "/home/pi/bin/browser-dmenu chromium")
  , ( (0, xK_f), spawn "/home/pi/bin/browser-dmenu firefox")
  , ( (0, xK_q), spawn "/home/pi/bin/browser-dmenu qutebrowser")
  , ( (0, xK_d), spawn "rofi -show run -theme solarized_alternate")
  , ( (0, xK_g), goToSelected def)
  , ( (0, xK_b), bringSelected def)
  , ( (0, xK_p), XP.passTypePrompt myPromptConfig)
  , ( (shiftMask, xK_p), XP.passPrompt myPromptConfig)
  ]

-- | toggle to previous workspace, skipping the workspace that is the associated
-- side (or main) workspace of the current workspace
toggleWSSkipSide :: [String] -> X()
toggleWSSkipSide ignores = do
  workspace <- gets (W.currentTag . windowset)
  let otherWS = getOtherWorkspace workspace
  toggleWS' $ otherWS:ignores

outerAction :: Message a => a -> X ()
outerAction = sendMessage . G.ToEnclosing . SomeMessage
-- sendMessage $ G.ToFocused $ SomeMessage NextLayout

myMainKeys :: [(( ButtonMask, KeySym ), X () )]
myMainKeys =
  [ ( (mod4Mask,                xK_t),         spawn myTerminal)
  , ( (myModMask,               xK_a),         submap appSubmap)
  , ( (myModMask,               xK_z),         submap promptSubmap)
  , ( (myModMask,               xK_w),         submap windowSubmap)
  , ( (myModMask,               xK_r),         toggleWSSkipSide ["NSP", "scratch"])
  , ( (myModMask,               xK_s),         nextScreen)
  , ( (myAltMask,               xK_c),         S.triggerScratch firefox)
  , ( (myControlMask,           xK_c),         S.triggerScratch chromium)
  , ( (myModMask,               xK_q),         S.triggerScratch confT)
  , ( (myModMask,               xK_f),         sendMessage $ Toggle FULL)
  , ( (myModMask,               xK_t),         workspaceTerm "term")
  , ( (myShiftMask,             xK_t),         workspaceTerm "term" >> promote)
  , ( (myModMask,               xK_slash),     focusUrgent)

  -- SubLayout: go / swap in the four directions
  , ( (myModMask,               xK_l),         sendMessage $ Go R)
  , ( (myModMask,               xK_h),         sendMessage $ Go L)
  , ( (myModMask,               xK_k),         sendMessage $ Go U)
  , ( (myModMask,               xK_j),         sendMessage $ Go D)
  , ( (myShiftMask,             xK_l),         sendMessage $ Swap R)
  , ( (myShiftMask,             xK_h),         sendMessage $ Swap L)
  , ( (myShiftMask,             xK_k),         sendMessage $ G.Modify $ G.moveToGroupUp False)
  , ( (myShiftMask,             xK_j),         sendMessage $ G.Modify $ G.moveToGroupDown False)
  , ( (myControlMask,           xK_h),         outerAction Shrink)
  , ( (myControlMask,           xK_l),         outerAction Expand)
  , ( (myControlMask,           xK_j),         outerAction MirrorShrink)
  , ( (myControlMask,           xK_k),         outerAction MirrorExpand)
  , ( (myModMask,               xK_slash),     sendMessage $ Toggle MIRROR)
  -- overlay terminal: one per workspace. Very similar to named scratchpads,
  -- but doesn't have to be registered at startup.
  , ( (myModMask,               xK_o),         S.triggerScratch $ S.localTmux "overlay" rightBarRect)
  , ( (myModMask,               xK_semicolon), S.triggerScratch S.projectBrowser')
  , ( (myShiftMask,             xK_semicolon), S.triggerScratch S.projectChromium)
  , ( (myAltMask,               xK_semicolon), S.triggerScratch S.projectFirefox)
  , ( (mod4Mask,                xK_x),         spawn "setxkbmap -layout us -option -option caps:escape -option compose:lwin-altgr -option lv3:ralt_switch -option terminate:ctrl_alt_bksp")
  , ( (myModMask,               xK_F5),        spawn "/home/pi/bin/btk.sh")
  , ( (myModMask,               xK_F7),        spawn "xmodmap /home/pi/.Xmodmap")
  , ( (myModMask,               xK_F11),       spawn "xlock -mode blank")
  , ( (myModMask,               xK_F12),       spawn "xmodmap /home/pi/.Xmodmap")
  , ( (myModMask,               xK_F8),        spawn "/home/pi/bin/block_all.sh")
  , ( (myModMask,               xK_F9),        spawn "/home/pi/bin/unblock_all.sh")
  ]

myBaseKeys :: XConfig Layout -> [(( ButtonMask, KeySym ), X () )]
myBaseKeys _conf = myMainKeys ++
  -- managing groups: next, previous, shift windows between, promote group go master
  -- note that these group-specific actions don't work with non-grouped outer layouts
  [ ( (myModMask,   xK_Return), GH.focusGroupMaster)
  , ( (myAltMask,   xK_Return), GH.swapGroupMaster)
  , ( (myModMask,   xK_n),      GH.focusGroupDown)
  , ( (myModMask,   xK_p),      GH.focusGroupUp)
  , ( (myShiftMask, xK_n),      GH.moveToGroupDown False)
  , ( (myShiftMask, xK_p),      GH.moveToGroupUp False)
  , ( (myAltMask,   xK_n),      GH.swapGroupDown)
  , ( (myAltMask,   xK_p),      GH.swapGroupUp)

  -- only works _inside_ a group, which is what I want but unexpected :)
  -- this is also the way to navigate when in a layout that's not a group
  , ( (myModMask,   xK_period), GH.focusDown)
  , ( (myModMask,   xK_comma),  GH.focusUp)

  -- TODO: no visible effect
  , ( (myShiftMask, xK_period), GH.swapDown)
  , ( (myShiftMask, xK_comma),  GH.swapUp)

  , ( (myAltMask,   xK_v), S.triggerScratch pavucontrol)
  , ( (myModMask,   xK_y), S.triggerScratch anki)
  , ( (myModMask,   xK_g), S.triggerScratch obsidian)

  , ( (myShiftMask, xK_s), shiftNextScreen)
  , ( (myModMask,     xK_BackSpace), toggleSideWorkspace)
  , ( (myShiftMask,   xK_BackSpace), shiftToOtherWorkspace )

  , ( (myModMask,     xK_space), switchProjectPrompt    myPromptConfig)
  , ( (myShiftMask,   xK_space), shiftToProjectPrompt   myPromptConfig)
  , ( (myControlMask, xK_space), changeProjectDirPrompt myPromptConfig)

  -- move floating windows: snap to next barrier. Last param is a Maybe Int
  -- threshold in pixels but I couldn't find any impact;
  -- TODO: check snapMove sources to understand param
  , ( (myShiftMask,   xK_a),  withFocused $ snapMove L Nothing)
  , ( (myShiftMask,   xK_d),  withFocused $ snapMove R Nothing)
  , ( (myShiftMask,   xK_w),  withFocused $ snapMove U Nothing)
  , ( (myShiftMask,   xK_s),  withFocused $ snapMove D Nothing)

  -- resize floating windows, snapping
  , ( (myControlMask, xK_a),  withFocused $ snapShrink R Nothing)
  , ( (myControlMask, xK_d),  withFocused $ snapGrow   R Nothing)
  , ( (myControlMask, xK_w),  withFocused $ snapShrink D Nothing)
  , ( (myControlMask, xK_s),  withFocused $ snapGrow   D Nothing)

  -- resize floating windows, fixed steps
  , ( (myAltMask,     xK_a), withFocused $ keysResizeWindow (-resizeStepSize, 0) (0, 0) )
  , ( (myAltMask,     xK_d), withFocused $ keysResizeWindow (resizeStepSize,  0) (0, 0) )
  , ( (myAltMask,     xK_w), withFocused $ keysResizeWindow (0, -resizeStepSize) (0, 0) )
  , ( (myAltMask,     xK_s), withFocused $ keysResizeWindow (0, resizeStepSize)  (0, 0) )
  ]

myKeys :: XConfig Layout -> M.Map ( ButtonMask, KeySym ) ( X () )
myKeys conf = M.fromList $
  myBaseKeys conf ++ buildTagKeys tags

tagControl :: [( ButtonMask, String -> X () )]
tagControl = [ ( myModMask,     focusUpTagged )
             , ( tagToggleMask, withFocused . toggleTag )
             , ( myShiftMask,   \tag -> focusUpTagged tag >> promote) ]

buildTagKeys :: [Tag] -> [(( ButtonMask, KeySym ), X () )]
buildTagKeys tagKeys =
  [ ( ( modMask', keyToCode M.! key ), action [key] ) | (modMask', action ) <- tagControl, key <- tagKeys ]

toggleTag :: String -> Window -> X ()
toggleTag tag window = do
  tagActive <- hasTag tag window
  if tagActive
  then delTag tag window
  else addTag tag window

workspaceTerm :: String -> X ()
workspaceTerm suffix = do
  workspace <- gets (W.currentTag . windowset)
  let localName = workspace ++ "_" ++ suffix
  raiseMaybe (spawn $ S.tmuxTerm localName localName) (className =? localName)

-- | Send a key to the window
sendKeyEvent :: ButtonMask -> KeySym -> Window -> X ()
sendKeyEvent mask sym w = do
  dpy <- asks display
  io $ allocaXEvent $ \e -> do
    rw      <- rootWindow dpy $ defaultScreen dpy
    keyCode <- keysymToKeycode dpy sym
    setEventType e keyPress
    setKeyEvent e w rw 0 mask keyCode True
    sendEvent dpy w False structureNotifyMask e
  pure ()

-- notify-send: copied from http://pbrisbin.com/posts/using_notify_osd_for_xmonad_notifications/
data LibNotifyUrgencyHook = LibNotifyUrgencyHook deriving (Read, Show)

instance UrgencyHook LibNotifyUrgencyHook where
    urgencyHook LibNotifyUrgencyHook w = do
        n        <- getName w
        Just idx <- fmap (W.findTag w) $ gets windowset
        notify (show n) $ Just $ "workspace " ++ idx

notify :: String -> Maybe String -> X()
notify summary body = safeSpawn "notify-send" [summary, fromMaybe "" body]

-- curtesy of ethanschoonover config somewhere over at github
myTabTheme :: Theme
myTabTheme = def
    { fontName              = myFont 16
    , activeColor           = active
    , inactiveColor         = base02
    , activeBorderColor     = active
    , inactiveBorderColor   = base02
    , activeTextColor       = base03
    , inactiveTextColor     = base00
    , decoHeight            = tabHeight
    }

topBarTheme :: Theme
topBarTheme = def
    { fontName              = myFont 16
    , inactiveBorderColor   = base03
    , inactiveColor         = base03
    , inactiveTextColor     = base03
    , activeBorderColor     = active
    , activeColor           = active
    , activeTextColor       = active
    , urgentBorderColor     = red
    , urgentTextColor       = yellow
    , decoHeight            = topbar
    }

topbar, tabHeight :: Dimension
topbar      = 5
tabHeight   = 14

myFont :: Int -> String
myFont ftSize = "xft:Iosevka:pixelsize=" ++ show ftSize


active, base03, base02, base01, base00, base0, base1, base2, base3, yellow,
  orange, red, magenta, violet, blue, cyan, green :: String
active      = blue
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

