# Gesture Cheatsheet (Omarchy shell plugin)

A bar button for [Omarchy](https://omarchy.org/) (Quickshell) that opens a
panel cheat sheet for the Windows-style touchpad gestures set up by
[omarchy-gestures](https://github.com/mittai17/omarchy-gestures).

This is an **Omarchy shell plugin** (`bar-widget` kind). It just displays
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
- This plugin only opens a URL and copies text to the clipboard; it does not
  modify your Hyprland configuration.

## License

MIT — see [LICENSE](LICENSE).