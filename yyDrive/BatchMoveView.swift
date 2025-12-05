import SwiftUI

struct BatchMoveView: View {
    var selectedItems: [String]
    var currentPath: String
    var onComplete: () -> Void
    
    @EnvironmentObject var fileManager: FileManagerHelper
    @Environment(\.dismiss) var dismiss
    
    // Rainbow colors (7 colors of the rainbow)
    private let rainbowColors: [Color] = [
        .red,
        .orange,
        .yellow,
        .green,
        .blue,
        Color(red: 0.29, green: 0.0, blue: 0.51), // Indigo
        Color(red: 0.93, green: 0.51, blue: 0.93) // Violet
    ]
    
    // Get consistent rainbow color for a folder name
    func getFolderColor(for folderName: String) -> Color {
        // Use folder name hash to get consistent color
        let hash = abs(folderName.hashValue)
        let index = hash % rainbowColors.count
        return rainbowColors[index]
    }
    
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
                            .font(.system(size: 35))
                            .foregroundColor(.green.opacity(0.12))
                            .position(x: geo.size.width * 0.15, y: geo.size.height * 0.25)
                        
                        Image(systemName: "cloud.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.18))
                            .position(x: geo.size.width * 0.8, y: geo.size.height * 0.2)
                        
                        Image(systemName: "drop.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.blue.opacity(0.12))
                            .position(x: geo.size.width * 0.2, y: geo.size.height * 0.6)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 28))
                            .foregroundColor(.yellow.opacity(0.15))
                            .position(x: geo.size.width * 0.85, y: geo.size.height * 0.7)
                    }
                }
                
                List {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                            Text("\(selectedItems.count) item(s) selected")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.white.opacity(0.95))
                    } header: {
                        Text("Move To")
                    }
                    
                    Section {
                        ForEach(availableFolders(), id: \.self) { folder in
                            Button(action: {
                                moveItems(to: folder)
                            }) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(folder == "📁 Root" ? .blue : getFolderColor(for: folder))
                                        .font(.title3)
                                    Text(folder)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.blue.opacity(0.6))
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.white.opacity(0.95))
                        }
                    } header: {
                        Text("Available Folders")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Move Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func availableFolders() -> [String] {
        // Get all folders from root
        let allFolders = fileManager.getFolders()
        
        // If we're in root, show all folders
        if currentPath.isEmpty {
            return allFolders.filter { folder in
                !selectedItems.contains(folder)
            }
        }
        
        // If we're in a subfolder, show root folders and parent paths
        var available: [String] = []
        
        // Add root folder option
        available.append("📁 Root")
        
        // Add all top-level folders except current folder
        let currentTopFolder = currentPath.components(separatedBy: "/").first ?? ""
        for folder in allFolders {
            if folder != currentTopFolder && !selectedItems.contains(folder) {
                available.append(folder)
            }
        }
        
        return available
    }
    
    private func moveItems(to destination: String) {
        var targetPath = ""
        
        if destination == "📁 Root" {
            targetPath = ""
        } else {
            targetPath = destination
        }
        
        // Move each selected item
        for item in selectedItems {
            let sourcePath = currentPath.isEmpty ? item : currentPath + "/" + item
            fileManager.moveFile(from: sourcePath, to: targetPath)
        }
        
        onComplete()
        dismiss()
    }
}

