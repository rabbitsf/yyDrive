import SwiftUI
import UniformTypeIdentifiers
import QuickLook

@main
struct yyDriveApp: App {
    // We need to handle openURL to support saving files from other apps
    @Environment(\.scenePhase) private var scenePhase
    @State private var incomingURL: URL?
    @State private var showFolderPicker = false

    // We use a shared FileManagerHelper across the app so we can import files
    @StateObject private var fileManagerHelper = FileManagerHelper()
    
    // Media managers for audio and video playback
    @StateObject private var audioManager = AudioManager()
    @StateObject private var videoManager = VideoManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fileManagerHelper)
                .environmentObject(audioManager)
                .environmentObject(videoManager)
                // When another app tries to open a file in this app
                .onOpenURL { url in
                    incomingURL = url
                    showFolderPicker = true
                }
                // A sheet to let user pick a folder
                .sheet(isPresented: $showFolderPicker, onDismiss: {
                    // Clean up if needed
                    incomingURL = nil
                }) {
                    if let fileURL = incomingURL {
                        FolderPickerView(fileToImportURL: fileURL)
                            .environmentObject(fileManagerHelper)
                    } else {
                        EmptyView()
                    }
                }
                // Monitor app lifecycle to keep server running
                .onChange(of: scenePhase) { newPhase in
                    handleScenePhaseChange(newPhase)
                }
        }
    }
    
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        let server = WiFiUploadServer.shared
        switch phase {
        case .background:
            // When app goes to background, ensure server keeps running
            if server.isServerRunning {
                print("📱 App entered background, maintaining server...")
            }
        case .inactive:
            // App is inactive but still visible
            break
        case .active:
            // App became active - restart server if it should be running
            if server.isServerRunning {
                print("📱 App became active, verifying server status...")
                // Server should already be running, but verify
            }
        @unknown default:
            break
        }
    }
}
