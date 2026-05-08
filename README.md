<details><summary>Example</summary>

```json
{
    "enabled": true,
    "appearance": {
        "deformScale": 1,
        "anim": {
            "durations": {
                "scale": 1
            }
        },
        "font": {
            "family": {
                "clock": "Rubik",
                "material": "Material Symbols Rounded",
                "mono": "CaskaydiaCove NF",
                "sans": "Rubik"
            },
            "size": {
                "scale": 1
            }
        },
        "padding": {
            "scale": 1
        },
        "rounding": {
            "scale": 1
        },
        "spacing": {
            "scale": 1
        },
        "transparency": {
            "enabled": false,
            "base": 0.85,
            "layers": 0.4
        }
    },
    "general": {
        "logo": "creomnia",
        "showOverFullscreen": false,
        "mediaGifSpeedAdjustment": 300,
        "sessionGifSpeed": 0.7,
        "apps": {
            "terminal": ["foot"],
            "audio": ["pavucontrol"],
            "playback": ["mpv"],
            "explorer": ["thunar"]
        },
        "battery": {
            "warnLevels": [
                {
                    "level": 20,
                    "title": "Low battery",
                    "message": "You might want to plug in a charger",
                    "icon": "battery_android_frame_2"
                },
                {
                    "level": 10,
                    "title": "Did you see the previous message?",
                    "message": "You should probably plug in a charger <b>now</b>",
                    "icon": "battery_android_frame_1"
                },
                {
                    "level": 5,
                    "title": "Critical battery level",
                    "message": "PLUG THE CHARGER RIGHT NOW!!",
                    "icon": "battery_android_alert",
                    "critical": true
                }
            ],
            "criticalLevel": 3
        },
        "idle": {
            "lockBeforeSleep": true,
            "inhibitWhenAudio": true,
            "timeouts": [
                {
                    "timeout": 180,
                    "idleAction": "lock"
                },
                {
                    "timeout": 300,
                    "idleAction": "dpms off",
                    "returnAction": "dpms on"
                },
                {
                    "timeout": 600,
                    "idleAction": ["systemctl", "suspend-then-hibernate"]
                }
            ]
        }
    },
    "background": {
        "desktopClock": {
            "enabled": false,
            "scale": 1.0,
            "position": "bottom-right",
            "shadow": {
                "enabled": true,
                "opacity": 0.7,
                "blur": 0.4
            },
            "background": {
                "enabled": false,
                "opacity": 0.7,
                "blur": true
            },
            "invertColors": false
        },
        "enabled": true,
        "visualiser": {
            "blur": false,
            "enabled": false,
            "autoHide": true,
            "rounding": 1,
            "spacing": 1
        }
    },
    "bar": {
        "activeWindow": {
            "compact": false,
            "inverted": false,
            "showOnHover": true
        },
        "clock": {
            "background": false,
            "showDate": false,
            "showIcon": true
        },
        "dragThreshold": 20,
        "entries": [
            {
                "id": "logo",
                "enabled": true
            },
            {
                "id": "workspaces",
                "enabled": true
            },
            {
                "id": "spacer",
                "enabled": true
            },
            {
                "id": "activeWindow",
                "enabled": true
            },
            {
                "id": "spacer",
                "enabled": true
            },
            {
                "id": "tray",
                "enabled": true
            },
            {
                "id": "clock",
                "enabled": true
            },
            {
                "id": "statusIcons",
                "enabled": true
            },
            {
                "id": "power",
                "enabled": true
            }
        ],
        "persistent": true,
        "popouts": {
            "activeWindow": true,
            "statusIcons": true,
            "tray": true
        },
        "scrollActions": {
            "brightness": true,
            "workspaces": true,
            "volume": true
        },
        "showOnHover": true,
        "status": {
            "showAudio": false,
            "showBattery": true,
            "showBluetooth": true,
            "showKbLayout": false,
            "showMicrophone": false,
            "showNetwork": true,
            "showWifi": true,
            "showLockStatus": true
        },
        "tray": {
            "background": false,
            "compact": false,
            "iconSubs": [],
            "recolour": false
        },
        "workspaces": {
            "activeIndicator": true,
            "activeLabel": "󰮯",
            "activeTrail": false,
            "label": "  ",
            "occupiedBg": false,
            "occupiedLabel": "󰮯",
            "perMonitorWorkspaces": true,
            "showWindows": true,
            "shown": 5,
            "specialWorkspaceIcons": [
                {
                    "name": "steam",
                    "icon": "sports_esports"
                }
            ],
            "windowIcons": [
                {
                    "regex": "steam(_app_(default|[0-9]+))?",
                    "icon": "sports_esports"
                }
            ]
        },
        "excludedScreens": [""],
        "activeWindow": {
            "inverted": false
        }
    },
    "border": {
        "rounding": 25,
        "smoothing": 32,
        "thickness": 10
    },
    "dashboard": {
        "enabled": true,
        "showOnHover": true,
        "showDashboard": true,
        "showMedia": true,
        "showPerformance": true,
        "showWeather": true,
        "dragThreshold": 50,
        "mediaUpdateInterval": 500
    },
    "launcher": {
        "actionPrefix": ">",
        "actions": [
            {
                "name": "Calculator",
                "icon": "calculate",
                "description": "Do simple math equations (powered by Qalc)",
                "command": ["autocomplete", "calc"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Scheme",
                "icon": "palette",
                "description": "Change the current colour scheme",
                "command": ["autocomplete", "scheme"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Wallpaper",
                "icon": "image",
                "description": "Change the current wallpaper",
                "command": ["autocomplete", "wallpaper"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Variant",
                "icon": "colors",
                "description": "Change the current scheme variant",
                "command": ["autocomplete", "variant"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Transparency",
                "icon": "opacity",
                "description": "Change shell transparency",
                "command": ["autocomplete", "transparency"],
                "enabled": false,
                "dangerous": false
            },
            {
                "name": "Random",
                "icon": "casino",
                "description": "Switch to a random wallpaper",
                "command": ["creomnia", "wallpaper", "-r"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Light",
                "icon": "light_mode",
                "description": "Change the scheme to light mode",
                "command": ["setMode", "light"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Dark",
                "icon": "dark_mode",
                "description": "Change the scheme to dark mode",
                "command": ["setMode", "dark"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Shutdown",
                "icon": "power_settings_new",
                "description": "Shutdown the system",
                "command": ["systemctl", "poweroff"],
                "enabled": true,
                "dangerous": true
            },
            {
                "name": "Reboot",
                "icon": "cached",
                "description": "Reboot the system",
                "command": ["systemctl", "reboot"],
                "enabled": true,
                "dangerous": true
            },
            {
                "name": "Logout",
                "icon": "exit_to_app",
                "description": "Log out of the current session",
                "command": ["loginctl", "terminate-user", ""],
                "enabled": true,
                "dangerous": true
            },
            {
                "name": "Lock",
                "icon": "lock",
                "description": "Lock the current session",
                "command": ["loginctl", "lock-session"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Sleep",
                "icon": "bedtime",
                "description": "Suspend then hibernate",
                "command": ["systemctl", "suspend-then-hibernate"],
                "enabled": true,
                "dangerous": false
            },
            {
                "name": "Settings",
                "icon": "settings",
                "description": "Configure the shell",
                "command": ["creomnia", "shell", "controlCenter", "open"],
                "enabled": true,
                "dangerous": false
            }
        ],
        "dragThreshold": 50,
        "vimKeybinds": false,
        "enableDangerousActions": false,
        "maxShown": 7,
        "maxWallpapers": 9,
        "specialPrefix": "@",
        "useFuzzy": {
            "apps": false,
            "actions": false,
            "schemes": false,
            "variants": false,
            "wallpapers": false
        },
        "showOnHover": false,
        "favouriteApps": [],
        "hiddenApps": []
    },
    "lock": {
        "recolourLogo": false,
        "hideNotifs": false
    },
    "notifs": {
        "actionOnClick": false,
        "clearThreshold": 0.3,
        "defaultExpireTimeout": 5000,
        "expandThreshold": 20,
        "openExpanded": false,
        "expire": false
    },
    "osd": {
        "enabled": true,
        "enableBrightness": true,
        "enableMicrophone": false,
        "hideDelay": 2000
    },
    "paths": {
        "mediaGif": "root:/assets/bongocat.gif",
        "sessionGif": "root:/assets/kurukuru.gif",
        "noNotifsPic": "root:/assets/dino.png",
        "lockNoNotifsPic": "root:/assets/dino.png",
        "wallpaperDir": "~/Pictures/Wallpapers",
        "lyricsDir": "~/Music/lyrics"
    },
    "services": {
        "audioIncrement": 0.1,
        "brightnessIncrement": 0.1,
        "maxVolume": 1.0,
        "defaultPlayer": "Spotify",
        "gpuType": "",
        "playerAliases": [{ "from": "com.github.th_ch.youtube_music", "to": "YT Music" }],
        "weatherLocation": "",
        "useFahrenheit": false,
        "useFahrenheitPerformance": false,
        "useTwelveHourClock": false,
        "smartScheme": true,
        "visualiserBars": 45
    },
    "session": {
        "dragThreshold": 30,
        "enabled": true,
        "vimKeybinds": false,
        "icons": {
            "logout": "logout",
            "shutdown": "power_settings_new",
            "hibernate": "downloading",
            "reboot": "cached"
        },
        "commands": {
            "logout": ["loginctl", "terminate-user", ""],
            "shutdown": ["systemctl", "poweroff"],
            "hibernate": ["systemctl", "hibernate"],
            "reboot": ["systemctl", "reboot"]
        }
    },
    "sidebar": {
        "dragThreshold": 80,
        "enabled": true
    },
    "utilities": {
        "enabled": true,
        "maxToasts": 4,
        "toasts": {
            "audioInputChanged": true,
            "audioOutputChanged": true,
            "capsLockChanged": true,
            "chargingChanged": true,
            "configLoaded": true,
            "dndChanged": true,
            "gameModeChanged": true,
            "kbLayoutChanged": true,
            "kbLimit": true,
            "numLockChanged": true,
            "vpnChanged": true,
            "nowPlaying": false
        },
        "vpn": {
            "enabled": true,
            "provider": [
                {
                    "name": "wireguard",
                    "interface": "your-connection-name",
                    "displayName": "Wireguard (Your VPN)",
                    "enabled": false
                }
            ]
        },
        "quickToggles": [
            {
                "id": "wifi",
                "enabled": true
            },
            {
                "id": "bluetooth",
                "enabled": true
            },
            {
                "id": "mic",
                "enabled": true
            },
            {
                "enabled": true,
                "id": "settings"
            },
            {
                "id": "gameMode",
                "enabled": true
            },
            {
                "id": "dnd",
                "enabled": true
            },
            {
                "id": "vpn",
                "enabled": true
            }
        ]
    }
}
```

