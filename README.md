# Liquid Glass Player

A premium glassmorphism video player for Flutter (iOS only) that provides a native AVPlayer experience with a sleek, modern, frosted-glass aesthetic.

<p align="center">
  <img src="https://raw.githubusercontent.com/linggommarpaung/liquid_glass_player/main/screenshots/demo.gif" alt="Liquid Glass Player Demo" width="300">
</p>

## Features

- **Glassmorphism Design**: Beautiful "frosted glass" effect on the player container.
- **Native iOS Performance**: Powered by SwiftUI's `AVPlayer` for smooth playback and low battery consumption.
- **Customizable Controls**: Easy toggle for auto-play, auto-replay, and native controls.
- **Auto Orientation**: Smart handling of landscape and portrait modes.

## Installation

Add `liquid_glass_player` to your `pubspec.yaml`:

```yaml
dependencies:
  liquid_glass_player: ^0.0.1
```

## Usage

```dart
import 'package:liquid_glass_player/liquid_glass_player.dart';

// In your widget tree:
SizedBox(
  height: 250,
  child: LiquidGlassPlayer(
    videoUrl: "https://your-video-url.mp4",
    autoPlay: true,
    showControls: true,
  ),
)
```

## Platform Support

| Android | iOS | Web | macOS | Windows | Linux |
| :---: | :---: | :---: | :---: | :---: | :---: |
| ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |

*Note: This plugin currently only supports iOS.*

## License

MIT License. See [LICENSE](LICENSE) for more details.
