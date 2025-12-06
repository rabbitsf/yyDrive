import SwiftUI

struct FolderView: View {
    var path: String
    @EnvironmentObject var fileManager: FileManagerHelper
    @EnvironmentObject var audioManager: AudioManager
    @EnvironmentObject var videoManager: VideoManager
    
    // For rename flow
    @State private var showRenameSheet = false
    @State private var itemToRename: String = ""
    @State private var newItemName: String = ""
    @State private var isCreatingNewFolder = false // Track if we're creating a new folder
    
    // For importing files from within the app (DocumentPicker)
    @State private var showDocumentPicker = false
    
    // For importing pictures from Photo app
    @State private var showPhotoPicker = false
    
    // For cloud drive info
    @State private var showCloudDriveInfo = false
    
    // For selection mode
    @State private var isSelectionMode = false
    @State private var selectedItems = Set<String>()
    @State private var showMoveSheet = false
    @State private var showDeleteAlert = false
    
    // For paste functionality
    @State private var copiedItemPath: String? = nil
    
    // For move functionality
    @State private var showMoveItemSheet = false
    @State private var itemToMove: String = ""
    
    var body: some View {
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
                    Text(path.isEmpty ? "Root" : path.components(separatedBy: "/").last ?? path)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
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
                
                fileListView
            }
            .background(Color.clear)
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
                            selectedItems.removeAll()
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
                        
