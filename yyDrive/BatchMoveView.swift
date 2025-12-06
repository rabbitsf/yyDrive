import SwiftUI

struct BatchMoveView: View {
    var selectedItems: [String]
    var currentPath: String
    var onComplete: () -> Void
    
    @EnvironmentObject var fileManager: FileManagerHelper
    @Environment(\.dismiss) var dismiss
    
    // Track the current navigation path in the folder picker
    // Always start at root for simplicity
    @State private var navigationPath: String = ""
    @State private var showInvalidMoveAlert = false
    @State private var invalidMoveMessage = ""
    
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
                    // "Move Here" button at the top of each level
                    Section {
                        let canMove = canMoveToDestination(navigationPath)
                        Button(action: {
                            guard canMoveToDestination(navigationPath) else {
                                invalidMoveMessage = "Cannot move items to this location. You cannot move a folder into itself or into one of its subfolders."
                                showInvalidMoveAlert = true
                                return
                            }
                            moveItems(to: navigationPath)
                        }) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(canMove ? .blue : .gray)
                                    .font(.title3)
                                Text(navigationPath.isEmpty ? "Move to Root" : "Move Here")
                                    .foregroundColor(canMove ? .blue : .gray)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        .disabled(!canMove)
                        .listRowBackground(canMove ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    }
                    
                    // Folder list - tap to navigate into
                    Section {
                        // Show "Root" option if not at root, to navigate back
                        if !navigationPath.isEmpty {
                            Button(action: {
                                navigateToRoot()
                            }) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                    Text("📁 Root")
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
                        
                        // Show parent folder option if not at root
                        if !navigationPath.isEmpty && navigationPath.contains("/") {
                            Button(action: {
                                navigateBack()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                    Text("Parent Folder")
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
                        
                        // Show all folders at current level
                        ForEach(availableFolders(), id: \.self) { folder in
                            Button(action: {
                                navigateToFolder(folder)
                            }) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(getFolderColor(for: folder))
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
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(navigationTitle())
            .navigationBarTitleDisplayMode(.inline)
            .alert("Cannot Move", isPresented: $showInvalidMoveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(invalidMoveMessage)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                // Back button when not at current path or root
                if !navigationPath.isEmpty && navigationPath != currentPath {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            navigateBack()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
    }
    
    private func availableFolders() -> [String] {
        // Get folders at the current navigation path
        let contents = fileManager.getContents(of: navigationPath)
        var folders: [String] = []
        
        for item in contents {
            // Check if it's a folder
            if fileManager.isFolder(item, at: navigationPath) {
                // Check if we're trying to move this folder itself
                let folderPath = navigationPath.isEmpty ? item : navigationPath + "/" + item
                
                if !shouldExcludeFolder(folderPath) {
                    folders.append(item)
                }
            }
        }
        
        return folders.sorted()
    }
    
    private func shouldExcludeFolder(_ folderPath: String) -> Bool {
        for selectedItem in selectedItems {
            let selectedPath = currentPath.isEmpty ? selectedItem : currentPath + "/" + selectedItem
            
            // Check if the selected item is a folder or file
            let isSelectedFolder = fileManager.isFolder(selectedItem, at: currentPath)
            
            if isSelectedFolder {
                // For folders: Don't show the folder if we're trying to move that exact folder
                if selectedPath == folderPath {
                    return true
                }
                
                // For folders: Check if we're trying to move a parent folder into a child folder
                if folderPath.hasPrefix(selectedPath + "/") {
                    return true
                }
                
                // For folders: Check if we're trying to move into a folder that contains the item being moved
                if selectedPath.hasPrefix(folderPath + "/") {
                    return true
                }
            }
            // For files: Don't exclude any folders - files can be moved anywhere
        }
        return false
    }
    
    private func canMoveToDestination(_ destination: String) -> Bool {
        for selectedItem in selectedItems {
            let selectedPath = currentPath.isEmpty ? selectedItem : currentPath + "/" + selectedItem
            
            // Normalize paths for comparison (remove leading/trailing slashes)
            let normalizedSelected = selectedPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            let normalizedDestination = destination.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            
            // Can't move a folder into itself
            if normalizedSelected == normalizedDestination {
                print("❌ Cannot move: destination is same as source (\(normalizedSelected))")
                return false
            }
            
            // Check if the source is a folder (only folders have restrictions about moving into subfolders)
            let isSourceFolder = fileManager.isFolder(selectedItem, at: currentPath)
            
            // Can't move a FOLDER into one of its subfolders (but files can be moved into subfolders)
            if normalizedDestination.hasPrefix(normalizedSelected + "/") {
                if isSourceFolder {
                    return false
                }
            }
            
            // Can't move into a folder that contains the item being moved (only for folders)
            if isSourceFolder && normalizedSelected.hasPrefix(normalizedDestination + "/") {
                return false
            }
        }
        return true
    }
    
    private func navigateToFolder(_ folderName: String) {
        // Navigate into the selected folder
        if navigationPath.isEmpty {
            navigationPath = folderName
        } else {
            navigationPath = navigationPath + "/" + folderName
        }
    }
    
    private func navigateBack() {
        // Go back one level
        if navigationPath.contains("/") {
            let components = navigationPath.components(separatedBy: "/")
            navigationPath = components.dropLast().joined(separator: "/")
        } else {
            navigationPath = ""
        }
    }
    
    private func navigateToRoot() {
        // Navigate to root
        navigationPath = ""
    }
    
    private func getParentPath(_ path: String) -> String {
        if path.isEmpty {
            return ""
        }
        if path.contains("/") {
            let components = path.components(separatedBy: "/")
            return components.dropLast().joined(separator: "/")
        } else {
            // If path is a single folder name, parent is root
            return ""
        }
    }
    
    private func navigationTitle() -> String {
        if navigationPath.isEmpty {
            return "Move Items"
        }
        let folderName = navigationPath.components(separatedBy: "/").last ?? navigationPath
        return folderName
    }
    
    private func moveItems(to destination: String) {
        // Validate destination before moving
        guard canMoveToDestination(destination) else {
            invalidMoveMessage = "Cannot move items to this location. You cannot move a folder into itself or into one of its subfolders."
            showInvalidMoveAlert = true
            return
        }
        
        // Move each selected item
        var successCount = 0
        var failedItems: [String] = []
        
        for item in selectedItems {
            let sourcePath = currentPath.isEmpty ? item : currentPath + "/" + item
            
            // Double-check validation for each item
            if !canMoveItem(sourcePath, to: destination) {
                failedItems.append(item)
                continue
            }
            
            fileManager.moveFile(from: sourcePath, to: destination)
            successCount += 1
        }
        
        if !failedItems.isEmpty {
            invalidMoveMessage = "Could not move \(failedItems.count) item(s). You cannot move a folder into itself or into one of its subfolders."
            showInvalidMoveAlert = true
        }
        
        if successCount > 0 {
            onComplete()
            dismiss()
        }
    }
    
    private func canMoveItem(_ sourcePath: String, to destination: String) -> Bool {
        // Normalize paths for comparison
        let normalizedSource = sourcePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedDestination = destination.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        // Extract the item name and its parent path to check if it's a folder
        let sourceComponents = normalizedSource.components(separatedBy: "/")
        let itemName = sourceComponents.last ?? normalizedSource
        let parentPath = sourceComponents.count > 1 ? sourceComponents.dropLast().joined(separator: "/") : ""
        
        // Check if the source is a folder
        let isSourceFolder = fileManager.isFolder(itemName, at: parentPath)
        
        if isSourceFolder {
            // For folders: Can't move a folder into itself
            if normalizedSource == normalizedDestination {
                return false
            }
            
            // For folders: Can't move a folder into one of its subfolders
            if normalizedDestination.hasPrefix(normalizedSource + "/") {
                return false
            }
            
            // For folders: Can't move into a folder that contains the item being moved
            if normalizedSource.hasPrefix(normalizedDestination + "/") {
                return false
            }
        } else {
            // For files: Allow moving to any folder (including parent folders)
            // Only check if trying to move to the same location
            let fileParentPath = parentPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if fileParentPath == normalizedDestination {
                return false
            }
        }
        
        return true
    }
}

