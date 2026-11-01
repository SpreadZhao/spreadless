{ lib }:
let
  boolToInt = b: if b then "1" else "0";

  cStrOrNull = s: if s == null then "NULL" else builtins.toJSON s;

  cFloat =
    v:
    let
      s = toString v;
    in
    if lib.hasInfix "." s then "${s}f" else "${s}.0f";

  defaultConfig = {
    sloppyfocus = false;
    bypassSurfaceVisibility = false;
    borderpx = 2;
    unfocusedBorderpx = 0;
    snap = 32;
    cursorSize = 36;
    enablePrimarySelection = false;
    showbar = true;
    topbar = true;
    barHpad = 2;
    statusRpad = 2;
    fonts = [
      "monospace:size=10"
    ];
    rootcolor = "0x222222ff";
    fullscreenBg = [
      0.0
      0.0
      0.0
      1.0
    ];
    colors = {
      norm = {
        fg = "0xbbbbbbff";
        bg = "0x222222ff";
        border = "0x444444ff";
      };
      sel = {
        fg = "0xeeeeeeff";
        bg = "0x005577ff";
        border = "0x005577ff";
      };
      urg = {
        fg = "0";
        bg = "0";
        border = "0x770000ff";
      };
    };
    tags = [
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
    ];
    logLevel = "WLR_ERROR";
    rules = [ ];
    layouts = [
      {
        symbol = "[]=";
        arrange = "tile";
      }
      {
        symbol = "><>";
        arrange = null;
      }
      {
        symbol = "[M]";
        arrange = "monocle";
      }
      {
        symbol = "[D]";
        arrange = "deck";
      }
    ];
    monrules = [
      {
        name = null;
        mfact = 0.5;
        nmaster = 1;
        scale = 1.0;
        layout = "&layouts[0]";
        transform = "WL_OUTPUT_TRANSFORM_NORMAL";
        x = -1;
        y = -1;
      }
    ];
    xkbRules = {
      rules = null;
      model = null;
      layout = null;
      variant = null;
      options = null;
    };
    repeatRate = 25;
    repeatDelay = 600;
    numlockOn = true;
    touchpad = {
      scrollFactor = 1.0;
      tapToClick = true;
      tapAndDrag = true;
      dragLock = true;
      naturalScrolling = true;
      disableWhileTyping = true;
      leftHanded = false;
      middleButtonEmulation = false;
      scrollMethod = "LIBINPUT_CONFIG_SCROLL_2FG";
      clickMethod = "LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS";
      sendEventsMode = "LIBINPUT_CONFIG_SEND_EVENTS_ENABLED";
      accelProfile = "LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE";
      accelSpeed = 0.5;
      buttonMap = "LIBINPUT_CONFIG_TAP_MAP_LRM";
    };
    mouse = {
      naturalScrolling = false;
      accelProfile = "LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE";
      accelSpeed = 0.0;
    };
    tabletRules = [ ];
    modkey = "WLR_MODIFIER_ALT";
    binds = {
      "MODKEY, XKB_KEY_p" = ''spawn, {.v = (const char*[]){ "wmenu-run", NULL }}'';
      "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_Return" = ''spawn, {.v = (const char*[]){ "foot", NULL }}'';
      "MODKEY, XKB_KEY_b" = "togglebar, {0}";
      "MODKEY, XKB_KEY_j" = "focusstack, {.i = +1}";
      "MODKEY, XKB_KEY_k" = "focusstack, {.i = -1}";
      "MODKEY, XKB_KEY_i" = "incnmaster, {.i = +1}";
      "MODKEY, XKB_KEY_d" = "incnmaster, {.i = -1}";
      "MODKEY, XKB_KEY_h" = "setmfact, {.f = -0.05f}";
      "MODKEY, XKB_KEY_l" = "setmfact, {.f = +0.05f}";
      "MODKEY, XKB_KEY_Return" = "zoom, {0}";
      "MODKEY, XKB_KEY_Tab" = "view, {0}";
      "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_c" = "killclient, {0}";
      "MODKEY, XKB_KEY_t" = "setlayout, {.v = &layouts[0]}";
      "MODKEY, XKB_KEY_f" = "setlayout, {.v = &layouts[1]}";
      "MODKEY, XKB_KEY_m" = "setlayout, {.v = &layouts[2]}";
      "MODKEY, XKB_KEY_space" = "cyclelayout, {0}";
      "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_space" = "togglefloating, {0}";
      "MODKEY, XKB_KEY_e" = "togglefullscreen, {0}";
      "MODKEY, XKB_KEY_0" = "view, {.ui = ~0}";
      "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_0" = "tag, {.ui = ~0}";
      "MODKEY, XKB_KEY_comma" = "focusmon, {.i = WLR_DIRECTION_LEFT}";
      "MODKEY, XKB_KEY_period" = "focusmon, {.i = WLR_DIRECTION_RIGHT}";
      "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_comma" = "tagmon, {.i = WLR_DIRECTION_LEFT}";
      "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_period" = "tagmon, {.i = WLR_DIRECTION_RIGHT}";
      "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_q" = "quit, {0}";
      "WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT, XKB_KEY_BackSpace" = "quit, {0}";
    }
    // lib.mergeAttrsList (
      lib.genList (
        i:
        let
          key = "XKB_KEY_${toString (i + 1)}";
          arg = "{.ui = 1 << ${toString i}}";
        in
        {
          "MODKEY, ${key}" = "view, ${arg}";
          "MODKEY|WLR_MODIFIER_CTRL, ${key}" = "toggleview, ${arg}";
          "MODKEY|WLR_MODIFIER_SHIFT, ${key}" = "tag, ${arg}";
          "MODKEY|WLR_MODIFIER_CTRL|WLR_MODIFIER_SHIFT, ${key}" = "toggletag, ${arg}";
        }
      ) 9
    )
    // builtins.listToAttrs (
      lib.genList (i: {
        name = "WLR_MODIFIER_CTRL|WLR_MODIFIER_ALT, XKB_KEY_F${toString (i + 1)}";
        value = "chvt, {.ui = ${toString (i + 1)}}";
      }) 12
    );
    buttons = [
      "MODKEY, BTN_LEFT, moveresize, {.ui = CurMove}, ClkClient"
      "MODKEY, BTN_MIDDLE, togglefloating, {0}, ClkClient"
      "MODKEY, BTN_RIGHT, moveresize, {.ui = CurResize}, ClkClient"
      "0, BTN_LEFT, view, {0}, ClkTagBar"
      "0, BTN_RIGHT, toggleview, {0}, ClkTagBar"
      "MODKEY, BTN_LEFT, tag, {0}, ClkTagBar"
      "MODKEY, BTN_RIGHT, toggletag, {0}, ClkTagBar"
    ];
    axes = [ ];
  };

  renderConfig =
    rawCfg:
    let
      cfg =
        defaultConfig
        // rawCfg
        // {
          colors = {
            norm = defaultConfig.colors.norm // (rawCfg.colors.norm or { });
            sel = defaultConfig.colors.sel // (rawCfg.colors.sel or { });
            urg = defaultConfig.colors.urg // (rawCfg.colors.urg or { });
          };
          xkbRules = defaultConfig.xkbRules // (rawCfg.xkbRules or { });
          touchpad = defaultConfig.touchpad // (rawCfg.touchpad or { });
          mouse = defaultConfig.mouse // (rawCfg.mouse or { });
        };

      fontLines = lib.concatMapStringsSep "\n" (f: "\t${builtins.toJSON f},") cfg.fonts;
      tagList = lib.concatMapStringsSep ", " builtins.toJSON cfg.tags;
      fsBg = lib.concatMapStringsSep ", " cFloat cfg.fullscreenBg;

      effectiveRules =
        if cfg.rules == [ ] then
          [
            {
              appId = "\\0";
              title = null;
              tags = 0;
              isFloating = false;
              monitor = -1;
              floatW = 0.0;
              floatH = 0.0;
              floatY = -1;
            }
          ]
        else
          cfg.rules;

      ruleLines = lib.concatMapStringsSep "\n" (
        r:
        "\t{ ${cStrOrNull (r.appId or null)}, ${cStrOrNull (r.title or null)}, ${toString (r.tags or 0)}, ${
          boolToInt (r.isFloating or false)
        }, ${toString (r.monitor or (-1))}, ${cFloat (r.floatW or 0.0)}, ${cFloat (r.floatH or 0.0)}, ${toString (r.floatY or (-1))} },"
      ) effectiveRules;

      layoutLines = lib.concatMapStringsSep "\n" (
        l: "\t{ ${builtins.toJSON l.symbol}, ${if l.arrange == null then "NULL" else l.arrange} },"
      ) cfg.layouts;

      monruleLines = lib.concatMapStringsSep "\n" (
        m:
        "\t{ ${cStrOrNull (m.name or null)}, ${cFloat (m.mfact or 0.5)}, ${toString (m.nmaster or 1)}, ${cFloat (m.scale or 1.0)}, ${m.layout or "&layouts[0]"}, ${
          m.transform or "WL_OUTPUT_TRANSFORM_NORMAL"
        }, ${toString (m.x or (-1))}, ${toString (m.y or (-1))} },"
      ) cfg.monrules;

      tabletLines =
        lib.concatMapStringsSep "\n" (t: "\t{ ${cStrOrNull t.name}, ${cStrOrNull t.output} },")
          (
            cfg.tabletRules
            ++ [
              {
                name = null;
                output = null;
              }
            ]
          );

      bindLines = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (key: action: "\t{ ${key}, ${action} },") cfg.binds
      );

      buttonLines = lib.concatMapStringsSep "\n" (b: "\t{ ${b} },") cfg.buttons;

      axisLines =
        if cfg.axes == [ ] then "\t{0}," else lib.concatMapStringsSep "\n" (a: "\t{ ${a} },") cfg.axes;
    in
    ''
      /* Taken from https://github.com/djpohly/dwl/issues/466 */
      #define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                              ((hex >> 16) & 0xFF) / 255.0f, \
                              ((hex >> 8) & 0xFF) / 255.0f, \
                              (hex & 0xFF) / 255.0f }

      static const TabletRule tabletrules[] = {
      ${tabletLines}
      };

      /* appearance */
      static const int sloppyfocus               = ${boolToInt cfg.sloppyfocus};
      static const int bypass_surface_visibility = ${boolToInt cfg.bypassSurfaceVisibility};
      static const unsigned int borderpx         = ${toString cfg.borderpx};
      static const unsigned int unfocused_borderpx = ${toString cfg.unfocusedBorderpx};
      static const unsigned int snap             = ${toString cfg.snap};
      static const unsigned int cursor_size      = ${toString cfg.cursorSize};
      static const int enable_primary_selection  = ${boolToInt cfg.enablePrimarySelection};
      static const int showbar                   = ${boolToInt cfg.showbar};
      static const int topbar                    = ${boolToInt cfg.topbar};
      static const int bar_hpad                  = ${toString cfg.barHpad};
      static const int status_rpad               = ${toString cfg.statusRpad};
      static const char *fonts[]                 = {
      ${fontLines}
      };
      static const float rootcolor[]             = COLOR(${cfg.rootcolor});
      static const float fullscreen_bg[]         = { ${fsBg} };
      static uint32_t colors[][3]                = {
      	/*               fg          bg          border    */
      	[SchemeNorm] = { ${cfg.colors.norm.fg}, ${cfg.colors.norm.bg}, ${cfg.colors.norm.border} },
      	[SchemeSel]  = { ${cfg.colors.sel.fg},  ${cfg.colors.sel.bg},  ${cfg.colors.sel.border}  },
      	[SchemeUrg]  = { ${cfg.colors.urg.fg},  ${cfg.colors.urg.bg},  ${cfg.colors.urg.border}  },
      };

      /* tagging */
      static char *tags[] = { ${tagList} };

      /* logging */
      static int log_level = ${cfg.logLevel};

      static const Rule rules[] = {
      	/* app_id  title  tags mask  isfloating  monitor  floatw  floath  floaty */
      ${ruleLines}
      };

      /* layout(s) */
      static const Layout layouts[] = {
      	/* symbol  arrange function */
      ${layoutLines}
      };

      /* monitors */
      static const MonitorRule monrules[] = {
      	/* name  mfact  nmaster  scale  layout  rotate/reflect  x  y */
      ${monruleLines}
      };

      /* keyboard */
      static const struct xkb_rule_names xkb_rules = {
      	.rules = ${cStrOrNull cfg.xkbRules.rules},
      	.model = ${cStrOrNull cfg.xkbRules.model},
      	.layout = ${cStrOrNull cfg.xkbRules.layout},
      	.variant = ${cStrOrNull cfg.xkbRules.variant},
      	.options = ${cStrOrNull cfg.xkbRules.options},
      };

      static const int repeat_rate = ${toString cfg.repeatRate};
      static const int repeat_delay = ${toString cfg.repeatDelay};
      static const int numlock_on = ${boolToInt cfg.numlockOn};

      /* Trackpad */
      static const double touchpad_scroll_factor = ${toString cfg.touchpad.scrollFactor};
      static const int tap_to_click = ${boolToInt cfg.touchpad.tapToClick};
      static const int tap_and_drag = ${boolToInt cfg.touchpad.tapAndDrag};
      static const int drag_lock = ${boolToInt cfg.touchpad.dragLock};
      static const int natural_scrolling = ${boolToInt cfg.touchpad.naturalScrolling};
      static const int disable_while_typing = ${boolToInt cfg.touchpad.disableWhileTyping};
      static const int left_handed = ${boolToInt cfg.touchpad.leftHanded};
      static const int middle_button_emulation = ${boolToInt cfg.touchpad.middleButtonEmulation};
      static const enum libinput_config_scroll_method scroll_method = ${cfg.touchpad.scrollMethod};
      static const enum libinput_config_click_method click_method = ${cfg.touchpad.clickMethod};
      static const uint32_t send_events_mode = ${cfg.touchpad.sendEventsMode};
      static const enum libinput_config_accel_profile accel_profile = ${cfg.touchpad.accelProfile};
      static const double accel_speed = ${toString cfg.touchpad.accelSpeed};
      static const enum libinput_config_tap_button_map button_map = ${cfg.touchpad.buttonMap};

      /* Mouse */
      static const int mouse_natural_scrolling = ${boolToInt cfg.mouse.naturalScrolling};
      static const enum libinput_config_accel_profile mouse_accel_profile = ${cfg.mouse.accelProfile};
      static const double mouse_accel_speed = ${toString cfg.mouse.accelSpeed};

      #define MODKEY ${cfg.modkey}

      #define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

      static const Key keys[] = {
      ${bindLines}
      };

      static const Button buttons[] = {
      ${buttonLines}
      };

      static const Axis axes[] = {
      ${axisLines}
      };
    '';

  mkSchemeOptions = defaults: {
    fg = lib.mkOption {
      type = lib.types.singleLineStr;
      default = defaults.fg;
      description = "Foreground color C literal (such as 0xbbbbbbff).";
    };
    bg = lib.mkOption {
      type = lib.types.singleLineStr;
      default = defaults.bg;
      description = "Background color C literal (such as 0x222222ff).";
    };
    border = lib.mkOption {
      type = lib.types.singleLineStr;
      default = defaults.border;
      description = "Border color C literal (such as 0x444444ff).";
    };
  };

  options = {
    sloppyfocus = lib.mkOption {
      type = lib.types.bool;
      default = defaultConfig.sloppyfocus;
      description = "Focus follows pointer movement.";
    };
    bypassSurfaceVisibility = lib.mkOption {
      type = lib.types.bool;
      default = defaultConfig.bypassSurfaceVisibility;
      description = "Allow idle inhibitors even when their surface is not visible.";
    };
    borderpx = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = defaultConfig.borderpx;
      description = "Visible border width in logical pixels for the focused window.";
    };
    unfocusedBorderpx = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = defaultConfig.unfocusedBorderpx;
      description = "Visible border width in logical pixels for unfocused windows.";
    };
    snap = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = defaultConfig.snap;
      description = "Edge snap distance in logical pixels.";
    };
    cursorSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = defaultConfig.cursorSize;
      description = "XCursor size in pixels.";
    };
    enablePrimarySelection = lib.mkOption {
      type = lib.types.bool;
      default = defaultConfig.enablePrimarySelection;
      description = "Allow middle-click primary selection paste.";
    };
    showbar = lib.mkOption {
      type = lib.types.bool;
      default = defaultConfig.showbar;
      description = "Show the status bar on outputs by default.";
    };
    topbar = lib.mkOption {
      type = lib.types.bool;
      default = defaultConfig.topbar;
      description = "Place the status bar at the top of each output.";
    };
    barHpad = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = defaultConfig.barHpad;
      description = "Horizontal padding in logical pixels around tags, layout symbols and titles.";
    };
    statusRpad = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = defaultConfig.statusRpad;
      description = "Right padding in logical pixels for the status text.";
    };
    fonts = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.singleLineStr;
      default = defaultConfig.fonts;
      description = "Ordered fontconfig strings for the bar (primary font followed by fallbacks).";
    };
    rootcolor = lib.mkOption {
      type = lib.types.singleLineStr;
      default = defaultConfig.rootcolor;
      description = "Compositor root background color C literal (such as 0x222222ff).";
    };
    fullscreenBg = lib.mkOption {
      type = lib.types.listOf lib.types.float;
      default = defaultConfig.fullscreenBg;
      description = "RGBA float array for fullscreen background.";
    };
    colors = {
      norm = mkSchemeOptions defaultConfig.colors.norm;
      sel = mkSchemeOptions defaultConfig.colors.sel;
      urg = mkSchemeOptions defaultConfig.colors.urg;
    };
    tags = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.singleLineStr;
      default = defaultConfig.tags;
      description = "Tag labels shown in the status bar.";
    };
    logLevel = lib.mkOption {
      type = lib.types.singleLineStr;
      default = defaultConfig.logLevel;
      description = "wlroots log verbosity constant.";
    };
    rules = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            appId = lib.mkOption {
              type = lib.types.nullOr lib.types.singleLineStr;
              default = null;
              description = "Substring matched against client app_id.";
            };
            title = lib.mkOption {
              type = lib.types.nullOr lib.types.singleLineStr;
              default = null;
              description = "Substring matched against client title.";
            };
            tags = lib.mkOption {
              type = lib.types.oneOf [
                lib.types.ints.unsigned
                lib.types.singleLineStr
              ];
              default = 0;
              description = "Tag bitmask expression assigned to matching clients (0 keeps current tags).";
            };
            isFloating = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Open matching clients as floating windows.";
            };
            monitor = lib.mkOption {
              type = lib.types.int;
              default = -1;
              description = "Target monitor index (-1 keeps the active monitor).";
            };
            floatW = lib.mkOption {
              type = lib.types.float;
              default = 0.0;
              description = "Floating width as a fraction of monitor width (0 preserves client width).";
            };
            floatH = lib.mkOption {
              type = lib.types.float;
              default = 0.0;
              description = "Floating height as a fraction of monitor height (0 preserves client height).";
            };
            floatY = lib.mkOption {
              type = lib.types.int;
              default = -1;
              description = "Vertical placement: 0 aligns to top of usable area, -1 centers vertically.";
            };
          };
        }
      );
      default = defaultConfig.rules;
      description = "Window matching and floating geometry rules.";
    };
    layouts = lib.mkOption {
      type = lib.types.nonEmptyListOf (
        lib.types.submodule {
          options = {
            symbol = lib.mkOption {
              type = lib.types.singleLineStr;
              description = "Layout indicator shown in the status bar.";
            };
            arrange = lib.mkOption {
              type = lib.types.nullOr lib.types.singleLineStr;
              default = null;
              description = "Layout arrangement function name (null for floating).";
            };
          };
        }
      );
      default = defaultConfig.layouts;
      description = "Available window layouts.";
    };
    monrules = lib.mkOption {
      type = lib.types.nonEmptyListOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.nullOr lib.types.singleLineStr;
              default = null;
              description = "Output connector name (null matches any output).";
            };
            mfact = lib.mkOption {
              type = lib.types.float;
              default = 0.5;
              description = "Default master area ratio.";
            };
            nmaster = lib.mkOption {
              type = lib.types.ints.positive;
              default = 1;
              description = "Default number of master windows.";
            };
            scale = lib.mkOption {
              type = lib.types.float;
              default = 1.0;
              description = "Output scale factor.";
            };
            layout = lib.mkOption {
              type = lib.types.singleLineStr;
              default = "&layouts[0]";
              description = "C pointer expression into the layouts table.";
            };
            transform = lib.mkOption {
              type = lib.types.singleLineStr;
              default = "WL_OUTPUT_TRANSFORM_NORMAL";
              description = "wl_output_transform constant.";
            };
            x = lib.mkOption {
              type = lib.types.int;
              default = -1;
              description = "Output X position (-1 for automatic layout).";
            };
            y = lib.mkOption {
              type = lib.types.int;
              default = -1;
              description = "Output Y position (-1 for automatic layout).";
            };
          };
        }
      );
      default = defaultConfig.monrules;
      description = "Output configuration rules.";
    };
    xkbRules = {
      rules = lib.mkOption {
        type = lib.types.nullOr lib.types.singleLineStr;
        default = null;
        description = "XKB rules file.";
      };
      model = lib.mkOption {
        type = lib.types.nullOr lib.types.singleLineStr;
        default = null;
        description = "XKB keyboard model.";
      };
      layout = lib.mkOption {
        type = lib.types.nullOr lib.types.singleLineStr;
        default = null;
        description = "XKB layout.";
      };
      variant = lib.mkOption {
        type = lib.types.nullOr lib.types.singleLineStr;
        default = null;
        description = "XKB variant.";
      };
      options = lib.mkOption {
        type = lib.types.nullOr lib.types.singleLineStr;
        default = null;
        description = "XKB options.";
      };
    };
    repeatRate = lib.mkOption {
      type = lib.types.ints.positive;
      default = defaultConfig.repeatRate;
      description = "Keyboard repeat rate in repeats per second.";
    };
    repeatDelay = lib.mkOption {
      type = lib.types.ints.positive;
      default = defaultConfig.repeatDelay;
      description = "Keyboard repeat delay in milliseconds.";
    };
    numlockOn = lib.mkOption {
      type = lib.types.bool;
      default = defaultConfig.numlockOn;
      description = "Enable NumLock when initializing keyboards.";
    };
    touchpad = {
      scrollFactor = lib.mkOption {
        type = lib.types.float;
        default = defaultConfig.touchpad.scrollFactor;
        description = "Multiplier for touchpad finger scroll deltas.";
      };
      tapToClick = lib.mkOption {
        type = lib.types.bool;
        default = defaultConfig.touchpad.tapToClick;
        description = "Enable tap-to-click on touchpads.";
      };
      tapAndDrag = lib.mkOption {
        type = lib.types.bool;
        default = defaultConfig.touchpad.tapAndDrag;
        description = "Enable tap-and-drag on touchpads.";
      };
      dragLock = lib.mkOption {
        type = lib.types.bool;
        default = defaultConfig.touchpad.dragLock;
        description = "Enable drag lock on touchpads.";
      };
      naturalScrolling = lib.mkOption {
        type = lib.types.bool;
        default = defaultConfig.touchpad.naturalScrolling;
        description = "Enable natural scrolling on touchpads.";
      };
      disableWhileTyping = lib.mkOption {
        type = lib.types.bool;
        default = defaultConfig.touchpad.disableWhileTyping;
        description = "Disable touchpad while typing.";
      };
      leftHanded = lib.mkOption {
        type = lib.types.bool;
        default = defaultConfig.touchpad.leftHanded;
        description = "Enable left-handed mode on touchpads.";
      };
      middleButtonEmulation = lib.mkOption {
        type = lib.types.bool;
        default = defaultConfig.touchpad.middleButtonEmulation;
        description = "Enable middle-button emulation.";
      };
      scrollMethod = lib.mkOption {
        type = lib.types.singleLineStr;
        default = defaultConfig.touchpad.scrollMethod;
        description = "libinput scroll method constant.";
      };
      clickMethod = lib.mkOption {
        type = lib.types.singleLineStr;
        default = defaultConfig.touchpad.clickMethod;
        description = "libinput click method constant.";
      };
      sendEventsMode = lib.mkOption {
        type = lib.types.singleLineStr;
        default = defaultConfig.touchpad.sendEventsMode;
        description = "libinput send-events mode constant.";
      };
      accelProfile = lib.mkOption {
        type = lib.types.singleLineStr;
        default = defaultConfig.touchpad.accelProfile;
        description = "Touchpad acceleration profile constant.";
      };
      accelSpeed = lib.mkOption {
        type = lib.types.float;
        default = defaultConfig.touchpad.accelSpeed;
        description = "Touchpad pointer acceleration speed (-1.0 to 1.0).";
      };
      buttonMap = lib.mkOption {
        type = lib.types.singleLineStr;
        default = defaultConfig.touchpad.buttonMap;
        description = "Touchpad tap button map constant.";
      };
    };
    mouse = {
      naturalScrolling = lib.mkOption {
        type = lib.types.bool;
        default = defaultConfig.mouse.naturalScrolling;
        description = "Enable natural scrolling on mice.";
      };
      accelProfile = lib.mkOption {
        type = lib.types.singleLineStr;
        default = defaultConfig.mouse.accelProfile;
        description = "Mouse acceleration profile constant.";
      };
      accelSpeed = lib.mkOption {
        type = lib.types.float;
        default = defaultConfig.mouse.accelSpeed;
        description = "Mouse pointer acceleration speed (-1.0 to 1.0).";
      };
    };
    tabletRules = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.singleLineStr;
              description = "Exact tablet input device name.";
            };
            output = lib.mkOption {
              type = lib.types.singleLineStr;
              description = "Target output connector name, such as DP-1.";
            };
          };
        }
      );
      default = defaultConfig.tabletRules;
      description = "Tablet device to output mappings.";
    };
    modkey = lib.mkOption {
      type = lib.types.singleLineStr;
      default = defaultConfig.modkey;
      description = "Primary compositor modifier constant (such as WLR_MODIFIER_LOGO or WLR_MODIFIER_ALT).";
    };
    binds = lib.mkOption {
      type = lib.types.attrsOf lib.types.singleLineStr;
      default = defaultConfig.binds;
      description = "Key bindings mapping 'mod, keysym' to 'func, arg' C initializers.";
    };
    buttons = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
      default = defaultConfig.buttons;
      description = "Button struct initializers ('mod, button, func, arg, click').";
    };
    axes = lib.mkOption {
      type = lib.types.listOf lib.types.singleLineStr;
      default = defaultConfig.axes;
      description = "Axis struct initializers ('mod, dir, func, arg').";
    };
  };
in
{
  inherit defaultConfig options renderConfig;
}
