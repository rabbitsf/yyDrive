import SwiftUI

class FileManagerHelper: ObservableObject {
    @Published var folders: [String] = []
    private let baseURL: URL

    init() {
        // Directory in app's Documents folder
        baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        loadFolders()
    }

    func loadFolders() {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: baseURL.path)
            // Show only folders
            folders = contents.filter { isFolder($0, at: "") }
        } catch {
            print("Error loading folders: \(error)")
        }
    }

    // Check if item is a folder
    func isFolder(_ name: String, at path: String) -> Bool {
        var isDir: ObjCBool = false
        let fullPath = baseURL.appendingPathComponent(path).appendingPathComponent(name).path
        FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir)
        return isDir.boolValue
    }

    // Create folder with optional name (if nil, creates "New Folder")
    func createFolder(in path: String = "", name: String? = nil) -> String? {
        let folderName = name ?? "New Folder"
        let newFolderURL = baseURL.appendingPathComponent(path).appendingPathComponent(folderName)
        do {
            try FileManager.default.createDirectory(at: newFolderURL, withIntermediateDirectories: true)
            // If we are in the root folder, refresh folder list
            if path.isEmpty {
                loadFolders()
            }
            // Force view updates for subfolders
            objectWillChange.send()
            return folderName
        } catch {
            print("Failed to create folder: \(error)")
            return nil
        }
    }

    // Delete folder by index in root
    func deleteFolder(at indexSet: IndexSet) {
        for index in indexSet {
            let folder = folders[index]
            let folderURL = baseURL.appendingPathComponent(folder)
            do {
                try FileManager.default.removeItem(at: folderURL)
                loadFolders()
            } catch {
                print("Failed to delete folder: \(error)")
            }
        }
    }

    // List contents of a folder (subfolders and files)
    func getContents(of path: String) -> [String] {
        let folderURL = baseURL.appendingPathComponent(path)
        do {
            return try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
        } catch {
            print("Failed to get folder contents: \(error)")
            return []
        }
    }

    // Delete item (file or folder) in path
    func deleteItem(at indexSet: IndexSet, in path: String) {
        let folderURL = baseURL.appendingPathComponent(path)
        let contents = getContents(of: path)
        for index in indexSet {
            let itemURL = folderURL.appendingPathComponent(contents[index])
            do {
                try FileManager.default.removeItem(at: itemURL)
            } catch {
                print("Failed to delete item: \(error)")
            }
        }
        if path.isEmpty {
            // If we deleted in root folder, reload root
            loadFolders()
        }
    }

    // Move file from oldPath to newFolder
    func moveFile(from oldPath: String, to newFolder: String) {
        print("📦 FileManagerHelper.moveFile called:")
        print("   From: \(oldPath)")
        print("   To: \(newFolder)")
        
        // Normalize paths for comparison
        let normalizedOld = oldPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let normalizedNew = newFolder.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        // Validate: Can't move into the same location
        if normalizedOld == normalizedNew {
            print("❌ FileManagerHelper: Cannot move \(oldPath) to itself")
            return
        }
        
        // Check if the source is a folder
        let oldURL = baseURL.appendingPathComponent(oldPath)
        var isSourceDir: ObjCBool = false
        FileManager.default.fileExists(atPath: oldURL.path, isDirectory: &isSourceDir)
        let isSourceFolder = isSourceDir.boolValue
        
        // Validate: Can't move a FOLDER into itself or into one of its subfolders
        // (Files can be moved into subfolders, but folders cannot)
        if isSourceFolder && normalizedNew.hasPrefix(normalizedOld + "/") {
            print("❌ FileManagerHelper: Cannot move folder \(oldPath) into \(newFolder) - would create circular reference")
            print("   normalizedOld: '\(normalizedOld)'")
            print("   normalizedNew: '\(normalizedNew)'")
            print("   Check: '\(normalizedNew)'.hasPrefix('\(normalizedOld)/') = \(normalizedNew.hasPrefix(normalizedOld + "/"))")
            return
        }
        
        let newURL = baseURL.appendingPathComponent(newFolder).appendingPathComponent(oldURL.lastPathComponent)
        
        print("   Final destination: \(newURL.path)")
        
        // Final safety check: ensure the destination doesn't contain the source (only for folders)
        if isSourceFolder {
            let finalDestinationPath = newURL.path
            let sourcePath = oldURL.path
            if finalDestinationPath.hasPrefix(sourcePath + "/") {
                print("❌ FileManagerHelper: Final safety check failed - destination contains source")
                return
            }
        }
        
        do {
            try FileManager.default.moveItem(at: oldURL, to: newURL)
            print("✅ Successfully moved \(isSourceFolder ? "folder" : "file")")
        } catch {
            print("❌ Failed to move file: \(error)")
        }
    }

    // Rename a folder or file
    // oldName is the existing folder/file name, newName is the user-provided name
    func renameFolder(at path: String, oldName: String, newName: String) {
        let oldURL = baseURL.appendingPathComponent(path).appendingPathComponent(oldName)
        let newURL = baseURL.appendingPathComponent(path).appendingPathComponent(newName)

        do {
            try FileManager.default.moveItem(at: oldURL, to: newURL)
            // If we renamed in the root, refresh the folder list
            if path.isEmpty {
                loadFolders()
            }
        } catch {
            print("Failed to rename folder: \(error)")
        }
    }

    // Copy external file into a folder
    // Handles files from Files app, cloud drives (Google Drive, Dropbox, OneDrive, Box, etc.)
    func importFile(from externalURL: URL, to path: String) {
        let folderURL = baseURL.appendingPathComponent(path)
        let fileManager = FileManager.default
        
        // Ensure destination folder exists
        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            print("Failed to create destination folder: \(error)")
            return
        }
        
        // Handle security-scoped resources (needed for cloud drives)
        // Note: If URL is from temp directory (already copied), this will return false
        let needsSecurityAccess = externalURL.startAccessingSecurityScopedResource()
        defer {
            if needsSecurityAccess {
                externalURL.stopAccessingSecurityScopedResource()
            }
        }
        
        // Check if source file exists and is readable
        guard fileManager.fileExists(atPath: externalURL.path) else {
            print("Source file does not exist: \(externalURL.path)")
            return
        }
        
        guard fileManager.isReadableFile(atPath: externalURL.path) else {
            print("Source file is not readable: \(externalURL.path)")
            return
        }
        
        // Handle duplicate file names
        var destinationURL = folderURL.appendingPathComponent(externalURL.lastPathComponent)
        var counter = 1
        while fileManager.fileExists(atPath: destinationURL.path) {
            let nameWithoutExt = externalURL.deletingPathExtension().lastPathComponent
            let ext = externalURL.pathExtension
            let newName = ext.isEmpty ? "\(nameWithoutExt) \(counter)" : "\(nameWithoutExt) \(counter).\(ext)"
            destinationURL = folderURL.appendingPathComponent(newName)
            counter += 1
        }
        
        do {
            // Copy the file from source (could be from Inbox, cloud drive, or temp directory) to destination
            try fileManager.copyItem(at: externalURL, to: destinationURL)
            print("Imported file to: \(destinationURL)")
            
            // Check if this is a Google Docs/Sheets/Slides file that's actually a PDF
            let fileExtension = externalURL.pathExtension.lowercased()
            let googleFileExtensions = ["gdoc", "gsheet", "gslides"]
            
            if googleFileExtensions.contains(fileExtension) {
                // Check if the file is actually a PDF
                if let fileData = try? Data(contentsOf: destinationURL), fileData.count >= 4 {
                    let pdfHeader = fileData.prefix(4)
                    if pdfHeader == Data([0x25, 0x50, 0x44, 0x46]) { // "%PDF"
                        // It's a PDF! Rename the file to .pdf
                        let nameWithoutExt = destinationURL.deletingPathExtension().lastPathComponent
                        let pdfURL = destinationURL.deletingLastPathComponent().appendingPathComponent("\(nameWithoutExt).pdf")
                        
                        // Handle duplicate PDF names
                        var finalPDFURL = pdfURL
                        var counter = 1
                        while fileManager.fileExists(atPath: finalPDFURL.path) {
                            let newName = "\(nameWithoutExt) \(counter).pdf"
                            finalPDFURL = destinationURL.deletingLastPathComponent().appendingPathComponent(newName)
                            counter += 1
                        }
                        
                        do {
                            try fileManager.moveItem(at: destinationURL, to: finalPDFURL)
                            print("Renamed Google file from .\(fileExtension) to .pdf: \(finalPDFURL.lastPathComponent)")
                            destinationURL = finalPDFURL // Update for cleanup check
                        } catch {
                            print("Failed to rename Google file to PDF: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
            // Clean up temp file if it's in the temp directory
            if externalURL.path.contains(fileManager.temporaryDirectory.path) {
                try? fileManager.removeItem(at: externalURL)
            }
            
            // Trigger UI update
            objectWillChange.send()
        } catch {
            print("Failed to import file: \(error.localizedDescription)")
        }
    }
    
    // Save pictures to current folder
    func saveImageData(_ data: Data, to path: String, named filename: String) {
        let folderURL = baseURL.appendingPathComponent(path)
        let fileURL = folderURL.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            objectWillChange.send() // re-render UI
            print("Saved image to: \(fileURL)")
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    // Save video file to current folder
    func saveVideoFile(from sourceURL: URL, to path: String, named filename: String) {
        let folderURL = baseURL.appendingPathComponent(path)
        let fileURL = folderURL.appendingPathComponent(filename)
        let fileManager = FileManager.default
        
        // Ensure destination folder exists
        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            print("Failed to create destination folder: \(error)")
            return
        }
        
        // Handle duplicate file names
        var finalDestinationURL = fileURL
        var counter = 1
        while fileManager.fileExists(atPath: finalDestinationURL.path) {
            let nameWithoutExt = filename.components(separatedBy: ".").dropLast().joined(separator: ".")
            let ext = filename.components(separatedBy: ".").last ?? ""
            let newName = "\(nameWithoutExt) \(counter).\(ext)"
            finalDestinationURL = folderURL.appendingPathComponent(newName)
            counter += 1
        }
        
        do {
            try fileManager.copyItem(at: sourceURL, to: finalDestinationURL)
            objectWillChange.send() // re-render UI
            print("Saved video to: \(finalDestinationURL)")
        } catch {
            print("Failed to save video: \(error)")
        }
    }
    
    // MARK: - Methods for Upload Server Compatibility
    
    // Get base path as String for server use
    func getBasePath() -> String {
        return baseURL.path
    }
    
    // Get folder path for server
    func getFolderPath(_ folderName: String) -> String {
        return baseURL.appendingPathComponent(folderName).path
    }
    
    // Get list of folders for server
    func getFolders() -> [String] {
        return folders
    }
    
    // Create folder with specific name (for server)
    func createFolder(name: String) throws {
        let folderURL = baseURL.appendingPathComponent(name)
        
        // Check if folder already exists
        if FileManager.default.fileExists(atPath: folderURL.path) {
            throw NSError(domain: "FileManagerHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Folder already exists"])
        }
        
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        loadFolders()
    }
    
    // MARK: - Media File Detection Methods
    
    // Get audio files in a folder (by folder name)
    func getSongs(in folder: String) -> [String] {
        let folderPath = getFolderPath(folder)
        let folderURL = baseURL.appendingPathComponent(folderPath)
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
            // Support multiple audio formats
            let supportedExtensions: Set<String> = ["mp3", "m4a", "aac", "wav", "flac", "ogg", "opus", "wma", "amr", "3gp", "aiff", "aif", "caf", "m4r", "mp4", "m4b", "ac3", "eac3", "mp2", "mpa", "ra", "rm", "vox", "au", "snd"]
            return contents.filter { fileName in
                let ext = (fileName as NSString).pathExtension.lowercased()
                return supportedExtensions.contains(ext)
            }
        } catch {
            print("Failed to get songs in folder \(folder): \(error)")
            return []
        }
    }
    
    // Get audio files in a path (supports nested folders)
    func getSongs(inPath path: String) -> [String] {
        let folderURL = baseURL.appendingPathComponent(path)
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
            // Support multiple audio formats
            let supportedExtensions: Set<String> = ["mp3", "m4a", "aac", "wav", "flac", "ogg", "opus", "wma", "amr", "3gp", "aiff", "aif", "caf", "m4r", "mp4", "m4b", "ac3", "eac3", "mp2", "mpa", "ra", "rm", "vox", "au", "snd"]
            return contents.filter { fileName in
                let ext = (fileName as NSString).pathExtension.lowercased()
                return supportedExtensions.contains(ext)
            }
        } catch {
            print("Failed to get songs in path \(path): \(error)")
            return []
        }
    }
    
    // Get video files in a folder (by folder name)
    func getVideos(in folder: String) -> [String] {
        let folderPath = getFolderPath(folder)
        let folderURL = baseURL.appendingPathComponent(folderPath)
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
            // Support multiple video formats
            let supportedExtensions: Set<String> = ["mp4", "mov", "m4v", "3gp", "avi", "mkv", "wmv", "flv", "webm", "mpeg", "mpg", "m2v", "ts", "mts", "m2ts", "vob", "asf", "rm", "rmvb", "divx", "xvid", "f4v", "ogv", "dv", "mxf"]
            return contents.filter { fileName in
                let ext = (fileName as NSString).pathExtension.lowercased()
                return supportedExtensions.contains(ext)
            }
        } catch {
            print("Failed to get videos in folder \(folder): \(error)")
            return []
        }
    }
    
    // Get video files in a path (supports nested folders)
    func getVideos(inPath path: String) -> [String] {
        let folderURL = baseURL.appendingPathComponent(path)
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
            // Support multiple video formats
            let supportedExtensions: Set<String> = ["mp4", "mov", "m4v", "3gp", "avi", "mkv", "wmv", "flv", "webm", "mpeg", "mpg", "m2v", "ts", "mts", "m2ts", "vob", "asf", "rm", "rmvb", "divx", "xvid", "f4v", "ogv", "dv", "mxf"]
            return contents.filter { fileName in
                let ext = (fileName as NSString).pathExtension.lowercased()
                return supportedExtensions.contains(ext)
            }
        } catch {
            print("Failed to get videos in path \(path): \(error)")
            return []
        }
    }
    
    // Get all media files (audio + video) in a folder (by folder name)
    func getAllMediaFiles(in folder: String) -> [String] {
        let folderPath = getFolderPath(folder)
        return getAllMediaFiles(inPath: folderPath)
    }
    
    // Get all media files (audio + video) in a path (supports nested folders)
    func getAllMediaFiles(inPath path: String) -> [String] {
        let folderURL = baseURL.appendingPathComponent(path)
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
            // Support both audio and video formats
            let supportedExtensions: Set<String> = ["mp3", "m4a", "aac", "wav", "flac", "ogg", "opus", "wma", "amr", "aiff", "aif", "caf", "m4r", "mp4", "m4b", "ac3", "eac3", "mp2", "mpa", "ra", "rm", "vox", "au", "snd", "mov", "m4v", "3gp", "avi", "mkv", "wmv", "flv", "webm", "mpeg", "mpg", "m2v", "ts", "mts", "m2ts", "vob", "asf", "rmvb", "divx", "xvid", "f4v", "ogv", "dv", "mxf"]
            return contents.filter { fileName in
                let ext = (fileName as NSString).pathExtension.lowercased()
                return supportedExtensions.contains(ext)
            }
        } catch {
            print("Failed to get media files in path \(path): \(error)")
            return []
        }
    }
    
    // Check if a file is a video file
    func isVideoFile(_ filename: String) -> Bool {
        let videoExtensions: Set<String> = ["mp4", "mov", "m4v", "3gp", "avi", "mkv", "wmv", "flv", "webm", "mpeg", "mpg", "m2v", "ts", "mts", "m2ts", "vob", "asf", "rm", "rmvb", "divx", "xvid", "f4v", "ogv", "dv", "mxf"]
        let ext = (filename as NSString).pathExtension.lowercased()
        return videoExtensions.contains(ext)
    }
    
    // Check if a file is an audio file
    func isAudioFile(_ filename: String) -> Bool {
        let audioExtensions: Set<String> = ["mp3", "m4a", "aac", "wav", "flac", "ogg", "opus", "wma", "amr", "3gp", "aiff", "aif", "caf", "m4r", "mp4", "m4b", "ac3", "eac3", "mp2", "mpa", "ra", "rm", "vox", "au", "snd"]
        let ext = (filename as NSString).pathExtension.lowercased()
        return audioExtensions.contains(ext)
    }
    
    // Check if a file is a media file (audio or video)
    func isMediaFile(_ filename: String) -> Bool {
        return isAudioFile(filename) || isVideoFile(filename)
    }
}
