# CenterGaze

A DCS World hook that relocates the **command menu**, **radio messages** and **tutorial/system messages** to the center of the viewport — or any custom position you prefer.

Designed for ultrawide monitor users who are tired of turning their head to the edges of the screen to read messages or give commands.

> Passes the DCS multiplayer integrity check.

---

## Background

I wrote this hook because I have a 57" ultrawide monitor with a horizontal resolution of 7680px. Having the command menu and radio messages at the extreme edges of my field of view forced me to constantly turn my head left and right like a fool, losing focus on what was happening in the middle.

---

## Installation

1. Download the latest release zip from the [Releases](../../releases) page
2. Extract the contents into your DCS hooks folder:
   ```
   %USERPROFILE%\Saved Games\DCS\Scripts\Hooks\
   ```
3. Launch DCS **twice**:
   - **First launch**: the hook detects the new configuration and patches the DCS UI files
   - **Second launch**: DCS loads the patched UI files

> **Note:** Every time you change `CenterGaze.cfg`, you need to launch DCS twice for the changes to take effect.

---

## Configuration

The configuration file `CenterGaze.cfg` is auto-generated on first run with sane defaults. Edit it to your preferences.

```lua
-- Command Menu config --
defaultCommandMenu = false
commandMenuOffset  = 0

-- Radio Messages --
defaultRadioMessages = false
radioMessagesOffset  = -450
radioMessagesWidth   = 400

-- Tutorial / System Messages --
defaultSystemMessages = false
systemMessagesOffset  = -450
systemMessagesWidth   = 400
```

### Parameters

#### Command Menu

| Parameter | Type | Default | Description |
|---|---|---|---|
| `defaultCommandMenu` | bool | `false` | Set to `true` to restore the default DCS positioning |
| `commandMenuOffset` | number | `0` | Offset of the left side of the menu container relative to the vertical center axis of the DCS window. `0` = aligned to center axis. Negative = left, positive = right. |

#### Radio Messages

| Parameter | Type | Default | Description |
|---|---|---|---|
| `defaultRadioMessages` | bool | `false` | Set to `true` to restore the default DCS positioning |
| `radioMessagesOffset` | number | `-450` | Offset of the left side of the radio messages container relative to the vertical center axis. |
| `radioMessagesWidth` | number | `400` | Width of the radio messages container in pixels. |

#### Tutorial / System Messages

| Parameter | Type | Default | Description |
|---|---|---|---|
| `defaultSystemMessages` | bool | `false` | Set to `true` to restore the default DCS positioning |
| `systemMessagesOffset` | number | `-450` | Offset of the left side of the system messages container relative to the vertical center axis. |
| `systemMessagesWidth` | number | `400` | Width of the system messages container in pixels. |

---

## How It Works

The hook patches two DCS UI files at startup:

- `Scripts\UI\RadioCommandDialogPanel\CommandMenu.lua` — repositions the command menu
- `Scripts\UI\gameMessages.lua` — repositions radio messages and tutorial/system messages

Before patching, a backup of each original file is saved alongside the hook. The hook automatically re-applies the patch after a DCS update (detected via file modification timestamps) or after any change to `CenterGaze.cfg`.

---

## Notes

- There are no overlap checks between containers — make sure your offsets and widths don't cause them to overlap.
- The hook directory and runtime artifacts (`*.bkp`, `*.t`) are created automatically next to the script file.

---

## Credits

- **Hannibal** — original author
- **Racter** — contributed v0.07 patch adding support for centering tutorial/system messages (`autoScrollTextTrig`)

---

## Changelog

| Date | Version | Description |
|---|---|---|
| 2026-03-18 | v0.07 | Added the ability to center game messages and tutorials (Racter) |
| 2024-06-15 | v0.04 | Fixed typo error |
| 2024-06-13 | v0.03 | Full rewrite with config file support for position and size |
| 2024-06-08 | v0.02 | Minor fix |
| 2024-06-08 | v0.01 | First release |

---

## Contributing

Contributions are welcome! If you want to report a bug, suggest an improvement or submit a patch:

1. **Open an issue** on [GitHub](https://github.com/annibale-x/dcs-center-gaze/issues) describing the problem or idea
2. **Fork** the repository and create a branch for your change
3. **Submit a pull request** with a clear description of what you changed and why

Please keep in mind that this hook targets the DCS World environment, so changes should be tested
against an actual DCS installation before submitting. If you cannot test it yourself, mention it
in the pull request and I will take care of it.

---

## License

This project is released as free software. Use at your own risk.
Feel free to open issues or submit pull requests on [GitHub](https://github.com/annibale-x/dcs-center-gaze).