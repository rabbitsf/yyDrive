import SwiftUI

struct ContentView: View {
    @EnvironmentObject var fileManager: FileManagerHelper
    // For rename flow
    @State private var showRenameSheet = false
    @State private var folderToRename: String = ""
    @State private var newFolderName: String = ""
    
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
    
    // For selection mode
    @State private var isSelectionMode = false
    @State private var selectedFolders = Set<String>()
    @State private var showMoveSheet = false
    @State private var showDeleteAlert = false
    @State private var copiedFolderPath: String? = nil

    var body: some View {
        NavigationView {
            ZStack {
                // Light blue gradient background - FORCE this to always show
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
                        
                        // Flowers/Stars
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
                
                // Content - third layer
                VStack(spacing: 0) {
                    // Title container
                    VStack {
                        Text("My Files Cabinet")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.05, green: 0.2, blue: 0.5).opacity(0.7),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // List with transparent background
                    List {
                        ForEach(fileManager.folders, id: \..self) { folder in
                            if isSelectionMode {
                                // Selection mode row
                                HStack {
                                    Image(systemName: selectedFolders.contains(folder) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedFolders.contains(folder) ? .blue : .gray)
                                        .font(.title3)
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(getFolderColor(for: folder))
                                        .font(.title3)
                                    Text(folder)
                                        .foregroundColor(.black)
                                        .font(.system(size: 17, weight: .medium, design: .rounded))
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    toggleSelection(folder)
                                }
                                .listRowBackground(Color.white.opacity(0.6))
                            } else {
                                // Normal mode row
                                NavigationLink(destination: FolderView(path: folder)) {
                                    HStack {
                                        Image(systemName: "folder.fill")
                                            .foregroundColor(getFolderColor(for: folder))
                                            .font(.title3)
                                        Text(folder)
                                            .foregroundColor(.black)
                                            .font(.system(size: 17, weight: .medium, design: .rounded))
                                    }
                                    .padding(.vertical, 4)
                                }
                                .listRowBackground(Color.white.opacity(0.6))
                                .swipeActions {
                                    // Delete
                                    Button(role: .destructive) {
                                        if let index = fileManager.folders.firstIndex(of: folder) {
                                            fileManager.deleteFolder(at: IndexSet(integer: index))
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    // Rename
                                    Button {
                                        folderToRename = folder
                                        newFolderName = folder // prefill old name
                                        showRenameSheet = true
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if isSelectionMode {
                        // Cancel selection
                        Button("Cancel") {
                            isSelectionMode = false
                            selectedFolders.removeAll()
                        }
                        .foregroundColor(.blue)
                    } else {
                        // Select button
                        Button(action: {
                            isSelectionMode = true
                        }) {
                            Text("Select")
                                .foregroundColor(.blue)
                        }
                        
                        // Upload button (WiFi server)
                        NavigationLink(destination: UploadView()) {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .foregroundColor(.blue)
                        }
                        
                        // Refresh button for root
                        Button(action: {
                            // Reload the list of folders in root
                            fileManager.loadFolders()
                        }) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundColor(.blue)
                        }

                        // Create new folder
                        Button(action: {
                            if let createdName = fileManager.createFolder() {
                                folderToRename = createdName
                                newFolderName = createdName
                                showRenameSheet = true
                            }
                        }) {
                            Image(systemName: "folder.badge.plus")
                                .foregroundColor(.blue)
                        }
                        
                        // Paste button (if something is copied)
                        if let clipboardString = UIPasteboard.general.string,
                           !clipboardString.isEmpty,
                           clipboardString.contains("/") {
                            Menu {
                                Button(action: {
                                    pasteFolder(from: clipboardString)
                                }) {
                                    Label("Paste", systemImage: "doc.on.clipboard")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if isSelectionMode && !selectedFolders.isEmpty {
                    // Custom bottom action bar
                    HStack(spacing: 0) {
                        // Delete button
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "trash")
                                    .font(.title3)
                                Text("Delete")
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        // Copy button
                        Button(action: {
                            copySelectedFolders()
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                    .font(.title3)
                                Text("Copy")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        
                        Divider()
                            .frame(height: 40)
                        
                        // Selection count (non-interactive)
                        VStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("\(selectedFolders.count) selected")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        
                        Divider()
                            .frame(height: 40)
                        
                        // Move button
                        Button(action: {
                            showMoveSheet = true
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "folder")
                                    .font(.title3)
                                Text("Move")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                    }
                    .background(
                        .regularMaterial,
                        in: RoundedRectangle(cornerRadius: 0)
                    )
                    .overlay(
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color.gray.opacity(0.3)),
                        alignment: .top
                    )
                }
            }
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showRenameSheet) {
            RenameFolderView(oldName: folderToRename, newName: $newFolderName) {
                // On rename completion
                fileManager.renameFolder(at: "", oldName: folderToRename, newName: newFolderName)
            }
        }
        // For moving selected folders
        .sheet(isPresented: $showMoveSheet) {
            BatchMoveView(
                selectedItems: Array(selectedFolders),
                currentPath: "",
                onComplete: {
                    isSelectionMode = false
                    selectedFolders.removeAll()
                    fileManager.loadFolders()
                }
            )
            .environmentObject(fileManager)
        }
        // Delete confirmation alert
        .alert("Delete Folders", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSelectedFolders()
            }
        } message: {
            Text("Are you sure you want to delete \(selectedFolders.count) folder(s)? This action cannot be undone.")
        }
    }
    
    // MARK: - Helper Functions
    
    func toggleSelection(_ folder: String) {
        if selectedFolders.contains(folder) {
            selectedFolders.remove(folder)
        } else {
            selectedFolders.insert(folder)
        }
    }
    
    func deleteSelectedFolders() {
        for folder in selectedFolders {
            if let index = fileManager.folders.firstIndex(of: folder) {
                fileManager.deleteFolder(at: IndexSet(integer: index))
            }
        }
        selectedFolders.removeAll()
        isSelectionMode = false
        fileManager.loadFolders()
    }
    
    func copySelectedFolders() {
        // Copy all selected folders to clipboard (comma-separated paths)
        let pathsToCopy = Array(selectedFolders)
        UIPasteboard.general.string = pathsToCopy.joined(separator: ",")
        copiedFolderPath = pathsToCopy.first
        
        // Exit selection mode after copying
        isSelectionMode = false
        selectedFolders.removeAll()
    }
    
    func pasteFolder(from sourcePath: String) {
        let systemFileManager = FileManager.default
        let documentsURL = systemFileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Handle multiple items (comma-separated) or single item
        let paths = sourcePath.contains(",") ? sourcePath.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } : [sourcePath]
        
        var successCount = 0
        
        for sourcePathItem in paths {
            let sourceURL = documentsURL.appendingPathComponent(sourcePathItem)
            let folderName = sourceURL.lastPathComponent
            let destinationURL = documentsURL.appendingPathComponent(folderName)
            
            // Check if source exists and is a directory
            var isDirectory: ObjCBool = false
            guard systemFileManager.fileExists(atPath: sourceURL.path, isDirectory: &isDirectory),
                  isDirectory.boolValue else {
                print("Source folder does not exist: \(sourcePathItem)")
                continue
            }
            
            do {
                // If destination exists, add a number suffix
                var finalDestination = destinationURL
                var counter = 1
                while systemFileManager.fileExists(atPath: finalDestination.path) {
                    let newName = "\(folderName) \(counter)"
                    finalDestination = documentsURL.appendingPathComponent(newName)
                    counter += 1
                }
                
                try systemFileManager.copyItem(at: sourceURL, to: finalDestination)
                print("Pasted folder from \(sourcePathItem) to \(finalDestination.path)")
                successCount += 1
            } catch {
                print("Failed to paste folder \(sourcePathItem): \(error)")
            }
        }
        
        if successCount > 0 {
            fileManager.loadFolders()
        }
    }
}
