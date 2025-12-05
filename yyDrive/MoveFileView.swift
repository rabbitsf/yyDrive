import SwiftUI

struct MoveFileView: View {
    var filePath: String
    @EnvironmentObject var fileManager: FileManagerHelper

    var body: some View {
        List {
            ForEach(fileManager.folders, id: \..self) { folder in
                Button(action: {
                    fileManager.moveFile(from: filePath, to: folder)
                }) {
                    Text("Move to \(folder)")
                }
            }
        }
        .navigationTitle("Move File")
    }
}
