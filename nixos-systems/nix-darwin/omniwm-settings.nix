# OmniWM v0.7.6 requires a complete version 4 file, including disabled features.
# Schema: https://github.com/OmniNull/OmniWM/blob/v0.7.6/Sources/OmniWM/Core/Config/CanonicalTOMLConfig.swift
{
  schemaVersion = 4;

  general = {
    hotkeysEnabled = false;
    systemHyperTrigger = "None";
    hyperKeyModifiers = "Control+Option+Shift+Command";
    defaultLayoutType = "niri";
    preventSleepEnabled = false;
    updateChecksEnabled = false;
    ipcEnabled = true;
    animationsEnabled = true;
  };

  focus = {
    followsMouse = true;
    raiseOnMouseFocus = false;
    lockModifier = "off";
    moveMouseToFocusedWindow = false;
    followsWindowToMonitor = false;
    crossesMonitorAtEdge = false;
    moveCrossesMonitorAtEdge = false;
  };

  mouseWarp = {
    margin = 1;
    enabled = true;
    constrainToArrangement = false;
  };
  routing = {
    mode = "macOS";
    arrangements = [ ];
  };

  gaps = {
    size = 16.0;
    fullscreenUsesOuterGaps = false;
    outer = {
      left = 0.0;
      right = 0.0;
      top = 0.0;
      bottom = 0.0;
    };
  };
  niri = {
    visibleContainerCount = 2;
    infiniteLoop = false;
    centerFocusedColumn = "never";
    alwaysCenterSingleColumn = false;
    singleWindowFit = "fill";
    containerPrimarySpanPresets = [
      0.5
      0.75
      0.9
    ];
    defaultContainerPrimarySpan = 0.5;
    resizeStepPercent = 10;
  };
  dwindle = {
    smartSplit = false;
    defaultSplitRatio = 1.0;
    splitWidthMultiplier = 1.0;
    singleWindowFit = "fill";
    useGlobalGaps = true;
    moveToRootStable = true;
  };

  borders = {
    enabled = true;
    width = 5.0;
    color = {
      red = 0.08458520228437894;
      green = 1.0;
      blue = 0.979300037944676;
      alpha = 1.0;
    };
  };
  overview = {
    zoom = 1.0;
    backdrop = {
      red = 0.05;
      green = 0.05;
      blue = 0.08;
      alpha = 0.0;
    };
    windowBorders = {
      normal = {
        red = 0.3;
        green = 0.3;
        blue = 0.35;
        alpha = 0.5;
      };
      hovered = {
        red = 0.4;
        green = 0.6;
        blue = 1.0;
        alpha = 1.0;
      };
      selected = {
        red = 0.3;
        green = 0.8;
        blue = 0.4;
        alpha = 1.0;
      };
    };
  };

  workspaceBar = {
    enabled = true;
    hoverPreviewsEnabled = false;
    showLabels = true;
    showFloatingWindows = false;
    windowLevel = "popup";
    position = "overlappingMenuBar";
    notchMode = "moveBelowMenuBar";
    notchActiveZoneWidth = 180.0;
    systemStatsButton = false;
    deduplicateAppIcons = false;
    hideEmptyWorkspaces = false;
    excludedBundleIDs = [ ];
    iconOverrides = { };
    reserveLayoutSpace = false;
    revealModifier = "off";
    revealHoldMilliseconds = 200.0;
    hideInNativeFullscreen = false;
    height = 24.0;
    backgroundOpacity = 0.1;
    xOffset = 0.0;
    yOffset = 0.0;
  };
  gestures = {
    scrollEnabled = true;
    scrollSensitivity = 5.0;
    scrollModifierKey = "optionShift";
    mouseMoveModifierKey = "option";
    mouseResizeModifierKey = "option";
    fingerCount = 3;
    invertDirection = true;
    trackpadScrollStyle = "snap";
    workspaceSwipeEnabled = false;
    workspaceSwipeFingerCount = 3;
    workspaceSwipeAxis = "vertical";
  };
  statusBar = {
    showWorkspaceName = false;
    showAppNames = false;
    useWorkspaceId = false;
  };
  hiddenBar = {
    enabled = false;
    hiddenBundleIDs = [ ];
    rehideIntervalSeconds = 5.0;
  };
  clipboard = {
    historyEnabled = false;
    maxItems = 200;
    maxItemBytes = 8388608;
    maxTotalBytes = 67108864;
  };
  quakeTerminal = {
    enabled = false;
    position = "center";
    widthPercent = 50.0;
    heightPercent = 50.0;
    animationDuration = 0.2;
    autoHide = false;
    backgroundEffect = "standardBlur";
  };
  scratchpads.labels."1" = "overlay";
  appearance = {
    mode = "dark";
    tabRailAppIcons = true;
  };
  hotkeys = [ ];

  workspaces = [
    {
      id = "AD36F001-C57E-41A5-AC1D-DF5249D007F0";
      name = "1";
      layoutType = "niri";
      monitorAssignment.type = "main";
    }
    {
      id = "454CECD4-5E9D-4ED1-95D7-979D48817F5F";
      name = "2";
      layoutType = "niri";
      monitorAssignment.type = "secondary";
    }
  ];

  appRules = [
    # Floating admission preserves the overlay's small launch size.
    {
      id = "CF29B47D-7A5C-4A15-A1BB-9BDB7F28F74B";
      bundleId = "org.alacritty";
      titleRegex = "^code/overlay$";
      layout = "float";
    }
    # Retain upstream resize floors so layouts respect application constraints.
    {
      id = "6A31F08A-4051-4354-B439-42F4C71894A3";
      bundleId = "com.openai.codex";
      minWidth = 800.0;
      minHeight = 600.0;
    }
    {
      id = "4BA546DA-2875-4BEF-B13F-1539E833B1A0";
      bundleId = "com.eltima.cmd1.pro.mas";
      minWidth = 950.0;
      minHeight = 550.0;
    }
    {
      id = "486CEFA6-69AA-4A3C-AF27-BCD38F4F138B";
      bundleId = "com.google.Chrome";
      minWidth = 500.0;
      minHeight = 375.0;
    }
    {
      id = "979F05F4-FFA2-4EDD-B23F-08A9944C759F";
      bundleId = "dev.zed.Zed";
      minWidth = 360.0;
      minHeight = 240.0;
    }
    {
      id = "81426D13-C1A5-475E-AFBC-00BBA05042D0";
      bundleId = "com.apple.Safari";
      minWidth = 574.0;
      minHeight = 220.0;
    }
    {
      id = "1CF39647-F30D-4E76-9686-79B551F1B094";
      bundleId = "app.zen-browser.zen";
      minWidth = 500.0;
      minHeight = 495.0;
    }
    {
      id = "005C00D3-F665-47F8-BDAE-D80790E9E46B";
      bundleId = "org.mozilla.firefox";
      minWidth = 500.0;
      minHeight = 120.0;
    }
    {
      id = "C21156B1-0224-4998-97E3-8F4FA65B9F3B";
      bundleId = "company.thebrowser.dia";
      minWidth = 500.0;
      minHeight = 420.0;
    }
    {
      id = "2DE9390B-0DB4-4D0C-9ABA-06F76F1D4EA9";
      bundleId = "com.spotify.client";
      minWidth = 800.0;
      minHeight = 600.0;
    }
    {
      id = "AF752D95-8497-4844-BE20-4C93E73BAEF2";
      bundleId = "com.hnc.Discord";
      minWidth = 800.0;
      minHeight = 500.0;
    }
    {
      id = "7876C9EF-437E-4D4F-9C27-B1B02F4AABCE";
      bundleId = "com.mitchellh.ghostty";
      minWidth = 90.0;
      minHeight = 48.0;
    }
    {
      id = "8ECAB78B-BCDD-4245-BC25-1609A49B1C86";
      bundleId = "com.microsoft.Outlook";
      minWidth = 930.0;
      minHeight = 650.0;
    }
    {
      id = "552FB77D-BF0E-4737-90A6-B5BC6986C579";
      bundleId = "com.apple.MobileSMS";
      minWidth = 660.0;
      minHeight = 320.0;
    }
  ];

  monitorBarOverrides = [ ];
  monitorOrientationOverrides = [ ];
  monitorNiriOverrides = [ ];
  monitorDwindleOverrides = [ ];
  monitorGapOverrides = [ ];
}
