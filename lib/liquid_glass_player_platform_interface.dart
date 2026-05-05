import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'liquid_glass_player_method_channel.dart';

abstract class LiquidGlassPlayerPlatform extends PlatformInterface {
  /// Constructs a LiquidGlassPlayerPlatform.
  LiquidGlassPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static LiquidGlassPlayerPlatform _instance = MethodChannelLiquidGlassPlayer();

  /// The default instance of [LiquidGlassPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelLiquidGlassPlayer].
  static LiquidGlassPlayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LiquidGlassPlayerPlatform] when
  /// they register themselves.
  static set instance(LiquidGlassPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

}