</details>

### Advanced configuration

> [!WARNING]
> Do NOT change any of these options if you do not know what you are doing. These options control the
> tokens used internally within the shell, and can cause visual issues if changed. The existence of
> the options are also not guaranteed across versions, and may change or be removed without notice.

A separate `~/.config/Creomnia/shell-tokens.json` file allows editing the internal tokens without
touching the source code of the shell. These tokens affect, for example, individual rounding,
spacing, padding, font size, animation duration and easing curves tokens, and the sizes of certain
components. The appearance scale values in `shell.json` are multiplied against these base
token values to produce the final computed values.

Per-monitor token overrides are also available at
`~/.config/Creomnia/monitors/<screen-name>/shell-tokens.json`.

### Home Manager Module

For NixOS users, a home manager module is also available.

<details><summary><code>home.nix</code></summary>

```nix
programs.creomnia = {
  enable = true;
  systemd = {
    enable = false; # if you prefer starting from your compositor
    target = "graphical-session.target";
    environment = [];
  };
  settings = {
    bar.status = {
      showBattery = false;
    };
    paths.wallpaperDir = "~/Images";
  };
  cli = {
    enable = true; # Also add creomnia-cli to path
    settings = {
      theme.enableGtk = false;
    };
  };
};
```

The module automatically adds Creomnia shell to the path with **full functionality**. The CLI is not required, however you have the option to enable and configure it.

