import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct PhotoPickerView: UIViewControllerRepresentable {
    // Closure to handle the picked items (images and videos)
    var onItemsPicked: ([PhotoPickerItem]) -> Void
    
    // Whether to allow videos
    var allowVideos: Bool = true

    func makeCoordinator() -> Coordinator {
        Coordinator(onItemsPicked: onItemsPicked, allowVideos: allowVideos)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0 // 0 = unlimited
        
        // Support both images and videos
        if allowVideos {
            config.filter = .any(of: [.images, .videos])
        } else {
            config.filter = .images
        }

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates needed
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onItemsPicked: ([PhotoPickerItem]) -> Void
        var allowVideos: Bool
        
        init(onItemsPicked: @escaping ([PhotoPickerItem]) -> Void, allowVideos: Bool) {
            self.onItemsPicked = onItemsPicked
            self.allowVideos = allowVideos
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true, completion: nil)

            var pickedItems: [PhotoPickerItem] = []
            let dispatchGroup = DispatchGroup()

            for result in results {
                dispatchGroup.enter()
                
                // Check if it's a video
                if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    // Handle video
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                        defer { dispatchGroup.leave() }
                        if let url = url, error == nil {
                            // Copy video to a temporary location we can access
                            let tempURL = FileManager.default.temporaryDirectory
                                .appendingPathComponent(UUID().uuidString)
                                .appendingPathExtension(url.pathExtension)
                            
                            do {
                                try FileManager.default.copyItem(at: url, to: tempURL)
                                pickedItems.append(.video(tempURL))
                            } catch {
                                print("Failed to copy video: \(error)")
                            }
                        }
                    }
                } else {
                    // Handle image
                    result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                        defer { dispatchGroup.leave() }
                        if let image = reading as? UIImage {
                            pickedItems.append(.image(image))
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.onItemsPicked(pickedItems)
            }
        }
    }
}

// Enum to represent picked items (images or videos)
enum PhotoPickerItem {
    case image(UIImage)
    case video(URL)
    
    var filename: String {
        switch self {
        case .image:
            return "ImportedImage"
        case .video:
            return "ImportedVideo"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .image:
            return "png"
        case .video(let url):
            return url.pathExtension.isEmpty ? "mov" : url.pathExtension
        }
    }
}

