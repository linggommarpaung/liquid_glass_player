import SwiftUI
import AVKit
import Foundation
import Flutter

// MARK: - Native Video Player Wrapper
struct NativeVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    let gravity: AVLayerVideoGravity
    let showControls: Bool
    @Binding var isLandscape: Bool

    class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        var parent: NativeVideoPlayer
        init(_ parent: NativeVideoPlayer) {
            self.parent = parent
        }
        
        func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            // Sinkronkan status saat user keluar dari full screen native (klik Done/X)
            DispatchQueue.main.async {
                withAnimation(.spring()) {
                    self.parent.isLandscape = false
                }
            }
            
            // Tunggu sampai animasi transisi selesai baru paksa Play
            coordinator.animate(alongsideTransition: nil) { _ in
                self.parent.player.play()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = showControls
        controller.videoGravity = gravity
        controller.allowsPictureInPicturePlayback = true
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player != player {
            uiViewController.player = player
        }
        uiViewController.videoGravity = gravity
        uiViewController.showsPlaybackControls = showControls
    }
}

// MARK: - Ambient Glow View
struct AmbientGlowView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color.black
            
            // Animating "Liquid" Blobs
            Group {
                Circle()
                    .fill(Color.indigo.opacity(0.6))
                    .frame(width: 400, height: 400)
                    .offset(x: animate ? 100 : -100, y: animate ? -100 : 100)
                    .blur(radius: 80)
                
                Circle()
                    .fill(Color.purple.opacity(0.5))
                    .frame(width: 350, height: 350)
                    .offset(x: animate ? -150 : 150, y: animate ? 150 : -150)
                    .blur(radius: 90)
                
                Circle()
                    .fill(Color.blue.opacity(0.4))
                    .frame(width: 450, height: 450)
                    .offset(x: animate ? 50 : -50, y: animate ? 150 : -50)
                    .blur(radius: 100)
            }
            .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear {
            animate = true
        }
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
    let showEffect: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    if showEffect {
                        // Deep Blur Material
                        BlurView(style: .systemUltraThinMaterialDark)
                        
                        // Inner Sheen / Refraction
                        RoundedRectangle(cornerRadius: 32)
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.1), .clear, .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Border Highlight
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.1),
                                        .white.opacity(0.3),
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: showEffect ? 32 : 0))
            .shadow(color: Color.black.opacity(showEffect ? 0.5 : 0), radius: showEffect ? 20 : 0, x: 0, y: showEffect ? 15 : 0)
            .overlay(
                Group {
                    if showEffect {
                        // Specular highlight at the top edge
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            .padding(0.5)
                            .mask(
                                LinearGradient(colors: [.white, .clear, .clear], startPoint: .top, endPoint: .bottom)
                            )
                    }
                }
                .allowsHitTesting(false)
            )
    }
}
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
        let avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer.preventsDisplaySleepDuringVideoPlayback = true
        self._player = State(initialValue: avPlayer)
        
        // Jalankan setup audio sekali saja di sini
        DispatchQueue.global(qos: .userInteractive).async {
            let audioSession = AVAudioSession.sharedInstance()
            if audioSession.category != .playback {
                try? audioSession.setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers, .allowAirPlay])
                try? audioSession.setActive(true)
            }
        }
    }

    var body: some View {
        ZStack {
            // Background Liquid Ambient Light
            AmbientGlowView()
                .ignoresSafeArea()
            
            ZStack(alignment: .bottomLeading) {
                // Gunakan satu instance Player agar tidak pause saat rotasi
                NativeVideoPlayer(player: player, gravity: isLandscape ? .resizeAspect : videoGravity, showControls: showControls, isLandscape: $isLandscape)
                    .modifier(LiquidGlassModifier(showEffect: !isLandscape))
                    .aspectRatio(isLandscape ? nil : 16/9, contentMode: .fit)
                    .padding(isLandscape ? 0 : 20)
                    .ignoresSafeArea(isLandscape ? .all : [])
                
                if !showControls {
                    // Custom Landscape Toggle Button
                    Button(action: {
                        withAnimation(.spring()) {
                            isLandscape.toggle()
                        }
                        channel.invokeMethod("toggleFullScreen", arguments: isLandscape)
                    }) {
                        HStack {
                            Image(systemName: isLandscape ? "arrow.down.right.and.arrow.up.left" : "viewfinder")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(12)
                        .background(BlurView(style: .systemThinMaterialDark).opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 5)
                    }
                    .padding(.leading, isLandscape ? 40 : 35)
                    .padding(.bottom, isLandscape ? 40 : 35)
                }
            }
        }
        .onAppear {
            if autoPlay && player.rate == 0 {
                player.play()
            }
        }
        .onDisappear {
            // Biarkan mengalir
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)) { _ in
            if autoReplay {
                player.seek(to: .zero)
                player.play()
            }
        }
        .simultaneousGesture(
            DragGesture()
                .onEnded { value in
                    if isLandscape {
                        let horizontalDrag = abs(value.translation.width)
                        let verticalDrag = abs(value.translation.height)
                        
                        if horizontalDrag > 100 || verticalDrag > 100 {
                            withAnimation(.spring()) {
                                isLandscape = false
                            }
                            channel.invokeMethod("toggleFullScreen", arguments: false)
                        }
                    }
                }
        )
    }
}

