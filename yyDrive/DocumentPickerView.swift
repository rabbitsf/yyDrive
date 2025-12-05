import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: UIViewControllerRepresentable {
    var onPickedFiles: ([URL]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPickedFiles: onPickedFiles)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // We allow importing any type of file
        // Using asCopy: true ensures files from cloud drives are copied to app's Inbox
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item], asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Nothing to update
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPickedFiles: ([URL]) -> Void
        init(onPickedFiles: @escaping ([URL]) -> Void) {
            self.onPickedFiles = onPickedFiles
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            // When using asCopy: true, files are automatically copied to the app's Inbox
            // We need to access them with security-scoped resource access and copy them
            // to a temporary location we can access later
            var accessibleURLs: [URL] = []
            let fileManager = FileManager.default
            let tempDirectory = fileManager.temporaryDirectory
            
            for url in urls {
                // Start accessing security-scoped resource
                let needsSecurityAccess = url.startAccessingSecurityScopedResource()
                defer {
                    if needsSecurityAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                
                // Check if file exists and is readable
                guard fileManager.fileExists(atPath: url.path),
                      fileManager.isReadableFile(atPath: url.path) else {
                    print("File not accessible: \(url.lastPathComponent)")
                    continue
                }
                
                // Copy to temporary directory so we can access it later
                let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(url.pathExtension)
                
                do {
                    try fileManager.copyItem(at: url, to: tempURL)
                    accessibleURLs.append(tempURL)
                } catch {
                    print("Failed to copy file to temp location: \(error)")
                }
            }
            
            // Pass copied URLs - they're now in temp directory and accessible
            onPickedFiles(accessibleURLs)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onPickedFiles([])
        }
    }
}
