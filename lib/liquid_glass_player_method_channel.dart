import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'liquid_glass_player_platform_interface.dart';

/// An implementation of [LiquidGlassPlayerPlatform] that uses method channels.
class MethodChannelLiquidGlassPlayer extends LiquidGlassPlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('liquid_glass_player');

}