</details>

## FAQ

### My screen is flickering, help pls!

Try disabling VRR in the hyprland config. You can do this by adding the following to `~/.config/Creomnia/hypr-user.conf`:

```conf
misc {
    vrr = 0
}
```

### I want to make my own changes to the hyprland config!

You can add your custom hyprland configs to `~/.config/creomnia/hypr-user.conf`.

### I want to make my own changes to other stuff!

See the [manual installation](https://github.com/creomnia-dots/shell?tab=readme-ov-file#manual-installation) section
for the corresponding repo.

### I want to disable XXX feature!

Please read the [configuring](https://github.com/creomnia-dots/shell?tab=readme-ov-file#configuring) section in the readme.
If there is no corresponding option, make feature request.

### How do I make my colour scheme change with my wallpaper?

Set a wallpaper via the launcher or `creomnia wallpaper` and set the scheme to the dynamic scheme via the launcher
or `creomnia scheme set`. e.g.

```sh
creomnia wallpaper -f <path/to/file>
creomnia scheme set -n dynamic
```

### My wallpapers aren't showing up in the launcher!

The launcher pulls wallpapers from `~/Pictures/Wallpapers` by default. You can change this in the config. Additionally,
the launcher only shows an odd number of wallpapers at one time. If you only have 2 wallpapers, consider getting more
(or just putting one).


yay -S quickshell-git libcava 
sudo pacman -S --needed ddcutil brightnessctl networkmanager lm_sensors fish aubio libpipewire glibc gcc-libs ttf-material-symbols-variable (material-symbols-font) ttf-cascadia-code-nerd libqalculate cmake ninja
