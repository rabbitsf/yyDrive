import SwiftUI

struct RenameFolderView: View {
    let oldName: String
    @Binding var newName: String
    var onRename: () -> Void

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // Blue gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.2, blue: 0.5),
                        Color(red: 0.1, green: 0.35, blue: 0.7),
                        Color(red: 0.2, green: 0.5, blue: 0.85)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Nature decorative background elements
                GeometryReader { geo in
                    Group {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.green.opacity(0.12))
                            .position(x: geo.size.width * 0.15, y: geo.size.height * 0.3)
                        
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 38))
                            .foregroundColor(.white.opacity(0.18))
                            .position(x: geo.size.width * 0.82, y: geo.size.height * 0.25)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 26))
                            .foregroundColor(.yellow.opacity(0.15))
                            .position(x: geo.size.width * 0.85, y: geo.size.height * 0.65)
                    }
                }
                
                Form {
                    Section(header: Text("Old Name")) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.blue)
                            Text(oldName)
                                .foregroundColor(.black)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.95))
                    
                    Section(header: Text("New Name")) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.blue)
                            TextField("Enter new name", text: $newName)
                                .foregroundColor(.black)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.95))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Rename")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onRename()
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

