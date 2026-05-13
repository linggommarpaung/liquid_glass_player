import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A premium video player widget with a glassmorphism effect.
///
/// Currently supports iOS only.
class LiquidGlassPlayer extends StatefulWidget {
  /// The URL of the video to play.
  final String videoUrl;

  /// Whether to show native iOS playback controls.
  final bool showControls;

  /// Whether to start playing the video automatically.
  final bool autoPlay;

  /// Whether to loop the video after it finishes.
  final bool autoReplay;

  const LiquidGlassPlayer({
    super.key,
    required this.videoUrl,
    this.showControls = false,
    this.autoPlay = true,
    this.autoReplay = true,
  });

  @override
  State<LiquidGlassPlayer> createState() => _LiquidGlassPlayerState();
}

class _LiquidGlassPlayerState extends State<LiquidGlassPlayer> {
  // 1. Definisikan channel dengan nama yang sama seperti di Swift
  static const MethodChannel _channel = MethodChannel(
    'liquid_glass_player_controls',
  );

  @override
  void initState() {
    super.initState();

    // 2. TAMBAHKAN DI SINI
    _channel.setMethodCallHandler((call) async {
      if (call.method == "toggleFullScreen") {
        bool isLandscape = call.arguments as bool;

        if (isLandscape) {
          // Memaksa layar menjadi Landscape
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
        } else {
          // Memaksa layar kembali menjadi Portrait (Tegak)[cite: 7]
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        }
      }
    });
  }

  @override
  void dispose() {
    // 3. PENTING: Kembalikan ke portrait saat widget ditutup agar tidak merusak UI halaman lain[cite: 7]
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. Pastikan ID viewType sinkron dengan yang didaftarkan di Swift[cite: 7]
    return UiKitView(
      viewType: 'liquid_glass_player_view',
      layoutDirection: TextDirection.ltr,
      creationParams: {
        "videoUrl": widget.videoUrl,
        "showControls": widget.showControls,
        "autoPlay": widget.autoPlay,
        "autoReplay": widget.autoReplay,
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
