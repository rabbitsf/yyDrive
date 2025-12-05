import SwiftUI
import QuickLook
import Photos
import UIKit

// MARK: - Zoomable Image View
struct ZoomableImageView: View {
    let image: UIImage
    let orientation: UIDeviceOrientation
    @Binding var scale: CGFloat
    @Binding var lastScale: CGFloat
    @Binding var offset: CGSize
    @Binding var lastOffset: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            let imageAspectRatio = image.size.width / image.size.height
            let viewAspectRatio = geometry.size.width / geometry.size.height
            let fittedSize: CGSize = {
                if imageAspectRatio > viewAspectRatio {
                    // Image is wider - fit to width
                    return CGSize(width: geometry.size.width, height: geometry.size.width / imageAspectRatio)
                } else {
                    // Image is taller - fit to height
                    return CGSize(width: geometry.size.height * imageAspectRatio, height: geometry.size.height)
                }
            }()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(orientation == .landscapeLeft ? 90 : orientation == .landscapeRight ? -90 : orientation == .portraitUpsideDown ? 180 : 0))
                .frame(width: fittedSize.width, height: fittedSize.height)
                .scaleEffect(scale)
                .offset(x: offset.width, y: offset.height)
                .gesture(
                    SimultaneousGesture(
                        // Pinch to zoom
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                let newScale = scale * delta
                                scale = min(max(newScale, 1.0), 5.0)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                                // Constrain scale between 1.0 and 5.0
                                scale = min(max(scale, 1.0), 5.0)
                                // Reset offset if scale is back to 1.0
                                if scale == 1.0 {
                                    withAnimation {
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                } else {
                                    // Constrain offset when zoom ends
                                    constrainOffset(for: fittedSize, in: geometry.size)
                                }
                            },
                        // Drag to pan (only when zoomed)
                        DragGesture()
                            .onChanged { value in
                                if scale > 1.0 {
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                            }
                            .onEnded { _ in
                                lastOffset = offset
                                // Constrain offset to keep image visible
                                constrainOffset(for: fittedSize, in: geometry.size)
                            }
                    )
                )
                .onTapGesture(count: 2) {
                    // Double tap to reset zoom or zoom to 2x
                    withAnimation {
                        if scale > 1.0 {
                            scale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2.0
                        }
                    }
                }
        }
    }
    
    func constrainOffset(for imageSize: CGSize, in viewSize: CGSize) {
        let scaledImageSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let maxOffsetX = max(0, (scaledImageSize.width - viewSize.width) / 2)
        let maxOffsetY = max(0, (scaledImageSize.height - viewSize.height) / 2)
        
        offset = CGSize(
            width: min(max(offset.width, -maxOffsetX), maxOffsetX),
            height: min(max(offset.height, -maxOffsetY), maxOffsetY)
        )
        lastOffset = offset
    }
}

struct FileDetailView: View {
    var filePath: String
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var videoManager: VideoManager
    @EnvironmentObject var fileManager: FileManagerHelper

    // Holds the UIImage if we detect this file is an image
    @State private var loadedImage: UIImage?
    
    // Orientation support
    @State private var orientation = UIDeviceOrientation.portrait
    
    // File conversion
    @State private var showConversionSheet = false
    
    // Share sheet
    @State private var showShareSheet = false
    
    // Zoom and pan support for images
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        // Path to the file in Documents
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(filePath)

        ZStack {
            // Light blue gradient background (same as landing page and folder view)
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.7, green: 0.85, blue: 0.95),
                            Color(red: 0.75, green: 0.88, blue: 0.97),
                            Color(red: 0.8, green: 0.9, blue: 0.98)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .zIndex(-1)
            
