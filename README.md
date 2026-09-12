# Gesture Cheatsheet (Omarchy shell plugin)

![Gesture Cheatsheet](preview.png)

A bar button for [Omarchy](https://omarchy.org/) (Quickshell) that opens a
panel cheat sheet for the Windows-style touchpad gestures set up by
[omarchy-gestures](https://github.com/mittai17/omarchy-gestures).

This is an **Omarchy shell plugin** (`bar-widget` kind). It displays
information and links out — the actual gesture wiring lives in Hyprland config
and is installed by the `omarchy-gestures` repo it points to.

## What the panel shows

| Gesture | Action |
| --- | --- |
| 4-finger left / right | Switch workspace |
| 4-finger down / up | Minimize all / restore |
| 3-finger left / right | Cycle windows (Alt-Tab) |
| 3-finger up | App menu |

The panel also carries:

- The `omarchy-gestures` install command, with a **Copy install command** button (`wl-copy`).
- An **Open repo** button that opens the source repository in your browser (`xdg-open`).

## Customize

Click **Customize** in the panel to edit the cheat sheet. Everything is stored
in the widget's own entry in `~/.config/omarchy/shell.json` and restored on
restart:

- **Show / hide each gesture** — toggle any row (4-finger workspace switch,
  minimize all, Alt-Tab cycle, app menu).
- **Install section** — show or hide the repo/install-command footer.
- **Bar label** — change the button text in the bar (default `Gestures`).
- **Reset to defaults** — clear the customizations.

Settings keys (in case you want to edit `shell.json` by hand):

| Key | Default | Meaning |
| --- | --- | --- |
| `showWorkspaceSwitch` | `true` | Show "4-finger ← → : Switch workspace" |
| `showMinimizeAll` | `true` | Show "4-finger ↓ ↑ : Minimize all / restore" |
| `showCycleWindows` | `true` | Show "3-finger ← → : Cycle windows (Alt-Tab)" |
| `showAppMenu` | `true` | Show "3-finger ↑ : App menu" |
| `showInstallSection` | `true` | Show the install command / buttons footer |
| `barLabel` | `Gestures` | Text on the bar button |

## Install

```sh
omarchy plugin add https://github.com/mittai17/omarchy-gesture-cheatsheet.git --enable
```

Left click the **Gestures** button in the bar to open the panel; Escape or
clicking elsewhere closes it. You can also summon it with:

```sh
omarchy-shell shell summon io.github.mittai17.gesture-cheatsheet '{}'
```

## The companion repo

The gestures themselves are configured in Hyprland, not in the shell, so they
ship as a Hyprland config add-on:

- https://github.com/mittai17/omarchy-gestures

## Remove

```sh
omarchy plugin remove io.github.mittai17.gesture-cheatsheet --yes
```

## Notes

- Plugins run unsandboxed inside your long-running `omarchy-shell` process.
  Review the code before you enable it.
- This plugin only opens a URL, copies text to the clipboard, and stores its
  own display settings in `shell.json`; it does not modify Hyprland
  configuration.

## License

MIT — see [LICENSE](LICENSE).