import Flutter
import UIKit
import AVFoundation

public class LiquidGlassPlayerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Konfigurasi Audio Session agar suara tetap muncul meskipun HP dalam mode silent
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try AVAudioSession.sharedInstance().setActive(true)
    } catch {
        print("LiquidGlassPlayer: Gagal mengatur AVAudioSession: \(error)")
    }

    // 1. Daftarkan Method Channel standar
    let channel = FlutterMethodChannel(name: "liquid_glass_player", binaryMessenger: registrar.messenger())
    let instance = LiquidGlassPlayerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    // 2. DAFTARKAN FACTORY UNTUK UI (Ini yang wajib ada agar view muncul)
    let factory = LiquidGlassFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "liquid_glass_player_view")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Handle pesan dari Dart jika ada (misal: ambil versi sistem)
    if (call.method == "getPlatformVersion") {
      result("iOS " + UIDevice.current.systemVersion)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}
