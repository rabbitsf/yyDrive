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
    @State private var selectedItems = Set<String>() // Changed from selectedFolders to selectedItems
    @State private var showMoveSheet = false
    @State private var showDeleteAlert = false
    @State private var copiedItemPath: String? = nil
    
    // For move functionality (single item)
    @State private var showMoveItemSheet = false
    @State private var itemToMove: String = ""

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
                    
                    // List with transparent background - show folders first, then files
                    List {
                        let contents = fileManager.getContents(of: "")
                        let folders = contents.filter { fileManager.isFolder($0, at: "") }.sorted()
                        let files = contents.filter { !fileManager.isFolder($0, at: "") }.sorted()
                        
                        // Folders section
                        if !folders.isEmpty {
                            Section {
                                ForEach(folders, id: \.self) { item in
                                    if isSelectionMode {
                                        // Selection mode row
                                        HStack {
                                            Image(systemName: selectedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedItems.contains(item) ? .blue : .gray)
                                                .font(.title3)
                                            Image(systemName: "folder.fill")
                                                .foregroundColor(getFolderColor(for: item))
                                                .font(.title3)
                                            Text(item)
                                                .foregroundColor(.black)
                                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                            Spacer()
                                        }
                                        .padding(.vertical, 4)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            toggleSelection(item)
                                        }
                                        .listRowBackground(Color.white.opacity(0.6))
                                    } else {
                                        // Normal mode row - Folder
                                        NavigationLink(destination: FolderView(path: item)) {
                                            HStack {
                                                Image(systemName: "folder.fill")
                                                    .foregroundColor(getFolderColor(for: item))
                                                    .font(.title3)
                                                Text(item)
                                                    .foregroundColor(.black)
                                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                            }
                                            .padding(.vertical, 4)
                                        }
                                        .listRowBackground(Color.white.opacity(0.6))
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                let contents = fileManager.getContents(of: "")
                                                if let index = contents.firstIndex(of: item) {
                                                    fileManager.deleteItem(at: IndexSet(integer: index), in: "")
                                                    fileManager.loadFolders()
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            
                                            Button {
                                                folderToRename = item
                                                newFolderName = item
                                                showRenameSheet = true
                                            } label: {
                                                Label("Rename", systemImage: "pencil")
                                            }
                                            .tint(.orange)
                                        }
                                        .contextMenu {
                                            Button {
                                                // Copy folder path to clipboard for copy operation
                                                UIPasteboard.general.string = item
                                                copiedItemPath = item
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
                                                let contents = fileManager.getContents(of: "")
                                                if let idx = contents.firstIndex(of: item) {
                                                    fileManager.deleteItem(at: IndexSet(integer: idx), in: "")
                                                    fileManager.loadFolders()
                                                    // Force refresh after deletion
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        fileManager.objectWillChange.send()
                                                    }
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            Button {
                                                folderToRename = item
                                                newFolderName = item
                                                showRenameSheet = true
                                            } label: {
                                                Label("Rename", systemImage: "pencil")
                                            }
                                        }
                                    }
                                }
                            } header: {
                                Text("Folders")
                            }
                        }
                        
                        // Files section
                        if !files.isEmpty {
                            Section {
                                ForEach(files, id: \.self) { item in
                                    if isSelectionMode {
                                        // Selection mode row
                                        HStack {
                                            Image(systemName: selectedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedItems.contains(item) ? .blue : .gray)
                                                .font(.title3)
                                            // Show file icon
                                            let fileIcon = getFileIcon(for: item)
                                            Image(systemName: fileIcon.icon)
                                                .foregroundColor(fileIcon.color)
                                                .font(.title3)
                                            Text(item)
                                                .foregroundColor(.black)
                                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                            Spacer()
                                        }
                                        .padding(.vertical, 4)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            toggleSelection(item)
                                        }
                                        .listRowBackground(Color.white.opacity(0.6))
                                    } else {
                                        // Normal mode row - File
                                        let fileIcon = getFileIcon(for: item)
                                        NavigationLink(destination: FileDetailView(filePath: item)) {
                                            HStack {
                                                Image(systemName: fileIcon.icon)
                                                    .foregroundColor(fileIcon.color)
                                                    .font(.title3)
                                                Text(item)
                                                    .foregroundColor(.black)
                                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                            }
                                            .padding(.vertical, 4)
                                        }
                                        .listRowBackground(Color.white.opacity(0.6))
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                let contents = fileManager.getContents(of: "")
                                                if let index = contents.firstIndex(of: item) {
                                                    fileManager.deleteItem(at: IndexSet(integer: index), in: "")
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            
                                            Button {
                                                folderToRename = item
                                                newFolderName = item
                                                showRenameSheet = true
                                            } label: {
                                                Label("Rename", systemImage: "pencil")
                                            }
                                            .tint(.orange)
                                        }
                                        .contextMenu {
                                            Button {
                                                // Copy file path to clipboard for copy operation
                                                UIPasteboard.general.string = item
                                                copiedItemPath = item
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
                                                let contents = fileManager.getContents(of: "")
                                                if let idx = contents.firstIndex(of: item) {
                                                    fileManager.deleteItem(at: IndexSet(integer: idx), in: "")
                                                    // Force refresh after deletion
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                        fileManager.objectWillChange.send()
                                                    }
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            Button {
                                                folderToRename = item
                                                newFolderName = item
                                                showRenameSheet = true
                                            } label: {
                                                Label("Rename", systemImage: "pencil")
                                            }
                                        }
                                    }
                                }
                            } header: {
                                Text("Files")
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
                           isValidPath(clipboardString) {
                            Menu {
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
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .foregroundColor(.blue)
                            }
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
                // On rename completion - handle both folders and files
                fileManager.renameFolder(at: "", oldName: folderToRename, newName: newFolderName)
                fileManager.loadFolders()
                fileManager.objectWillChange.send()
            }
        }
        // For moving selected items
        .sheet(isPresented: $showMoveSheet) {
            BatchMoveView(
                selectedItems: Array(selectedItems),
                currentPath: "",
                onComplete: {
                    isSelectionMode = false
                    selectedItems.removeAll()
                    fileManager.loadFolders()
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
                currentPath: "",
                onComplete: {
                    itemToMove = ""
                    showMoveItemSheet = false
                    fileManager.loadFolders()
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
    }
    
    // MARK: - Helper Functions
    
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
        
        // Audio files
        if fileManager.isAudioFile(fileName) {
            return ("music.note", fileColor)
        }
        
        // Video files
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
        let contents = fileManager.getContents(of: "")
        var indicesToDelete = IndexSet()
        
        for item in selectedItems {
            if let index = contents.firstIndex(of: item) {
                indicesToDelete.insert(index)
            }
        }
        
        fileManager.deleteItem(at: indicesToDelete, in: "")
        selectedItems.removeAll()
        isSelectionMode = false
        fileManager.loadFolders()
        fileManager.objectWillChange.send()
    }
    
    func copySelectedItems() {
        // Copy all selected items to clipboard (comma-separated paths)
        let pathsToCopy = Array(selectedItems)
        UIPasteboard.general.string = pathsToCopy.joined(separator: ",")
        copiedItemPath = pathsToCopy.first
        
        // Exit selection mode after copying
        isSelectionMode = false
        selectedItems.removeAll()
    }
    
    func pasteItem(from sourcePath: String) {
        print("📋 Paste operation started with sourcePath: \(sourcePath)")
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
            
            let itemName = sourceURL.lastPathComponent
            // For root, destination is just the item name
            let destinationURL = documentsURL.appendingPathComponent(itemName)
            
            // Check if source exists
            guard systemFileManager.fileExists(atPath: sourceURL.path) else {
                print("❌ Source item does not exist: \(sourceURL.path)")
                failedItems.append(trimmedPath)
                continue
            }
            
            do {
                // If destination exists, add a number suffix
                var finalDestination = destinationURL
                var counter = 1
                while systemFileManager.fileExists(atPath: finalDestination.path) {
                    let nameWithoutExt = itemName.components(separatedBy: ".").dropLast().joined(separator: ".")
                    let ext = itemName.components(separatedBy: ".").last ?? ""
                    let newName = ext.isEmpty ? "\(itemName) \(counter)" : "\(nameWithoutExt) \(counter).\(ext)"
                    finalDestination = documentsURL.appendingPathComponent(newName)
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
            fileManager.loadFolders()
            fileManager.objectWillChange.send()
        } else if !failedItems.isEmpty {
            print("❌ Failed to paste all items: \(failedItems)")
        }
    }
}
