import Flutter
import UIKit
import SwiftUI

// 1. Factory Class
class LiquidGlassFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return LiquidGlassNativeView(frame: frame, viewId: viewId, messenger: messenger, arguments: args)
    }
    
    // Memberikan izin akses parameter dari Dart (Opsional)
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
            return FlutterStandardMessageCodec.sharedInstance()
        }
}

// 2. Native View Class
class LiquidGlassNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var hostingController: UIHostingController<LiquidGlassView>?

    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, arguments args: Any?) {
        let params = args as? [String: Any]
        let videoUrl = params?["videoUrl"] as? String ?? ""
        let showControls = params?["showControls"] as? Bool ?? false
        let autoPlay = params?["autoPlay"] as? Bool ?? true
        let autoReplay = params?["autoReplay"] as? Bool ?? true

        // Kirim messenger ke LiquidGlassView
        let swiftUIView = LiquidGlassView(
            videoUrl: videoUrl,
            messenger: messenger,
            showControls: showControls,
            autoPlay: autoPlay,
            autoReplay: autoReplay
        )
        
        let hc = UIHostingController(rootView: swiftUIView)
        self.hostingController = hc
        
        _view = hc.view
        _view.frame = frame
        _view.backgroundColor = .clear
        hc.view.backgroundColor = .clear
        
        super.init()
    }

    func view() -> UIView {
        return _view
    }
    
    deinit {
        // Memastikan hosting controller dilepas dan view dihapus
        hostingController?.view.removeFromSuperview()
        hostingController = nil
    }
}