                        // Refresh button
                        Button(action: {
                            // Force subfolder to re-render by announcing changes
                            fileManager.objectWillChange.send()
                        }) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundColor(.blue)
                        }
                        
                        // Create a new folder
                        Button(action: {
                            if let createdName = fileManager.createFolder(in: path) {
                                itemToRename = createdName
                                newItemName = createdName
                                isCreatingNewFolder = true
                                showRenameSheet = true
                            }
                        }) {
                            Image(systemName: "folder.badge.plus")
                            .foregroundColor(.blue)
                        }
                        
                        // Unified Import menu
                        Menu {
                            // Import from Files app (includes cloud drives)
                            Button(action: {
                                showDocumentPicker = true
                            }) {
                                Label("Import from Files & Cloud Drives", systemImage: "folder")
                            }
                            
                            // Import from Photo Library
                            Button(action: {
                                showPhotoPicker = true
                            }) {
                                Label("Import from Photos", systemImage: "photo.on.rectangle.angled")
                            }
                            
                            Divider()
                            
                            // Info about cloud drives
                            Button(action: {
                                showCloudDriveInfo = true
                            }) {
                                Label("About Cloud Drives", systemImage: "info.circle")
                            }
                            
                            Divider()
                            
                            // Paste button (if something is copied and looks like a file path)
                            if let clipboardString = UIPasteboard.general.string,
                               !clipboardString.isEmpty,
                               isValidPath(clipboardString) {
                                Button(action: {
                                    // Read clipboard fresh when pasting to ensure we get the current value
                                    if let currentClipboard = UIPasteboard.general.string,
                                       !currentClipboard.isEmpty,
                                       isValidPath(currentClipboard) {
                                        pasteItem(from: currentClipboard)
                                    }
                                }) {
                                    Label("Paste", systemImage: "doc.on.clipboard")
                                }
                            } else {
                                Button(action: {}) {
                                    Label("Paste", systemImage: "doc.on.clipboard")
                                }
                                .disabled(true)
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.down.fill")
                            .foregroundColor(.blue)
                        }
                    }
                }
        }
        .safeAreaInset(edge: .bottom) {
                if isSelectionMode && !selectedItems.isEmpty {
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
                        
                        // Selection count (non-interactive)
                        VStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("\(selectedItems.count) selected")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        
                        Divider()
                            .frame(height: 40)
                        
                        // Copy button
                        Button(action: {
                            copySelectedItems()
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
        .sheet(isPresented: $showRenameSheet, onDismiss: {
            // If the sheet is dismissed (canceled) and we were creating a new folder, delete it
            if isCreatingNewFolder {
                // Delete the folder that was created but canceled
                let contents = fileManager.getContents(of: path)
                if let idx = contents.firstIndex(of: itemToRename) {
                    fileManager.deleteItem(at: IndexSet(integer: idx), in: path)
                }
                isCreatingNewFolder = false
                itemToRename = ""
                newItemName = ""
            }
        }) {
                RenameFolderView(oldName: itemToRename, newName: $newItemName) {
                    // On rename completion (Save button pressed)
                    if isCreatingNewFolder {
                        // If creating new folder, rename it to the new name
                        fileManager.renameFolder(at: path, oldName: itemToRename, newName: newItemName)
                        isCreatingNewFolder = false
                    } else {
                        // If renaming existing folder, just rename it
                        fileManager.renameFolder(at: path, oldName: itemToRename, newName: newItemName)
                    }
                    // Force refresh after rename
                    fileManager.objectWillChange.send()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        fileManager.objectWillChange.send()
                    }
                }
        }
        // DocumentPicker for importing files
        .sheet(isPresented: $showDocumentPicker) {
                DocumentPickerView { urls in
                    for url in urls {
                        fileManager.importFile(from: url, to: path)
                    }
                }
        }
            
        // For importing pictures and videos from Photo Library
        .sheet(isPresented: $showPhotoPicker) {
                PhotoPickerView(allowVideos: true) { items in
                    // Handle the selected items (images and videos)
                    for (index, item) in items.enumerated() {
                        switch item {
                        case .image(let image):
                            // Save image as PNG or JPEG
                            if let data = image.pngData() {
                                let filename = "\(item.filename)\(index + 1).\(item.fileExtension)"
                                fileManager.saveImageData(data, to: path, named: filename)
                            } else if let data = image.jpegData(compressionQuality: 0.9) {
                                let filename = "\(item.filename)\(index + 1).jpg"
                                fileManager.saveImageData(data, to: path, named: filename)
                            }
                        case .video(let videoURL):
                            // Save video file
                            let filename = "\(item.filename)\(index + 1).\(item.fileExtension)"
                            fileManager.saveVideoFile(from: videoURL, to: path, named: filename)
                        }
                    }
                }
        }
        // For moving selected items
        .sheet(isPresented: $showMoveSheet) {
                BatchMoveView(
                    selectedItems: Array(selectedItems),
                    currentPath: path,
                    onComplete: {
                        isSelectionMode = false
                        selectedItems.removeAll()
                        fileManager.objectWillChange.send()
                    }
                )
                .environmentObject(fileManager)
        }
        // For moving a single item
        .sheet(isPresented: Binding(
            get: { showMoveItemSheet && !itemToMove.isEmpty },
            set: { showMoveItemSheet = $0 }
        )) {
            BatchMoveView(
                selectedItems: [itemToMove],
                currentPath: path,
                onComplete: {
                    itemToMove = ""
                    showMoveItemSheet = false
                    fileManager.objectWillChange.send()
                }
            )
            .environmentObject(fileManager)
        }
        // Delete confirmation alert
        .alert("Delete Items", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteSelectedItems()
                }
        } message: {
                Text("Are you sure you want to delete \(selectedItems.count) item(s)? This action cannot be undone.")
        }
        // Cloud Drive Info alert
        .alert("Import from Cloud Drives", isPresented: $showCloudDriveInfo) {
                Button("OK", role: .cancel) { }
                Button("Open Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
        } message: {
                Text("""
                To import from cloud drives (Google Drive, Dropbox, OneDrive, Box, etc.):
                
                1. Install the cloud drive app from the App Store
                2. Open the Files app
                3. Tap "Browse" → "More" (⋯) → "Edit"
                4. Enable your cloud drive under "Locations"
                
                Then use "Import from Files" - your cloud drives will appear in the sidebar.
                """)
        }
    }
    
    // MARK: - View Builders
    
    @ViewBuilder
    private var fileListView: some View {
        List {
            let contents = fileManager.getContents(of: path)
            ForEach(Array(contents.enumerated()), id: \.element) { index, item in
                if isSelectionMode {
                    selectionModeRow(item: item, index: index, totalCount: contents.count)
                        .listRowBackground(Color.white.opacity(0.6))
                        .listRowSeparator(.hidden)
                } else {
                    normalModeRow(item: item, index: index, totalCount: contents.count)
                        .listRowBackground(Color.white.opacity(0.6))
                        .listRowSeparator(.hidden)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        // Update when audio/video manager state changes to highlight playing items
        .onChange(of: audioManager.currentSongTitle) { _ in
            // Force view update
        }
        .onChange(of: audioManager.isPlaying) { _ in
            // Force view update
        }
        .onChange(of: videoManager.currentSongTitle) { _ in
            // Force view update
        }
        .onChange(of: videoManager.isPlaying) { _ in
            // Force view update
        }
    }
    
    @ViewBuilder
    private func selectionModeRow(item: String, index: Int, totalCount: Int) -> some View {
        HStack {
            Image(systemName: selectedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                .foregroundColor(selectedItems.contains(item) ? .blue : .gray)
                .font(.title3)
            
            if fileManager.isFolder(item, at: path) {
                Image(systemName: "folder.fill")
                    .foregroundColor(getFolderColor(for: item))
                Text(item)
                    .foregroundColor(.black)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
            } else {
                // Show appropriate icon based on file type
                let fileIcon = getFileIcon(for: item)
                Image(systemName: fileIcon.icon)
                    .foregroundColor(fileIcon.color)
                Text(item)
                    .foregroundColor(.black)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            toggleSelection(item)
        }
    }
    
    @ViewBuilder
    private func normalModeRow(item: String, index: Int, totalCount: Int) -> some View {
        if fileManager.isFolder(item, at: path) {
            folderRow(item: item, index: index, totalCount: totalCount)
        } else {
            fileRow(item: item, index: index, totalCount: totalCount)
        }
    }
    
    @ViewBuilder
    private func folderRow(item: String, index: Int, totalCount: Int) -> some View {
        NavigationLink(destination: FolderView(path: path + "/" + item)) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(getFolderColor(for: item))
                    .font(.title3)
                Text(item)
                    .foregroundColor(.black)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                let contents = fileManager.getContents(of: path)
                if let idx = contents.firstIndex(of: item) {
                    fileManager.deleteItem(at: IndexSet(integer: idx), in: path)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        fileManager.objectWillChange.send()
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                let fullPath = path.isEmpty ? item : path + "/" + item
                UIPasteboard.general.string = fullPath
                copiedItemPath = fullPath
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            .tint(.blue)
            
            Button {
                itemToRename = item
                newItemName = item
                showRenameSheet = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            .tint(.orange)
        }
        .contextMenu {
            Button {
                // Copy folder path to clipboard for copy operation
                let fullPath = path.isEmpty ? item : path + "/" + item
                UIPasteboard.general.string = fullPath
                copiedItemPath = fullPath
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            Button {
                // Set itemToMove first, then show sheet after a tiny delay to ensure state is updated
                itemToMove = item
                DispatchQueue.main.async {
                    showMoveItemSheet = true
                }
            } label: {
                Label("Move", systemImage: "folder")
            }
            Button {
                let contents = fileManager.getContents(of: path)
                if let idx = contents.firstIndex(of: item) {
                    fileManager.deleteItem(at: IndexSet(integer: idx), in: path)
                    // Force refresh after deletion
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        fileManager.objectWillChange.send()
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button {
                itemToRename = item
                newItemName = item
                showRenameSheet = true
            } label: {
                Label("Rename", systemImage: "pencil")
            }
        }
    }
    
    @ViewBuilder
    private func fileRow(item: String, index: Int, totalCount: Int) -> some View {
        // Check if this is a media file
        let isMedia = fileManager.isMediaFile(item)
        let isVideo = fileManager.isVideoFile(item)
        let isAudio = fileManager.isAudioFile(item)
        
        if isMedia {
            // For media files, navigate to appropriate player
            if isVideo {
                // Check if this is the currently playing video
                let isCurrentlyPlaying = videoManager.currentSongTitle == item && videoManager.isPlaying
                let videoColor = getFolderColor(for: item)
                
                NavigationLink(destination: VideoPlayerView(folderPath: path, initialSongName: item, videoManager: videoManager)) {
                    HStack {
                        Image(systemName: "film.fill")
                            .foregroundColor(isCurrentlyPlaying ? videoColor.opacity(0.8) : videoColor)
                            .font(.title3)
                        Text(item)
                            .foregroundColor(isCurrentlyPlaying ? videoColor : .black)
                            .font(.system(size: isCurrentlyPlaying ? 18 : 17, weight: isCurrentlyPlaying ? .bold : .medium, design: .rounded))
                        Spacer()
                        if isCurrentlyPlaying {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(videoColor)
                                .font(.title3)
                        } else {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(videoColor)
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 4)
                    .background(isCurrentlyPlaying ? videoColor.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        let contents = fileManager.getContents(of: path)
                        if let idx = contents.firstIndex(of: item) {
                            fileManager.deleteItem(at: IndexSet(integer: idx), in: path)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                fileManager.objectWillChange.send()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        let fullPath = path.isEmpty ? item : path + "/" + item
                        UIPasteboard.general.string = fullPath
                        copiedItemPath = fullPath
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .tint(.blue)
                    
                    Button {
                        itemToRename = item
                        newItemName = item
                        showRenameSheet = true
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    .tint(.orange)
                }
                .contextMenu {
                    Button {
                        // Copy file path to clipboard for copy operation
                        let fullPath = path.isEmpty ? item : path + "/" + item
                        UIPasteboard.general.string = fullPath
                        copiedItemPath = fullPath
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    Button {
                        // Set itemToMove first, then show sheet after a tiny delay to ensure state is updated
                        itemToMove = item
                        DispatchQueue.main.async {
                            showMoveItemSheet = true
                        }
                    } label: {
                        Label("Move", systemImage: "folder")
                    }
                    Button(role: .destructive) {
                        let contents = fileManager.getContents(of: path)
                        if let idx = contents.firstIndex(of: item) {
                            fileManager.deleteItem(at: IndexSet(integer: idx), in: path)
                            // Force refresh after deletion
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                fileManager.objectWillChange.send()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        itemToRename = item
                        newItemName = item
                        showRenameSheet = true
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                }
            } else if isAudio {
                // Check if this is the currently playing song
                let isCurrentlyPlaying = audioManager.currentSongTitle == item && audioManager.isPlaying
                let audioColor = getFolderColor(for: item)
                
                NavigationLink(destination: PlayerView(folderPath: path, initialSongName: item, audioManager: audioManager)) {
                    HStack {
                        Image(systemName: isCurrentlyPlaying ? "music.note" : "music.note")
                            .foregroundColor(isCurrentlyPlaying ? audioColor.opacity(0.8) : audioColor)
                            .font(.title3)
                        Text(item)
                            .foregroundColor(isCurrentlyPlaying ? audioColor : .black)
                            .font(.system(size: isCurrentlyPlaying ? 18 : 17, weight: isCurrentlyPlaying ? .bold : .medium, design: .rounded))
                        Spacer()
                        if isCurrentlyPlaying {
                            Image(systemName: "waveform")
                                .foregroundColor(audioColor)
                                .font(.title3)
                        } else {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(audioColor)
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 4)
                    .background(isCurrentlyPlaying ? audioColor.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        let contents = fileManager.getContents(of: path)
                        if let idx = contents.firstIndex(of: item) {
                            fileManager.deleteItem(at: IndexSet(integer: idx), in: path)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                fileManager.objectWillChange.send()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button {
                        let fullPath = path.isEmpty ? item : path + "/" + item
                        UIPasteboard.general.string = fullPath
                        copiedItemPath = fullPath
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .tint(.blue)
                    
                    Button {
                        itemToRename = item
                        newItemName = item
                        showRenameSheet = true
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    .tint(.orange)
                }
                .contextMenu {
                    Button {
                        let fullPath = path.isEmpty ? item : path + "/" + item
                        UIPasteboard.general.string = fullPath
                        copiedItemPath = fullPath
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    Button {
                        // Set itemToMove first, then show sheet after a tiny delay to ensure state is updated
                        itemToMove = item
                        DispatchQueue.main.async {
                            showMoveItemSheet = true
                        }
                    } label: {
                        Label("Move", systemImage: "folder")
                    }
                    Button(role: .destructive) {
                        let contents = fileManager.getContents(of: path)
                        if let idx = contents.firstIndex(of: item) {
                            fileManager.deleteItem(at: IndexSet(integer: idx), in: path)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                fileManager.objectWillChange.send()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        itemToRename = item
                        newItemName = item
                        showRenameSheet = true
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                }
            }
        } else {
            // For non-media files, use existing FileDetailView
            let fileIcon = getFileIcon(for: item)
            NavigationLink(destination: FileDetailView(filePath: path + "/" + item)) {
                HStack {
                    Image(systemName: fileIcon.icon)
                        .foregroundColor(fileIcon.color)
                        .font(.title3)
                    Text(item)
                        .foregroundColor(.black)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding(.vertical, 4)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    let contents = fileManager.getContents(of: path)
                    if let idx = contents.firstIndex(of: item) {
                        fileManager.deleteItem(at: IndexSet(integer: idx), in: path)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            fileManager.objectWillChange.send()
                        }
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                
                Button {
                    let fullPath = path.isEmpty ? item : path + "/" + item
                    UIPasteboard.general.string = fullPath
                    copiedItemPath = fullPath
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .tint(.blue)
                
                Button {
                    itemToRename = item
                    newItemName = item
                    showRenameSheet = true
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
                .tint(.orange)
            }
            .contextMenu {
                Button {
                    // Copy file path to clipboard for copy operation
                    let fullPath = path.isEmpty ? item : path + "/" + item
                    UIPasteboard.general.string = fullPath
                    copiedItemPath = fullPath
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                Button {
                    itemToMove = item
                    showMoveItemSheet = true
                } label: {
                    Label("Move", systemImage: "folder")
                }
                Button(role: .destructive) {
                    let contents = fileManager.getContents(of: path)
                    if let idx = contents.firstIndex(of: item) {
                        fileManager.deleteItem(at: IndexSet(integer: idx), in: path)
                        // Force refresh after deletion
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            fileManager.objectWillChange.send()
                        }
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button {
                    itemToRename = item
                    newItemName = item
                    showRenameSheet = true
                } label: {
                    Label("Rename", systemImage: "pencil")
                }
            }
            .overlay(separatorOverlay(show: index < totalCount - 1))
        }
    }
    
    @ViewBuilder
    private func separatorOverlay(show: Bool) -> some View {
        if show {
            VStack {
                Spacer()
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.leading, 60)
            }
        }
    }
    
    // MARK: - Helper Functions
    
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
    
    // Get appropriate icon for file type with rainbow color
    func getFileIcon(for fileName: String) -> (icon: String, color: Color) {
        let ext = (fileName as NSString).pathExtension.lowercased()
        let fileColor = getFolderColor(for: fileName) // Use rainbow color based on filename
        
        // PDF files
        if ext == "pdf" {
            return ("doc.richtext.fill", fileColor)
        }
        
        // Image files
        let imageExtensions = ["png", "jpg", "jpeg", "gif", "heic", "heif", "tiff", "tif", "bmp", "webp", "ico", "svg", "raw", "cr2", "nef", "orf", "sr2", "dng"]
        if imageExtensions.contains(ext) {
            return ("photo.fill", fileColor)
        }
        
        // Audio files (already handled, but include for completeness)
        if fileManager.isAudioFile(fileName) {
            return ("music.note", fileColor)
        }
        
        // Video files (already handled, but include for completeness)
        if fileManager.isVideoFile(fileName) {
            return ("film.fill", fileColor)
        }
        
        // Microsoft Office documents
        if ext == "doc" || ext == "docx" {
            return ("doc.text.fill", fileColor)
        }
        if ext == "xls" || ext == "xlsx" {
            return ("tablecells.fill", fileColor)
        }
        if ext == "ppt" || ext == "pptx" {
            return ("rectangle.stack.fill", fileColor)
        }
        
        // Text files
        if ext == "txt" || ext == "rtf" || ext == "rtfd" {
            return ("doc.plaintext.fill", fileColor)
        }
        
        // Code files
        let codeExtensions = ["swift", "js", "ts", "html", "htm", "css", "xml", "json", "py", "java", "cpp", "c", "h", "php", "rb", "go", "rs", "kt", "dart"]
        if codeExtensions.contains(ext) {
            return ("chevron.left.forwardslash.chevron.right", fileColor)
        }
        
        // Archive files
        let archiveExtensions = ["zip", "rar", "7z", "tar", "gz", "bz2"]
        if archiveExtensions.contains(ext) {
            return ("archivebox.fill", fileColor)
        }
        
        // Spreadsheet/CSV
        if ext == "csv" {
            return ("tablecells.fill", fileColor)
        }
        
        // Markdown
        if ext == "md" || ext == "markdown" {
            return ("doc.text.fill", fileColor)
        }
        
        // Apple iWork files
        if ext == "pages" {
            return ("doc.text.fill", fileColor)
        }
        if ext == "numbers" {
            return ("tablecells.fill", fileColor)
        }
        if ext == "key" {
            return ("rectangle.stack.fill", fileColor)
        }
        
        // Default document icon
        return ("doc.fill", fileColor)
    }
    
    func toggleSelection(_ item: String) {
        if selectedItems.contains(item) {
        selectedItems.remove(item)
        } else {
        selectedItems.insert(item)
        }
    }
    
    func deleteSelectedItems() {
        let contents = fileManager.getContents(of: path)
        var indicesToDelete = IndexSet()
        
        for item in selectedItems {
        if let index = contents.firstIndex(of: item) {
                indicesToDelete.insert(index)
        }
        }
        
        fileManager.deleteItem(at: indicesToDelete, in: path)
        selectedItems.removeAll()
        isSelectionMode = false
        // Force refresh
        fileManager.objectWillChange.send()
        // Also trigger a small delay to ensure UI updates
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            fileManager.objectWillChange.send()
        }
    }
    
    func copySelectedItems() {
        // Copy all selected items to clipboard (comma-separated paths)
        let contents = fileManager.getContents(of: path)
        var pathsToCopy: [String] = []
        
        for item in selectedItems {
            let fullPath = path.isEmpty ? item : path + "/" + item
            pathsToCopy.append(fullPath)
        }
        
        // Store as comma-separated string
        UIPasteboard.general.string = pathsToCopy.joined(separator: ",")
        copiedItemPath = pathsToCopy.first
        
        // Exit selection mode after copying
        isSelectionMode = false
        selectedItems.removeAll()
    }
    
    // MARK: - Paste Functionality
    
    // Check if clipboard string is a valid file/folder path
    func isValidPath(_ pathString: String) -> Bool {
        let systemFileManager = FileManager.default
        guard let documentsURL = systemFileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        // Handle comma-separated paths (multiple items)
        let paths = pathString.contains(",") ? pathString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } : [pathString]
        
        // Check if at least one path exists
        for pathItem in paths {
            // Split the path by "/" and append each component properly
            let pathComponents = pathItem.components(separatedBy: "/").filter { !$0.isEmpty }
            var sourceURL = documentsURL
            for component in pathComponents {
                sourceURL = sourceURL.appendingPathComponent(component)
            }
            
            if systemFileManager.fileExists(atPath: sourceURL.path) {
                return true
            }
        }
        
        return false
    }
    
    func pasteItem(from sourcePath: String) {
        print("📋 Paste operation started with sourcePath: \(sourcePath), destination path: \(path)")
        let systemFileManager = FileManager.default
        guard let documentsURL = systemFileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Failed to get documents directory")
            return
        }
        
        // Handle multiple items (comma-separated) or single item
        let paths = sourcePath.contains(",") ? sourcePath.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) } : [sourcePath]
        print("📋 Processing \(paths.count) item(s) to paste")
        
        var successCount = 0
        var failedItems: [String] = []
        
        for sourcePathItem in paths {
            let trimmedPath = sourcePathItem.trimmingCharacters(in: .whitespaces)
            if trimmedPath.isEmpty {
                print("⚠️ Skipping empty path")
                continue
            }
            
            // Split the path by "/" and append each component properly to get source URL
            let pathComponents = trimmedPath.components(separatedBy: "/").filter { !$0.isEmpty }
            var sourceURL = documentsURL
            for component in pathComponents {
                sourceURL = sourceURL.appendingPathComponent(component)
            }
            
            let fileName = sourceURL.lastPathComponent
            
            // Build destination URL - handle empty path (root) correctly
            var destinationURL = documentsURL
            if !path.isEmpty {
                let destinationComponents = path.components(separatedBy: "/").filter { !$0.isEmpty }
                for component in destinationComponents {
                    destinationURL = destinationURL.appendingPathComponent(component)
                }
            }
            destinationURL = destinationURL.appendingPathComponent(fileName)
            
            // Check if source exists
            guard systemFileManager.fileExists(atPath: sourceURL.path) else {
                print("❌ Source file does not exist: \(sourceURL.path)")
                failedItems.append(trimmedPath)
                continue
            }
            
            do {
                // If destination exists, add a number suffix
                var finalDestination = destinationURL
                var counter = 1
                while systemFileManager.fileExists(atPath: finalDestination.path) {
                    let nameWithoutExt = fileName.components(separatedBy: ".").dropLast().joined(separator: ".")
                    let ext = fileName.components(separatedBy: ".").last ?? ""
                    let newName = "\(nameWithoutExt) \(counter).\(ext)"
                    
                    // Build destination URL with new name - handle empty path (root) correctly
                    var newDestinationURL = documentsURL
                    if !path.isEmpty {
                        let destinationComponents = path.components(separatedBy: "/").filter { !$0.isEmpty }
                        for component in destinationComponents {
                            newDestinationURL = newDestinationURL.appendingPathComponent(component)
                        }
                    }
                    finalDestination = newDestinationURL.appendingPathComponent(newName)
                    counter += 1
                }
                
                try systemFileManager.copyItem(at: sourceURL, to: finalDestination)
                print("✅ Pasted item from \(trimmedPath) to \(finalDestination.lastPathComponent)")
                successCount += 1
            } catch {
                print("❌ Failed to paste item \(trimmedPath): \(error)")
                failedItems.append(trimmedPath)
            }
        }
        
        if successCount > 0 {
            print("✅ Successfully pasted \(successCount) item(s)")
            // Refresh view using the FileManagerHelper environment object
            fileManager.objectWillChange.send()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                fileManager.objectWillChange.send()
            }
        } else if !failedItems.isEmpty {
            print("❌ Failed to paste all items: \(failedItems)")
        }
    }
}

