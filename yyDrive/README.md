# yyDrive

A powerful iOS file manager and media player with advanced file conversion capabilities, cloud drive integration, and WiFi file transfer.

## Features

### 📁 File Management
- **Complete File Organization**: Create, rename, delete, and organize folders
- **File Operations**: Move, copy, rename, and delete files with ease
- **Batch Operations**: Select and move multiple files at once
- **Beautiful UI**: Rainbow-colored folder and file icons for visual organization
- **File Preview**: QuickLook integration for viewing various file types

### 📥 File Import
- **iOS Files App**: Import files directly from the Files app
- **Cloud Drive Integration**: Access and import from:
  - Google Drive
  - Dropbox
  - Microsoft OneDrive
  - Box
  - And other cloud services accessible through iOS Files
- **Photo Library**: Import photos and videos directly from your Photo Library
- **Paste Support**: Paste files from clipboard

### 🎬 Media Player
- **Audio Player**: Full-featured audio player with:
  - Playlist support
  - Equalizer controls
  - Playback controls (play, pause, skip, shuffle, repeat)
- **Video Player**: Full-screen video playback with standard controls
- **Media Organization**: Automatically detects and organizes audio/video files

### 🔄 File Conversion
- **PDF Conversions**:
  - PDF → TXT (text extraction)
  - PDF → DOCX (Microsoft Word)
  - PDF → XLSX (Microsoft Excel)
  - PDF → PPTX (Microsoft PowerPoint)
  - PDF → PNG/JPG (image export)

- **Office Format Conversions**:
  - DOCX/DOC → PDF, TXT, RTF
  - XLSX/XLS → PDF, CSV, TXT
  - PPTX/PPT → PDF, TXT

- **Image Format Conversions**:
  - Convert between PNG, JPG, JPEG, GIF, HEIC, HEIF, TIFF, BMP, WEBP
  - Images → PDF

- **Google Docs/Sheets**:
  - Automatic detection and conversion
  - Google Docs → DOCX, PDF, TXT
  - Google Sheets → XLSX, CSV, PDF

- **Text Format Conversions**:
  - TXT, RTF, HTML → PDF and other text formats

### 📤 File Sharing
- **AirDrop**: Share files wirelessly to nearby devices
- **Save to Files**: Export files to the iOS Files app
- **Share Sheet**: Access all iOS sharing options (Messages, Mail, etc.)
- **Copy to Clipboard**: Quick copy functionality

### 📡 WiFi File Transfer
- **Upload Server**: Built-in WiFi server for transferring files from your computer
- **Easy Access**: Connect via WiFi and upload files through a web interface
- **Cross-Platform**: Works with any device that can access a web browser

### 🎨 User Interface
- **Beautiful Design**: Light blue gradient backgrounds with decorative icons
- **Rainbow Icons**: Colorful folder and file icons for better visual organization
- **Image Viewer**: Pinch-to-zoom and pan support for images
- **Orientation Support**: Automatic orientation handling for images and documents
- **Swipe Actions**: Quick actions via swipe gestures

### 🔍 File Viewing
- **QuickLook Integration**: Native iOS preview for supported file types
- **Image Viewer**: Full-featured image viewer with zoom and pan
- **Document Preview**: View PDFs, Office documents, and more
- **Media Preview**: Quick preview for audio and video files

## Requirements

- iOS 14.0 or later
- Xcode 14.0 or later (for building)
- Swift 5.0 or later

## Installation

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/rabbitsf/yyDrive.git
   cd yyDrive
   ```

2. Open the project in Xcode:
   ```bash
   open yyDrive.xcodeproj
   ```

3. Select your development team in Xcode project settings

4. Build and run on your iOS device or simulator

### Dependencies

- **ZIPFoundation**: Used for creating and reading Office file formats (DOCX, XLSX, PPTX)
  - Added via Swift Package Manager

## Usage

### Importing Files

1. Tap the **Import** button in the folder view
2. Choose from:
   - **Import from Files & Cloud Drives**: Access Files app and connected cloud services
   - **Import from Photos**: Select photos and videos from your Photo Library
   - **Paste**: Paste files from clipboard

### Converting Files

1. Open any supported file
2. Tap the **Convert** button in the toolbar
3. Select the desired output format
4. Tap **Convert** to process

### Sharing Files

1. Open any file
2. Tap the **Share** button in the toolbar
3. Choose your sharing method (AirDrop, Save to Files, etc.)

### Using WiFi Upload

1. Tap the **WiFi Upload** button on the landing page
2. Note the displayed IP address and port
3. Open a web browser on your computer
4. Navigate to the displayed URL
5. Upload files through the web interface

## Project Structure

```
yyDrive/
├── yyDrive/
│   ├── yyDriveApp.swift          # App entry point
│   ├── ContentView.swift          # Landing page
│   ├── FolderView.swift           # Folder browsing and management
│   ├── FileDetailView.swift       # File preview and details
│   ├── FileConversionView.swift  # File conversion interface
│   ├── FileManagerHelper.swift   # File operations
│   ├── AudioManager.swift        # Audio playback
│   ├── VideoManager.swift        # Video playback
│   ├── WiFiUploadServer.swift    # WiFi file transfer server
│   └── ...                       # Other supporting files
└── README.md
```

## Features in Detail

### File Conversion Technology

The app uses advanced techniques for file conversion:

- **PDF Processing**: Uses PDFKit for text extraction and page rendering
- **Office Formats**: Creates valid Office Open XML files using ZIPFoundation
- **Image Processing**: Uses Core Graphics and Image I/O for format conversion
- **XML Parsing**: Extracts content from Office files for conversion

### Cloud Drive Integration

Cloud drives (Google Drive, Dropbox, OneDrive, Box) are accessed through the iOS Files app integration. When you import files, they appear in the standard iOS file picker, allowing seamless access to all connected cloud services.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available for use. Please check the license file for details.

## Author

Created by rabbitsf

## Acknowledgments

- Uses [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) for ZIP archive handling
- Built with SwiftUI and native iOS frameworks

