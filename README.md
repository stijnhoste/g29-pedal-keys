# G29 Pedal Keys

Map Logitech G29 racing wheel pedals to keyboard shortcuts on macOS. Perfect for hands-free push-to-talk with apps like [BetterDictation](https://betterdictation.com/).

## Features

- Lightweight (~120KB binary, ~5MB RAM)
- No dependencies - pure Swift using native macOS APIs
- Configurable pedal, key, and modifier mapping
- Runs as a background service (launchd)
- Auto-starts on login

## Requirements

- macOS 12+ (Monterey or later)
- Logitech G29 Driving Force Racing Wheel
- Swift 5.9+ (included with Xcode Command Line Tools)

## Installation

```bash
# Clone the repo
git clone https://github.com/yourusername/g29-pedal-keys.git
cd g29-pedal-keys

# Build
swift build -c release

# Install binary and service
./install.sh
```

### Permissions

After installation, grant these permissions in **System Settings > Privacy & Security**:

1. **Input Monitoring** - for reading G29 pedal input
2. **Accessibility** - for simulating keyboard shortcuts

Add the binary at `~/.local/bin/g29-pedal-keys` to both lists.

## Configuration

Edit `~/.config/g29-pedal-keys/config.json`:

```json
{
  "pedal": "clutch",
  "key": "d",
  "modifiers": ["control"],
  "pressThreshold": 50,
  "releaseThreshold": 30,
  "verbose": false
}
```

### Options

| Option | Values | Description |
|--------|--------|-------------|
| `pedal` | `"gas"`, `"brake"`, `"clutch"` | Which pedal triggers the key |
| `key` | `"a"`-`"z"`, `"0"`-`"9"`, `"f1"`-`"f12"`, `"space"`, `"return"` | Key to simulate |
| `modifiers` | `["control"]`, `["command"]`, `["option"]`, `["shift"]` | Modifier keys (can combine) |
| `pressThreshold` | `0`-`255` | Pedal value to trigger key down |
| `releaseThreshold` | `0`-`255` | Pedal value to trigger key up |
| `verbose` | `true`/`false` | Enable debug logging |

## Usage

### Manual testing

```bash
g29-pedal-keys --verbose
```

### Service commands

```bash
# View logs
tail -f /tmp/g29-pedal-keys.log

# Stop service
launchctl unload ~/Library/LaunchAgents/com.user.g29pedalkeys.plist

# Start service
launchctl load ~/Library/LaunchAgents/com.user.g29pedalkeys.plist

# Restart after config change
launchctl unload ~/Library/LaunchAgents/com.user.g29pedalkeys.plist
launchctl load ~/Library/LaunchAgents/com.user.g29pedalkeys.plist
```

### Uninstall

```bash
./uninstall.sh
```

## How it works

1. **HIDManager** connects to the G29 via IOKit HID APIs
2. **PedalMapping** monitors pedal values with hysteresis to prevent jitter
3. **KeySimulator** posts keyboard events via CoreGraphics CGEvent API

The hysteresis (separate press/release thresholds) prevents rapid toggling when the pedal hovers near a single threshold value.

## License

MIT