            // Nature decorative background elements - second layer
            GeometryReader { geo in
                Group {
                    // Trees
                    Image(systemName: "tree.fill")
                        .font(.system(size: 45))
                        .foregroundColor(.green.opacity(0.35))
                        .position(x: geo.size.width * 0.1, y: geo.size.height * 0.15)
                    
                    Image(systemName: "tree")
                        .font(.system(size: 38))
                        .foregroundColor(.green.opacity(0.3))
                        .position(x: geo.size.width * 0.9, y: geo.size.height * 0.2)
                    
                    Image(systemName: "tree.fill")
                        .font(.system(size: 42))
                        .foregroundColor(.green.opacity(0.32))
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.25)
                    
                    // Clouds
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.5))
                        .position(x: geo.size.width * 0.25, y: geo.size.height * 0.1)
                    
                    Image(systemName: "cloud")
                        .font(.system(size: 35))
                        .foregroundColor(.white.opacity(0.45))
                        .position(x: geo.size.width * 0.75, y: geo.size.height * 0.12)
                    
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.white.opacity(0.48))
                        .position(x: geo.size.width * 0.55, y: geo.size.height * 0.08)
                    
                    Image(systemName: "cloud")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.42))
                        .position(x: geo.size.width * 0.15, y: geo.size.height * 0.05)
                    
                    // Leaves
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green.opacity(0.4))
                        .position(x: geo.size.width * 0.15, y: geo.size.height * 0.4)
                    
                    Image(systemName: "leaf")
                        .font(.system(size: 28))
                        .foregroundColor(.green.opacity(0.35))
                        .position(x: geo.size.width * 0.85, y: geo.size.height * 0.45)
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.green.opacity(0.38))
                        .position(x: geo.size.width * 0.3, y: geo.size.height * 0.5)
                    
                    Image(systemName: "leaf")
                        .font(.system(size: 26))
                        .foregroundColor(.green.opacity(0.33))
                        .position(x: geo.size.width * 0.7, y: geo.size.height * 0.55)
                    
                    // Sun
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow.opacity(0.4))
                        .position(x: geo.size.width * 0.85, y: geo.size.height * 0.08)
                    
                    Image(systemName: "sun.max")
                        .font(.system(size: 45))
                        .foregroundColor(.yellow.opacity(0.35))
                        .position(x: geo.size.width * 0.05, y: geo.size.height * 0.12)
                    
                    // Water drops
                    Image(systemName: "drop.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.blue.opacity(0.4))
                        .position(x: geo.size.width * 0.2, y: geo.size.height * 0.65)
                    
                    Image(systemName: "drop")
                        .font(.system(size: 22))
                        .foregroundColor(.blue.opacity(0.35))
                        .position(x: geo.size.width * 0.8, y: geo.size.height * 0.7)
                    
                    Image(systemName: "drop.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue.opacity(0.38))
                        .position(x: geo.size.width * 0.4, y: geo.size.height * 0.75)
                    
                    Image(systemName: "drop")
                        .font(.system(size: 20))
                        .foregroundColor(.blue.opacity(0.33))
                        .position(x: geo.size.width * 0.6, y: geo.size.height * 0.68)
                    
                    // Flowers
                    Image(systemName: "camera.macro")
                        .font(.system(size: 30))
                        .foregroundColor(.pink.opacity(0.4))
                        .position(x: geo.size.width * 0.12, y: geo.size.height * 0.85)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundColor(.yellow.opacity(0.4))
                        .position(x: geo.size.width * 0.88, y: geo.size.height * 0.88)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 26))
                        .foregroundColor(.yellow.opacity(0.35))
                        .position(x: geo.size.width * 0.35, y: geo.size.height * 0.9)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow.opacity(0.38))
                        .position(x: geo.size.width * 0.65, y: geo.size.height * 0.82)
                    
                    // Birds
                    Image(systemName: "bird.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.brown.opacity(0.4))
                        .position(x: geo.size.width * 0.25, y: geo.size.height * 0.3)
                    
                    Image(systemName: "bird")
                        .font(.system(size: 25))
                        .foregroundColor(.brown.opacity(0.35))
                        .position(x: geo.size.width * 0.65, y: geo.size.height * 0.35)
                    
                    // Stars
                    Image(systemName: "star.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.purple.opacity(0.4))
                        .position(x: geo.size.width * 0.45, y: geo.size.height * 0.6)
                    
                    Image(systemName: "star")
                        .font(.system(size: 27))
                        .foregroundColor(.purple.opacity(0.35))
                        .position(x: geo.size.width * 0.18, y: geo.size.height * 0.7)
                }
            }
            .allowsHitTesting(false)
            
            VStack {
                // Check if this is a media file
                let fileName = fileURL.lastPathComponent
                let isMedia = fileManager.isMediaFile(fileName)
                let isVideo = fileManager.isVideoFile(fileName)
                let isAudio = fileManager.isAudioFile(fileName)
                
                if isMedia {
                // For media files, show a play button that navigates to the player
                VStack(spacing: 30) {
                    if isVideo {
                        Image(systemName: "film.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.purple)
                        Text(fileName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        NavigationLink(destination: VideoPlayerView(
                            folderPath: getFolderPath(from: filePath),
                            initialSongName: fileName,
                            videoManager: videoManager
                        )) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Play Video")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                    } else if isAudio {
                        Image(systemName: "music.note")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        Text(fileName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        NavigationLink(destination: PlayerView(
                            folderPath: getFolderPath(from: filePath),
                            initialSongName: fileName,
                            audioManager: audioManager
                        )) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Play Audio")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let loadedImage = loadedImage {
                    // Display the image with zoom and pan support
                    ZoomableImageView(image: loadedImage, orientation: orientation, scale: $scale, lastScale: $lastScale, offset: $offset, lastOffset: $lastOffset)
                } else {
                    // For non-image files (or if loading fails), use QuickLook
                    // QuickLook handles orientation automatically, but we can add rotation for images
                    QLPreviewRepresented(fileURL: fileURL)
                }
            }
        }
        // When this view appears, check if it's an image
        .onAppear {
            if isImageFile(fileURL) {
                // Attempt to load as UIImage
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    loadedImage = image
                }
            }
            // Reset zoom when image changes
            scale = 1.0
            lastScale = 1.0
            offset = .zero
            lastOffset = .zero
            // Listen for orientation changes
            NotificationCenter.default.addObserver(
                forName: UIDevice.orientationDidChangeNotification,
                object: nil,
                queue: .main
            ) { _ in
                orientation = UIDevice.current.orientation
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        // Add toolbar buttons
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Share button
                Button(action: {
                    showShareSheet = true
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .foregroundColor(.blue)
                }
                
                // Convert button (for supported file types)
                if canConvertFile(fileURL) {
                    Button(action: {
                        showConversionSheet = true
                    }) {
                        Label("Convert", systemImage: "arrow.triangle.2.circlepath")
                            .foregroundColor(.blue)
                    }
                }
                
                // Orientation toggle button
                Button(action: {
                    if orientation == .portrait || orientation == .portraitUpsideDown {
                        orientation = .landscapeLeft
                    } else {
                        orientation = .portrait
                    }
                }) {
                    Image(systemName: orientation == .portrait || orientation == .portraitUpsideDown ? "arrow.turn.up.right" : "arrow.turn.down.right")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showConversionSheet) {
            FileConversionView(sourceFilePath: filePath)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [fileURL])
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("FileConverted"))) { _ in
            // Refresh file manager when conversion completes
            fileManager.objectWillChange.send()
        }
        .navigationTitle("File Viewer")
    }

    // MARK: - Check if file extension is an image
    func isImageFile(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        // Extended image format support
        let supportedExts = ["png", "jpg", "jpeg", "gif", "heic", "heif", "tiff", "tif", "bmp", "webp", "ico", "svg", "raw", "cr2", "nef", "orf", "sr2", "dng"]
        return supportedExts.contains(ext)
    }
    
    // MARK: - Check if file is a supported document (QuickLook supports many formats)
    func isSupportedDocument(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        // QuickLook natively supports: PDF, RTF, Text, Office docs (if available), iWork, etc.
        let documentExts = ["pdf", "txt", "rtf", "rtfd", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "pages", "numbers", "key", "csv", "html", "htm", "xml", "json", "md", "markdown", "log", "plist"]
        return documentExts.contains(ext)
    }

    // MARK: - Save image to user's Photo Library
    func saveImageToPhotos(_ image: UIImage) {
        // Request permission if needed
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                return
            }
            // Write to Photos
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if success {
                    print("Saved image to Photos.")
                } else if let error = error {
                    print("Error saving photo: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper to extract folder path from file path
    func getFolderPath(from filePath: String) -> String {
        // Remove the filename to get the folder path
        let components = filePath.components(separatedBy: "/")
        if components.count > 1 {
            return components.dropLast().joined(separator: "/")
        }
        return ""
    }
    
    // MARK: - Constrain offset to keep image visible when zoomed
    func constrainOffset(for imageSize: CGSize, in viewSize: CGSize) {
        let scaledImageSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        let maxOffsetX = max(0, (scaledImageSize.width - viewSize.width) / 2)
        let maxOffsetY = max(0, (scaledImageSize.height - viewSize.height) / 2)
        
        offset = CGSize(
            width: min(max(offset.width, -maxOffsetX), maxOffsetX),
            height: min(max(offset.height, -maxOffsetY), maxOffsetY)
        )
        lastOffset = offset
    }
    
    // MARK: - Check if file can be converted
    func canConvertFile(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        // Support conversion for images, PDFs, text files, Office formats, and Google Docs/Sheets
        let imageFormats = ["png", "jpg", "jpeg", "gif", "heic", "heif", "tiff", "tif", "bmp", "webp"]
        let textFormats = ["txt", "rtf", "html", "htm"]
        let officeFormats = ["docx", "xlsx", "pptx", "doc", "xls", "ppt"]
        let googleFormats = ["gdoc", "gsheet"]
        return imageFormats.contains(ext) || ext == "pdf" || textFormats.contains(ext) || officeFormats.contains(ext) || googleFormats.contains(ext)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

