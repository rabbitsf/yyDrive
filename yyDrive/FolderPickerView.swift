import SwiftUI

struct FolderPickerView: View {
    @EnvironmentObject var fileManager: FileManagerHelper
    let fileToImportURL: URL

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(fileManager.folders, id: \..self) { folder in
                    // Tap to import into selected folder
                    Button(folder) {
                        fileManager.importFile(from: fileToImportURL, to: folder)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Pick a folder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Reload the folder list in case user created new folders
            fileManager.loadFolders()
        }
    }
}
