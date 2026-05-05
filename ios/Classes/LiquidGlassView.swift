import SwiftUI
import AVKit
import Foundation
import Flutter

// MARK: - Native Video Player Wrapper (Dengan Kontrol Bawaan)
struct NativeVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    let gravity: AVLayerVideoGravity
    let showControls: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true // Kembalikan ke true agar kontrol native muncul
        controller.videoGravity = gravity
        controller.allowsPictureInPicturePlayback = true
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.videoGravity = gravity
    }
}


// MARK: - Pendukung Efek Kaca
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct LiquidGlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    BlurView(style: .systemUltraThinMaterial)
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .clear, .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
    }
}

// MARK: - View Utama
struct LiquidGlassView: View {
    let videoUrl: String
    let messenger: FlutterBinaryMessenger
    let showControls: Bool
    let autoPlay: Bool
    let autoReplay: Bool
    
    @State private var player: AVPlayer
    @State private var isLandscape = false
    @State private var videoGravity: AVLayerVideoGravity = .resizeAspect
    
    private var channel: FlutterMethodChannel {
        return FlutterMethodChannel(name: "liquid_glass_player_controls", binaryMessenger: messenger)
    }

    init(videoUrl: String, messenger: FlutterBinaryMessenger, showControls: Bool = false, autoPlay: Bool = true, autoReplay: Bool = true) {
        self.videoUrl = videoUrl
        self.messenger = messenger
        self.showControls = showControls
        self.autoPlay = autoPlay
        self.autoReplay = autoReplay
        let playerItem = AVPlayerItem(url: URL(string: videoUrl) ?? URL(string: "about:blank")!)
        self._player = State(initialValue: AVPlayer(playerItem: playerItem))
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            NativeVideoPlayer(player: player, gravity: videoGravity, showControls: showControls)
                .modifier(LiquidGlassModifier())
                .padding(showControls ? 0 : 5)
            
            // Custom Landscape Toggle Button
            Button(action: {
                isLandscape.toggle()
                channel.invokeMethod("toggleFullScreen", arguments: isLandscape)
            }) {
                HStack {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(BlurView(style: .systemThinMaterialDark).opacity(0.8))
                .clipShape(Capsule())
                .shadow(radius: 5)
            }
            .padding(.leading, 20)
            .padding(.bottom, 40)
        }
        .background(Color.black)
        .ignoresSafeArea()
        .onAppear {
            setupPlayer()
        }
    }

    private func setupPlayer() {
        if autoPlay {
            player.play()
        }
        
        if autoReplay {
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                player.seek(to: .zero)
                player.play()
            }
        }
    }
}
