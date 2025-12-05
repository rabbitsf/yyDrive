import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import Compression
import Foundation
import ZIPFoundation

struct FileConversionView: View {
    let sourceFilePath: String
    @Environment(\.dismiss) var dismiss
    @State private var selectedFormat: String = ""
    @State private var isConverting = false
    @State private var conversionMessage = ""
    @State private var showSuccessAlert = false
    
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
                
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        // Header section
                        VStack(spacing: 15) {
                            Text("Convert File")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.top, 10)
                            
                            // Source file info
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Source File:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text((sourceFilePath as NSString).lastPathComponent)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 15)
                        
                        // Scrollable format selection section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Convert To:")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            let availableFormats = getAvailableFormats(for: sourceFilePath)
                            
                            if availableFormats.isEmpty {
                                Text("No conversion options available for this file type")
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding()
                            } else {
                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(availableFormats, id: \.self) { format in
                                            Button(action: {
                                                selectedFormat = format
                                            }) {
                                                HStack {
                                                    Image(systemName: selectedFormat == format ? "checkmark.circle.fill" : "circle")
                                                        .foregroundColor(selectedFormat == format ? .green : .white)
                                                    Text(format.uppercased())
                                                        .foregroundColor(.white)
                                                    Spacer()
                                                }
                                                .padding()
                                                .background(selectedFormat == format ? Color.green.opacity(0.3) : Color.white.opacity(0.2))
                                                .cornerRadius(10)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                        .frame(maxHeight: geometry.size.height * 0.5)
                        
                        Spacer()
                        
                        // Fixed bottom section with Convert button
                        VStack(spacing: 15) {
                            if isConverting {
                                VStack(spacing: 10) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.5)
                                    Text("Converting...")
                                        .foregroundColor(.white)
                                }
                                .padding()
                            }
                            
                            if !conversionMessage.isEmpty && !isConverting {
                                Text(conversionMessage)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            
                            // Convert button - always visible when format is selected
                            if !selectedFormat.isEmpty && !isConverting {
                                Button(action: {
                                    convertFile()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text("Convert")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .alert("Conversion Complete", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(conversionMessage)
        }
    }
    
    func getAvailableFormats(for filePath: String) -> [String] {
        let ext = (filePath as NSString).pathExtension.lowercased()
        var formats: [String] = []
        
        // Google Docs format - can convert to DOCX
        if ext == "gdoc" {
            formats = ["docx", "pdf", "txt"]
        }
        
        // Google Sheets format - can convert to XLSX
        else if ext == "gsheet" {
            formats = ["xlsx", "csv", "pdf"]
        }
        
        // Microsoft Word formats
        else if ext == "docx" || ext == "doc" {
            formats = ["pdf", "txt", "rtf"]
        }
        
        // Microsoft Excel formats
        else if ext == "xlsx" || ext == "xls" {
            formats = ["pdf", "csv", "txt"]
        }
        
        // Microsoft PowerPoint formats
        else if ext == "pptx" || ext == "ppt" {
            formats = ["pdf", "txt"]
        }
        
        // Image formats
        else {
        let imageFormats = ["png", "jpg", "jpeg", "gif", "heic", "heif", "tiff", "tif", "bmp", "webp"]
        if imageFormats.contains(ext) {
            formats = imageFormats.filter { $0 != ext }
        }
        
        // Document formats - can convert images to PDF
        if imageFormats.contains(ext) {
            formats.append("pdf")
        }
        
        // PDF can be converted to images and documents
        if ext == "pdf" {
            formats = ["png", "jpg", "jpeg", "txt", "docx", "xlsx", "pptx"]
        }
        
        // Text formats
        let textFormats = ["txt", "rtf", "html", "htm"]
        if textFormats.contains(ext) {
            formats = textFormats.filter { $0 != ext }
            formats.append("pdf")
            }
        }
        
        return formats
    }
    
    func convertFile() {
        isConverting = true
        conversionMessage = ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let sourceURL = documentsURL.appendingPathComponent(sourceFilePath)
            let sourceExt = (sourceFilePath as NSString).pathExtension.lowercased()
            let fileName = (sourceFilePath as NSString).lastPathComponent
            let nameWithoutExt = (fileName as NSString).deletingPathExtension
            let folderPath = (sourceFilePath as NSString).deletingLastPathComponent
            let destinationURL = documentsURL.appendingPathComponent(folderPath).appendingPathComponent("\(nameWithoutExt).\(selectedFormat)")
            
            var success = false
            var message = ""
            
            // Image to Image conversion
            if isImageFormat(sourceExt) && isImageFormat(selectedFormat) {
                if let image = UIImage(contentsOfFile: sourceURL.path) {
                    if let data = getImageData(image: image, format: selectedFormat) {
                        do {
                            try data.write(to: destinationURL)
                            success = true
                            message = "File converted successfully to \(selectedFormat.uppercased())"
                        } catch {
                            message = "Failed to save converted file: \(error.localizedDescription)"
                        }
                    } else {
                        message = "Failed to convert image format"
                    }
                } else {
                    message = "Failed to load source image"
                }
            }
            // Image to PDF
            else if isImageFormat(sourceExt) && selectedFormat == "pdf" {
                if let image = UIImage(contentsOfFile: sourceURL.path) {
                    let pdfData = createPDF(from: image)
                    do {
                        try pdfData.write(to: destinationURL)
                        success = true
                        message = "Image converted to PDF successfully"
                    } catch {
                        message = "Failed to save PDF: \(error.localizedDescription)"
                    }
                } else {
                    message = "Failed to load source image"
                }
            }
            // PDF conversions
            else if sourceExt == "pdf" {
                if let pdfDocument = PDFDocument(url: sourceURL) {
                    if pdfDocument.pageCount == 0 {
                        message = "PDF has no pages"
                    } else if isImageFormat(selectedFormat) {
                        // PDF to Image
                        if let firstPage = pdfDocument.page(at: 0) {
                            let pageRect = firstPage.bounds(for: .mediaBox)
                            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                            let image = renderer.image { ctx in
                                ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
                                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                                firstPage.draw(with: .mediaBox, to: ctx.cgContext)
                            }
                            
                            if let data = getImageData(image: image, format: selectedFormat) {
                                do {
                                    try data.write(to: destinationURL)
                                    success = true
                                    message = "PDF converted to \(selectedFormat.uppercased()) successfully"
                                } catch {
                                    message = "Failed to save image: \(error.localizedDescription)"
                                }
                            } else {
                                message = "Failed to convert PDF page to image"
                            }
                        }
                    } else if selectedFormat == "txt" {
                        // PDF to TXT - Extract text from all pages
                        var extractedText = ""
                        for i in 0..<pdfDocument.pageCount {
                            if let page = pdfDocument.page(at: i) {
                                if let pageText = page.string {
                                    extractedText += pageText
                                    if i < pdfDocument.pageCount - 1 {
                                        extractedText += "\n\n--- Page \(i + 1) ---\n\n"
                                    }
                                }
                            }
                        }
                        
                        if !extractedText.isEmpty {
                            do {
                                try extractedText.write(to: destinationURL, atomically: true, encoding: .utf8)
                                success = true
                                message = "PDF converted to TXT successfully"
                            } catch {
                                message = "Failed to save TXT file: \(error.localizedDescription)"
                            }
                        } else {
                            message = "No text could be extracted from PDF"
                        }
                    } else if selectedFormat == "docx" {
                        // PDF to DOCX - Extract text and create basic Word document
                        let semaphore = DispatchSemaphore(value: 0)
                        convertPDFToDOCX(pdfDocument: pdfDocument, destinationURL: destinationURL) { convSuccess, convMessage in
                            success = convSuccess
                            message = convMessage
                            semaphore.signal()
                        }
                        semaphore.wait()
                    } else if selectedFormat == "xlsx" {
                        // PDF to XLSX - Extract text and create basic Excel file
                        let semaphore = DispatchSemaphore(value: 0)
                        convertPDFToXLSX(pdfDocument: pdfDocument, destinationURL: destinationURL) { convSuccess, convMessage in
                            success = convSuccess
                            message = convMessage
                            semaphore.signal()
                        }
                        semaphore.wait()
                    } else if selectedFormat == "pptx" {
                        // PDF to PPTX - Extract text and create basic PowerPoint file
                        let semaphore = DispatchSemaphore(value: 0)
                        convertPDFToPPTX(pdfDocument: pdfDocument, destinationURL: destinationURL) { convSuccess, convMessage in
                            success = convSuccess
                            message = convMessage
                            semaphore.signal()
                        }
                        semaphore.wait()
                    } else {
                        message = "PDF to \(selectedFormat.uppercased()) conversion is not supported"
                    }
                } else {
                    message = "Failed to load PDF document"
                }
            }
            // Google Docs conversion
            else if sourceExt == "gdoc" {
                let semaphore = DispatchSemaphore(value: 0)
                convertGoogleDoc(sourceURL: sourceURL, destinationURL: destinationURL, format: selectedFormat) { convSuccess, convMessage in
                    success = convSuccess
                    message = convMessage
                    semaphore.signal()
                }
                semaphore.wait()
            }
            // Google Sheets conversion
            else if sourceExt == "gsheet" {
                let semaphore = DispatchSemaphore(value: 0)
                convertGoogleSheet(sourceURL: sourceURL, destinationURL: destinationURL, format: selectedFormat) { convSuccess, convMessage in
                    success = convSuccess
                    message = convMessage
                    semaphore.signal()
                }
                semaphore.wait()
            }
            // Office formats (DOCX, XLSX, PPTX) conversions
            else if sourceExt == "docx" || sourceExt == "doc" {
                let semaphore = DispatchSemaphore(value: 0)
                if selectedFormat == "pdf" {
                    // DOCX to PDF - Extract text and create PDF
                    convertOfficeToPDF(sourceURL: sourceURL, destinationURL: destinationURL, fileType: "docx") { convSuccess, convMessage in
                        success = convSuccess
                        message = convMessage
                        semaphore.signal()
                    }
                } else if selectedFormat == "txt" {
                    // DOCX to TXT - Extract text
                    convertOfficeToTXT(sourceURL: sourceURL, destinationURL: destinationURL, fileType: "docx") { convSuccess, convMessage in
                        success = convSuccess
                        message = convMessage
                        semaphore.signal()
                    }
                } else if selectedFormat == "rtf" {
                    // DOCX to RTF - Extract text and create RTF
                    convertOfficeToRTF(sourceURL: sourceURL, destinationURL: destinationURL, fileType: "docx") { convSuccess, convMessage in
                        success = convSuccess
                        message = convMessage
                        semaphore.signal()
                    }
                } else {
                    message = "Conversion from DOCX to \(selectedFormat.uppercased()) is not supported"
                    semaphore.signal()
                }
                semaphore.wait()
            }
            else if sourceExt == "xlsx" || sourceExt == "xls" {
                let semaphore = DispatchSemaphore(value: 0)
                if selectedFormat == "pdf" {
                    // XLSX to PDF - Extract text and create PDF
                    convertOfficeToPDF(sourceURL: sourceURL, destinationURL: destinationURL, fileType: "xlsx") { convSuccess, convMessage in
                        success = convSuccess
                        message = convMessage
                        semaphore.signal()
                    }
                } else if selectedFormat == "csv" {
                    // XLSX to CSV - Extract data and create CSV
                    convertOfficeToCSV(sourceURL: sourceURL, destinationURL: destinationURL) { convSuccess, convMessage in
                        success = convSuccess
                        message = convMessage
                        semaphore.signal()
                    }
                } else if selectedFormat == "txt" {
                    // XLSX to TXT - Extract text
                    convertOfficeToTXT(sourceURL: sourceURL, destinationURL: destinationURL, fileType: "xlsx") { convSuccess, convMessage in
                        success = convSuccess
                        message = convMessage
                        semaphore.signal()
                    }
                } else {
                    message = "Conversion from XLSX to \(selectedFormat.uppercased()) is not supported"
                    semaphore.signal()
                }
                semaphore.wait()
            }
            else if sourceExt == "pptx" || sourceExt == "ppt" {
                let semaphore = DispatchSemaphore(value: 0)
                if selectedFormat == "pdf" {
                    // PPTX to PDF - Extract text and create PDF
                    convertOfficeToPDF(sourceURL: sourceURL, destinationURL: destinationURL, fileType: "pptx") { convSuccess, convMessage in
                        success = convSuccess
                        message = convMessage
                        semaphore.signal()
                    }
                } else if selectedFormat == "txt" {
                    // PPTX to TXT - Extract text
                    convertOfficeToTXT(sourceURL: sourceURL, destinationURL: destinationURL, fileType: "pptx") { convSuccess, convMessage in
                        success = convSuccess
                        message = convMessage
                        semaphore.signal()
                    }
                } else {
                    message = "Conversion from PPTX to \(selectedFormat.uppercased()) is not supported"
                    semaphore.signal()
                }
                semaphore.wait()
            }
            // Text to Text or PDF
            else if isTextFormat(sourceExt) {
                if let textData = try? Data(contentsOf: sourceURL),
                   let text = String(data: textData, encoding: .utf8) {
                    if selectedFormat == "pdf" {
                        let pdfData = createPDF(from: text)
                        do {
                            try pdfData.write(to: destinationURL)
                            success = true
                            message = "Text converted to PDF successfully"
                        } catch {
                            message = "Failed to save PDF: \(error.localizedDescription)"
                        }
                    } else if isTextFormat(selectedFormat) {
                        // Simple text format conversion (just copy with new extension)
                        do {
                            try textData.write(to: destinationURL)
                            success = true
                            message = "File converted to \(selectedFormat.uppercased()) successfully"
                        } catch {
                            message = "Failed to save converted file: \(error.localizedDescription)"
                        }
                    }
                } else {
                    message = "Failed to read source text file"
                }
            }
            else {
                message = "Conversion from \(sourceExt.uppercased()) to \(selectedFormat.uppercased()) is not supported"
            }
            
            DispatchQueue.main.async {
                isConverting = false
                conversionMessage = message
                if success {
                    showSuccessAlert = true
                    // Notify file system of new file
                    NotificationCenter.default.post(name: NSNotification.Name("FileConverted"), object: nil)
                }
            }
        }
    }
    
    func isImageFormat(_ ext: String) -> Bool {
        let imageFormats = ["png", "jpg", "jpeg", "gif", "heic", "heif", "tiff", "tif", "bmp", "webp"]
        return imageFormats.contains(ext.lowercased())
    }
    
    func isTextFormat(_ ext: String) -> Bool {
        let textFormats = ["txt", "rtf", "html", "htm"]
        return textFormats.contains(ext.lowercased())
    }
    
    func getImageData(image: UIImage, format: String) -> Data? {
        switch format.lowercased() {
        case "png":
            return image.pngData()
        case "jpg", "jpeg":
            return image.jpegData(compressionQuality: 0.9)
        case "heic", "heif":
            // HEIF conversion requires more complex handling, fallback to JPEG
            return image.jpegData(compressionQuality: 0.9)
        case "tiff", "tif":
            // Use CGImageDestination to create TIFF data
            guard let cgImage = image.cgImage else { return nil }
            let mutableData = NSMutableData()
            guard let destination = CGImageDestinationCreateWithData(mutableData, "public.tiff" as CFString, 1, nil) else {
                return nil
            }
            CGImageDestinationAddImage(destination, cgImage, nil)
            guard CGImageDestinationFinalize(destination) else {
                return nil
            }
            return mutableData as Data
        default:
            return image.pngData()
        }
    }
    
    func createPDF(from image: UIImage) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size))
        return pdfRenderer.pdfData { context in
            context.beginPage()
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
    
    func createPDF(from text: String) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        return pdfRenderer.pdfData { context in
            context.beginPage()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            let textRect = CGRect(x: 50, y: 50, width: 512, height: 692)
            attributedString.draw(in: textRect)
        }
    }
    
    // MARK: - Google Docs/Sheets Conversion
    
    func convertGoogleDoc(sourceURL: URL, destinationURL: URL, format: String, completion: @escaping (Bool, String) -> Void) {
        // Read the .gdoc file - it can be JSON, plain text, or PDF (when imported via iOS Files app)
        guard let data = try? Data(contentsOf: sourceURL) else {
            completion(false, "Failed to read Google Doc file.")
            return
        }
        
        // Debug: Print file info
        print("📄 Google Doc file size: \(data.count) bytes")
        
        // Check if file is actually a PDF (common when imported via iOS Files app)
        if data.count >= 4 {
            let pdfHeader = data.prefix(4)
            if pdfHeader == Data([0x25, 0x50, 0x44, 0x46]) { // "%PDF"
                print("📄 File is actually a PDF, not a .gdoc shortcut file")
                // Handle PDF conversion
                handlePDFConversion(sourceURL: sourceURL, destinationURL: destinationURL, format: format, completion: completion)
                return
            }
        }
        
        if let text = String(data: data, encoding: .utf8) {
            print("📄 File content preview (first 1000 chars): \(String(text.prefix(1000)))")
        }
        
        var documentID: String?
        var docURL: URL?
        
        // Try to parse as JSON first
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("📄 Parsed as JSON: \(json.keys)")
            // Try different possible JSON keys
            if let urlString = json["url"] as? String {
                docURL = URL(string: urlString)
                print("📄 Found URL in 'url' field: \(urlString)")
            } else if let docUrl = json["doc_url"] as? String {
                docURL = URL(string: docUrl)
                print("📄 Found URL in 'doc_url' field: \(docUrl)")
            } else if let documentUrl = json["document_url"] as? String {
                docURL = URL(string: documentUrl)
                print("📄 Found URL in 'document_url' field: \(documentUrl)")
            } else {
                // Try to find any URL-like string in the JSON
                let jsonString = String(data: data, encoding: .utf8) ?? ""
                let urlPattern = #"https://docs\.google\.com/document/d/([a-zA-Z0-9_-]+)"#
                if let regex = try? NSRegularExpression(pattern: urlPattern, options: []),
                   let match = regex.firstMatch(in: jsonString, options: [], range: NSRange(jsonString.startIndex..., in: jsonString)),
                   let idRange = Range(match.range(at: 1), in: jsonString) {
                    documentID = String(jsonString[idRange])
                    print("📄 Found document ID via regex in JSON: \(documentID ?? "nil")")
                }
            }
        }
        
        // If JSON parsing didn't work, try reading as plain text
        if docURL == nil && documentID == nil, let text = String(data: data, encoding: .utf8) {
            print("📄 Trying plain text parsing...")
            // Look for Google Docs URL in the text
            let urlPattern = #"https://docs\.google\.com/document/d/([a-zA-Z0-9_-]+)"#
            if let regex = try? NSRegularExpression(pattern: urlPattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               let idRange = Range(match.range(at: 1), in: text) {
                documentID = String(text[idRange])
                print("📄 Found document ID via regex in text: \(documentID ?? "nil")")
            } else {
                // Try to find any Google Docs URL pattern
                let patterns = [
                    #"document/d/([a-zA-Z0-9_-]+)"#,
                    #"d/([a-zA-Z0-9_-]+)/"#,
                    #"id=([a-zA-Z0-9_-]+)"#
                ]
                for pattern in patterns {
                    if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                       let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
                       let idRange = Range(match.range(at: 1), in: text) {
                        let potentialID = String(text[idRange])
                        // Validate it looks like a Google ID (usually 44 chars, alphanumeric and dashes)
                        if potentialID.count > 20 && potentialID.count < 100 {
                            documentID = potentialID
                            print("📄 Found potential document ID via pattern \(pattern): \(documentID ?? "nil")")
                            break
                        }
                    }
                }
            }
            
            // Last resort: try to extract URL from text
            if documentID == nil {
                let urlDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                if let detector = urlDetector {
                    let matches = detector.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
                    for match in matches {
                        if let url = match.url, url.absoluteString.contains("docs.google.com") {
                            docURL = url
                            print("📄 Found Google URL via data detector: \(url.absoluteString)")
                            break
                        }
                    }
                }
            }
        }
        
        // Extract document ID from URL if we have a URL but not an ID
        if let url = docURL, documentID == nil {
            let pathComponents = url.pathComponents
            if let docIndex = pathComponents.firstIndex(of: "d"),
               docIndex + 1 < pathComponents.count {
                documentID = pathComponents[docIndex + 1]
                print("📄 Extracted document ID from URL: \(documentID ?? "nil")")
            }
        }
        
        guard let docID = documentID else {
            // Log the file content for debugging
            if let content = String(data: data, encoding: .utf8) {
                print("❌ Google Doc file content (full): \(content)")
            } else {
                print("❌ File is binary, cannot read as text")
                let hexString = data.prefix(100).map { String(format: "%02x", $0) }.joined(separator: " ")
                print("❌ First 100 bytes (hex): \(hexString)")
            }
            completion(false, "Could not extract document ID from Google Doc file. Please check the console for file content details.")
            return
        }
        
        // Determine export format and MIME type
        let (exportFormat, mimeType): (String, String) = {
            switch format.lowercased() {
            case "docx":
                return ("docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
            case "pdf":
                return ("pdf", "application/pdf")
            case "txt":
                return ("txt", "text/plain")
            default:
                return ("docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document")
            }
        }()
        
        // Construct Google export URL
        let exportURLString = "https://docs.google.com/document/d/\(docID)/export?format=\(exportFormat)"
        guard let exportURL = URL(string: exportURLString) else {
            completion(false, "Failed to create export URL.")
            return
        }
        
        // Download the exported file
        downloadGoogleFile(from: exportURL, to: destinationURL) { success, errorMessage in
            if success {
                completion(true, "Google Doc converted to \(format.uppercased()) successfully")
            } else {
                completion(false, errorMessage ?? "Failed to download converted file. The document may be private or require authentication.")
            }
        }
    }
    
    // Handle conversion when the file is actually a PDF (common with iOS Files app imports)
    func handlePDFConversion(sourceURL: URL, destinationURL: URL, format: String, completion: @escaping (Bool, String) -> Void) {
        let formatLower = format.lowercased()
        
        // If target format is PDF, just copy the file
        if formatLower == "pdf" {
            do {
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                completion(true, "File is already a PDF. Copied to \(destinationURL.lastPathComponent)")
            } catch {
                completion(false, "Failed to copy PDF file: \(error.localizedDescription)")
            }
            return
        }
        
        // Convert PDF to other formats
        if formatLower == "docx" {
            // PDF to DOCX is complex, suggest using the PDF directly or online conversion
            completion(false, "PDF to DOCX conversion is not supported. The file was imported as a PDF from Google Drive. You can rename it to .pdf or use online conversion tools.")
        } else if formatLower == "xlsx" {
            // PDF to XLSX is not possible
            completion(false, "PDF to XLSX conversion is not supported. The file was imported as a PDF from Google Drive. You can rename it to .pdf or use online conversion tools.")
        } else if formatLower == "csv" {
            // PDF to CSV is not possible
            completion(false, "PDF to CSV conversion is not supported. The file was imported as a PDF from Google Drive. You can rename it to .pdf or use online conversion tools.")
        } else if formatLower == "txt" {
            // Try to extract text from PDF
            if let pdfDocument = PDFDocument(url: sourceURL) {
                var text = ""
                for i in 0..<pdfDocument.pageCount {
                    if let page = pdfDocument.page(at: i) {
                        text += page.string ?? ""
                        text += "\n\n"
                    }
                }
                do {
                    try text.write(to: destinationURL, atomically: true, encoding: .utf8)
                    completion(true, "PDF converted to TXT successfully")
                } catch {
                    completion(false, "Failed to save text file: \(error.localizedDescription)")
                }
            } else {
                completion(false, "Failed to read PDF document")
            }
        } else if isImageFormat(formatLower) {
            // PDF to Image (first page)
            if let pdfDocument = PDFDocument(url: sourceURL) {
                if let firstPage = pdfDocument.page(at: 0) {
                    let pageRect = firstPage.bounds(for: .mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                    let image = renderer.image { ctx in
                        ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
                        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                        firstPage.draw(with: .mediaBox, to: ctx.cgContext)
                    }
                    
                    if let data = getImageData(image: image, format: formatLower) {
                        do {
                            try data.write(to: destinationURL)
                            completion(true, "PDF converted to \(format.uppercased()) successfully")
                        } catch {
                            completion(false, "Failed to save image: \(error.localizedDescription)")
                        }
                    } else {
                        completion(false, "Failed to convert PDF page to image")
                    }
                } else {
                    completion(false, "PDF has no pages")
                }
            } else {
                completion(false, "Failed to load PDF document")
            }
        } else {
            completion(false, "PDF to \(format.uppercased()) conversion is not supported. The file is already a PDF.")
        }
    }
    
    func convertGoogleSheet(sourceURL: URL, destinationURL: URL, format: String, completion: @escaping (Bool, String) -> Void) {
        // Read the .gsheet file - it can be JSON, plain text, or PDF (when imported via iOS Files app)
        guard let data = try? Data(contentsOf: sourceURL) else {
            completion(false, "Failed to read Google Sheet file.")
            return
        }
        
        // Debug: Print file info
        print("📄 Google Sheet file size: \(data.count) bytes")
        
        // Check if file is actually a PDF (common when imported via iOS Files app)
        if data.count >= 4 {
            let pdfHeader = data.prefix(4)
            if pdfHeader == Data([0x25, 0x50, 0x44, 0x46]) { // "%PDF"
                print("📄 File is actually a PDF, not a .gsheet shortcut file")
                // Handle PDF conversion
                handlePDFConversion(sourceURL: sourceURL, destinationURL: destinationURL, format: format, completion: completion)
                return
            }
        }
        
        if let text = String(data: data, encoding: .utf8) {
            print("📄 File content preview (first 1000 chars): \(String(text.prefix(1000)))")
        } else {
            print("📄 File is not UTF-8 text, might be binary")
            // Try to find URL in binary data
            if let text = String(data: data, encoding: .utf16) {
                print("📄 File as UTF-16: \(String(text.prefix(1000)))")
            }
        }
        
        var spreadsheetID: String?
        var sheetURL: URL?
        
        // Try to parse as JSON first
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("📄 Parsed as JSON: \(json.keys)")
            // Try different possible JSON keys
            if let urlString = json["url"] as? String {
                sheetURL = URL(string: urlString)
                print("📄 Found URL in 'url' field: \(urlString)")
            } else if let sheetUrl = json["sheet_url"] as? String {
                sheetURL = URL(string: sheetUrl)
                print("📄 Found URL in 'sheet_url' field: \(sheetUrl)")
            } else if let spreadsheetUrl = json["spreadsheet_url"] as? String {
                sheetURL = URL(string: spreadsheetUrl)
                print("📄 Found URL in 'spreadsheet_url' field: \(spreadsheetUrl)")
            } else {
                // Try to find any URL-like string in the JSON
                let jsonString = String(data: data, encoding: .utf8) ?? ""
                let urlPattern = #"https://docs\.google\.com/spreadsheets/d/([a-zA-Z0-9_-]+)"#
                if let regex = try? NSRegularExpression(pattern: urlPattern, options: []),
                   let match = regex.firstMatch(in: jsonString, options: [], range: NSRange(jsonString.startIndex..., in: jsonString)),
                   let idRange = Range(match.range(at: 1), in: jsonString) {
                    spreadsheetID = String(jsonString[idRange])
                    print("📄 Found spreadsheet ID via regex in JSON: \(spreadsheetID ?? "nil")")
                }
            }
        }
        
        // If JSON parsing didn't work, try reading as plain text
        if sheetURL == nil && spreadsheetID == nil, let text = String(data: data, encoding: .utf8) {
            print("📄 Trying plain text parsing...")
            // Look for Google Sheets URL in the text
            let urlPattern = #"https://docs\.google\.com/spreadsheets/d/([a-zA-Z0-9_-]+)"#
            if let regex = try? NSRegularExpression(pattern: urlPattern, options: []),
               let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
               let idRange = Range(match.range(at: 1), in: text) {
                spreadsheetID = String(text[idRange])
                print("📄 Found spreadsheet ID via regex in text: \(spreadsheetID ?? "nil")")
            } else {
                // Try to find any Google Sheets URL pattern
                let patterns = [
                    #"spreadsheets/d/([a-zA-Z0-9_-]+)"#,
                    #"d/([a-zA-Z0-9_-]+)/"#,
                    #"id=([a-zA-Z0-9_-]+)"#
                ]
                for pattern in patterns {
                    if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                       let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
                       let idRange = Range(match.range(at: 1), in: text) {
                        let potentialID = String(text[idRange])
                        // Validate it looks like a Google ID (usually 44 chars, alphanumeric and dashes)
                        if potentialID.count > 20 && potentialID.count < 100 {
                            spreadsheetID = potentialID
                            print("📄 Found potential spreadsheet ID via pattern \(pattern): \(spreadsheetID ?? "nil")")
                            break
                        }
                    }
                }
            }
            
            // Last resort: try to extract URL from text
            if spreadsheetID == nil {
                let urlDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                if let detector = urlDetector {
                    let matches = detector.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
                    for match in matches {
                        if let url = match.url, url.absoluteString.contains("docs.google.com") {
                            sheetURL = url
                            print("📄 Found Google URL via data detector: \(url.absoluteString)")
                            break
                        }
                    }
                }
            }
        }
        
        // Extract spreadsheet ID from URL if we have a URL but not an ID
        if let url = sheetURL, spreadsheetID == nil {
            let pathComponents = url.pathComponents
            if let sheetIndex = pathComponents.firstIndex(of: "d"),
               sheetIndex + 1 < pathComponents.count {
                spreadsheetID = pathComponents[sheetIndex + 1]
                print("📄 Extracted spreadsheet ID from URL: \(spreadsheetID ?? "nil")")
            }
        }
        
        guard let sheetID = spreadsheetID else {
            // Log the file content for debugging
            if let content = String(data: data, encoding: .utf8) {
                print("❌ Google Sheet file content (full): \(content)")
            } else {
                print("❌ File is binary, cannot read as text")
                // Try hex dump of first bytes
                let hexString = data.prefix(100).map { String(format: "%02x", $0) }.joined(separator: " ")
                print("❌ First 100 bytes (hex): \(hexString)")
            }
            completion(false, "Could not extract spreadsheet ID from Google Sheet file. Please check the console for file content details.")
            return
        }
        
        // Determine export format
        let (exportFormat, mimeType): (String, String) = {
            switch format.lowercased() {
            case "xlsx":
                return ("xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
            case "csv":
                return ("csv", "text/csv")
            case "pdf":
                return ("pdf", "application/pdf")
            default:
                return ("xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
            }
        }()
        
        // Construct Google export URL
        let exportURLString = "https://docs.google.com/spreadsheets/d/\(sheetID)/export?format=\(exportFormat)"
        guard let exportURL = URL(string: exportURLString) else {
            completion(false, "Failed to create export URL.")
            return
        }
        
        // Download the exported file
        downloadGoogleFile(from: exportURL, to: destinationURL) { success, errorMessage in
            if success {
                completion(true, "Google Sheet converted to \(format.uppercased()) successfully")
            } else {
                completion(false, errorMessage ?? "Failed to download converted file. The spreadsheet may be private or require authentication.")
            }
        }
    }
    
    func downloadGoogleFile(from url: URL, to destination: URL, completion: @escaping (Bool, String?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(false, "Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, "Invalid response from server")
                return
            }
            
            // Check if we got an error page (Google returns HTML error pages for private docs)
            if httpResponse.statusCode != 200 {
                if let data = data,
                   let htmlString = String(data: data, encoding: .utf8),
                   htmlString.contains("<html") {
                    completion(false, "Document is private or requires authentication. Please make the document publicly accessible or use Google Drive API with authentication.")
                } else {
                    completion(false, "Server returned error code: \(httpResponse.statusCode)")
                }
                return
            }
            
            guard let data = data else {
                completion(false, "No data received from server")
                return
            }
            
            // Save the downloaded file
            do {
                try data.write(to: destination)
                completion(true, nil)
            } catch {
                completion(false, "Failed to save file: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    // MARK: - Office Format Conversions
    
    // Convert Office files (DOCX, XLSX, PPTX) to PDF
    func convertOfficeToPDF(sourceURL: URL, destinationURL: URL, fileType: String, completion: @escaping (Bool, String) -> Void) {
        // Extract text from Office file and create PDF
        extractTextFromOffice(sourceURL: sourceURL, fileType: fileType) { extractedText, error in
            guard let text = extractedText, !text.isEmpty else {
                completion(false, error ?? "Failed to extract text from \(fileType.uppercased()) file")
                return
            }
            
            // Create PDF from extracted text
            let pdfData = self.createPDF(from: text)
            do {
                try pdfData.write(to: destinationURL)
                completion(true, "\(fileType.uppercased()) converted to PDF successfully")
            } catch {
                completion(false, "Failed to save PDF: \(error.localizedDescription)")
            }
        }
    }
    
    // Convert Office files to TXT
    func convertOfficeToTXT(sourceURL: URL, destinationURL: URL, fileType: String, completion: @escaping (Bool, String) -> Void) {
        extractTextFromOffice(sourceURL: sourceURL, fileType: fileType) { extractedText, error in
            guard let text = extractedText, !text.isEmpty else {
                completion(false, error ?? "Failed to extract text from \(fileType.uppercased()) file")
                return
            }
            
            do {
                try text.write(to: destinationURL, atomically: true, encoding: .utf8)
                completion(true, "\(fileType.uppercased()) converted to TXT successfully")
            } catch {
                completion(false, "Failed to save TXT file: \(error.localizedDescription)")
            }
        }
    }
    
    // Convert Office files to RTF
    func convertOfficeToRTF(sourceURL: URL, destinationURL: URL, fileType: String, completion: @escaping (Bool, String) -> Void) {
        extractTextFromOffice(sourceURL: sourceURL, fileType: fileType) { extractedText, error in
            guard let text = extractedText, !text.isEmpty else {
                completion(false, error ?? "Failed to extract text from \(fileType.uppercased()) file")
                return
            }
            
            // Create basic RTF from text
            let rtfContent = self.createRTF(from: text)
            do {
                try rtfContent.write(to: destinationURL, atomically: true, encoding: .utf8)
                completion(true, "\(fileType.uppercased()) converted to RTF successfully")
            } catch {
                completion(false, "Failed to save RTF file: \(error.localizedDescription)")
            }
        }
    }
    
    // Convert XLSX to CSV
    func convertOfficeToCSV(sourceURL: URL, destinationURL: URL, completion: @escaping (Bool, String) -> Void) {
        // Extract data from XLSX and create CSV
        extractDataFromXLSX(sourceURL: sourceURL) { rows, error in
            guard let dataRows = rows, !dataRows.isEmpty else {
                completion(false, error ?? "Failed to extract data from XLSX file")
                return
            }
            
            // Create CSV content
            let csvContent = dataRows.map { row in
                row.map { cell in
                    // Escape quotes and wrap in quotes if contains comma or quote
                    let escaped = cell.replacingOccurrences(of: "\"", with: "\"\"")
                    if escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n") {
                        return "\"\(escaped)\""
                    }
                    return escaped
                }.joined(separator: ",")
            }.joined(separator: "\n")
            
            do {
                try csvContent.write(to: destinationURL, atomically: true, encoding: .utf8)
                completion(true, "XLSX converted to CSV successfully")
            } catch {
                completion(false, "Failed to save CSV file: \(error.localizedDescription)")
            }
        }
    }
    
    // Extract text from Office files (DOCX, XLSX, PPTX)
    func extractTextFromOffice(sourceURL: URL, fileType: String, completion: @escaping (String?, String?) -> Void) {
        // Office files are ZIP archives containing XML
        guard let archive = Archive(url: sourceURL, accessMode: .read) else {
            completion(nil, "Failed to open \(fileType.uppercased()) file")
            return
        }
        
        var extractedText = ""
        
        // Extract text from XML files in the archive
        for entry in archive {
            let entryPath = entry.path
            
            if fileType == "docx" && entryPath.hasPrefix("word/") && entryPath.hasSuffix(".xml") {
                var fileData = Data()
                do {
                    _ = try archive.extract(entry) { (chunk: Data) in
                        fileData.append(chunk)
                    }
                    if let xmlString = String(data: fileData, encoding: .utf8) {
                        extractedText += extractTextFromXML(xmlString) + "\n\n"
                    }
                } catch {
                    print("Failed to extract \(entryPath): \(error)")
                }
            } else if fileType == "xlsx" && entryPath.hasPrefix("xl/worksheets/") && entryPath.hasSuffix(".xml") {
                var fileData = Data()
                do {
                    _ = try archive.extract(entry) { (chunk: Data) in
                        fileData.append(chunk)
                    }
                    if let xmlString = String(data: fileData, encoding: .utf8) {
                        extractedText += extractTextFromXLSXXML(xmlString) + "\n"
                    }
                } catch {
                    print("Failed to extract \(entryPath): \(error)")
                }
            } else if fileType == "pptx" && entryPath.hasPrefix("ppt/slides/") && entryPath.hasSuffix(".xml") {
                var fileData = Data()
                do {
                    _ = try archive.extract(entry) { (chunk: Data) in
                        fileData.append(chunk)
                    }
                    if let xmlString = String(data: fileData, encoding: .utf8) {
                        extractedText += extractTextFromXML(xmlString) + "\n\n"
                    }
                } catch {
                    print("Failed to extract \(entryPath): \(error)")
                }
            }
        }
        
        if extractedText.isEmpty {
            completion(nil, "No text could be extracted from \(fileType.uppercased()) file")
        } else {
            completion(extractedText.trimmingCharacters(in: .whitespacesAndNewlines), nil)
        }
    }
    
    // Extract data from XLSX file
    func extractDataFromXLSX(sourceURL: URL, completion: @escaping ([[String]]?, String?) -> Void) {
        guard let archive = Archive(url: sourceURL, accessMode: .read) else {
            completion(nil, "Failed to open XLSX file")
            return
        }
        
        var allRows: [[String]] = []
        
        // Read shared strings first
        var sharedStrings: [String] = []
        if let sharedStringsEntry = archive["xl/sharedStrings.xml"] {
            var sharedStringsData = Data()
            do {
                _ = try archive.extract(sharedStringsEntry) { (chunk: Data) in
                    sharedStringsData.append(chunk)
                }
                if let xmlString = String(data: sharedStringsData, encoding: .utf8) {
                    sharedStrings = extractSharedStringsFromXML(xmlString)
                }
            } catch {
                print("Failed to extract shared strings: \(error)")
            }
        }
        
        // Read worksheet data
        for entry in archive {
            if entry.path.hasPrefix("xl/worksheets/") && entry.path.hasSuffix(".xml") {
                var worksheetData = Data()
                do {
                    _ = try archive.extract(entry) { (chunk: Data) in
                        worksheetData.append(chunk)
                    }
                    if let xmlString = String(data: worksheetData, encoding: .utf8) {
                        let rows = extractRowsFromXLSXXML(xmlString, sharedStrings: sharedStrings)
                        allRows.append(contentsOf: rows)
                    }
                } catch {
                    print("Failed to extract worksheet \(entry.path): \(error)")
                }
            }
        }
        
        if allRows.isEmpty {
            completion(nil, "No data could be extracted from XLSX file")
        } else {
            completion(allRows, nil)
        }
    }
    
    // Helper to extract text from XML (simple regex-based extraction)
    func extractTextFromXML(_ xml: String) -> String {
        // Extract text between <w:t> tags for DOCX or <a:t> tags for PPTX
        var text = ""
        let pattern = "<(?:w|a):t[^>]*>([^<]*)</(?:w|a):t>"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: xml, options: [], range: NSRange(xml.startIndex..., in: xml))
            for match in matches {
                if let range = Range(match.range(at: 1), in: xml) {
                    text += xml[range] + " "
                }
            }
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Helper to extract text from XLSX XML
    func extractTextFromXLSXXML(_ xml: String) -> String {
        var text = ""
        // Extract values from <v> tags or shared string references
        let pattern = "<v>([^<]*)</v>"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: xml, options: [], range: NSRange(xml.startIndex..., in: xml))
            for match in matches {
                if let range = Range(match.range(at: 1), in: xml) {
                    text += xml[range] + " "
                }
            }
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Helper to extract shared strings from XLSX
    func extractSharedStringsFromXML(_ xml: String) -> [String] {
        var strings: [String] = []
        let pattern = "<t[^>]*>([^<]*)</t>"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: xml, options: [], range: NSRange(xml.startIndex..., in: xml))
            for match in matches {
                if let range = Range(match.range(at: 1), in: xml) {
                    strings.append(String(xml[range]))
                }
            }
        }
        return strings
    }
    
    // Helper to extract rows from XLSX XML
    func extractRowsFromXLSXXML(_ xml: String, sharedStrings: [String]) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        
        // Extract cells from <c> tags
        let cellPattern = "<c[^>]*r=\"([A-Z]+)(\\d+)\"[^>]*>.*?<v>([^<]*)</v>"
        if let regex = try? NSRegularExpression(pattern: cellPattern, options: [.dotMatchesLineSeparators]) {
            let matches = regex.matches(in: xml, options: [], range: NSRange(xml.startIndex..., in: xml))
            var lastRowNum = 0
            
            for match in matches {
                if match.numberOfRanges >= 4 {
                    if let rowRange = Range(match.range(at: 2), in: xml),
                       let valueRange = Range(match.range(at: 3), in: xml) {
                        let rowNum = Int(xml[rowRange]) ?? 0
                        let value = String(xml[valueRange])
                        
                        if rowNum != lastRowNum && !currentRow.isEmpty {
                            rows.append(currentRow)
                            currentRow = []
                        }
                        currentRow.append(value)
                        lastRowNum = rowNum
                    }
                }
            }
            if !currentRow.isEmpty {
                rows.append(currentRow)
            }
        }
        
        return rows.isEmpty ? [["No data found"]] : rows
    }
    
    // Create RTF from text
    func createRTF(from text: String) -> String {
        let escapedText = text
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "{", with: "\\{")
            .replacingOccurrences(of: "}", with: "\\}")
            .replacingOccurrences(of: "\n", with: "\\par\n")
        
        return "{\\rtf1\\ansi\\deff0 {\\fonttbl {\\f0 Times New Roman;}}\\f0\\fs24 \(escapedText)}"
    }
    
    // MARK: - PDF to Office Format Conversions
    
    func convertPDFToDOCX(pdfDocument: PDFDocument, destinationURL: URL, completion: @escaping (Bool, String) -> Void) {
        // Extract text from all pages
        var extractedText = ""
        for i in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: i) {
                if let pageText = page.string {
                    extractedText += pageText
                    if i < pdfDocument.pageCount - 1 {
                        extractedText += "\n\n"
                    }
                }
            }
        }
        
        guard !extractedText.isEmpty else {
            completion(false, "No text could be extracted from PDF")
            return
        }
        
        // Create a basic DOCX file (ZIP archive with XML)
        createBasicDOCX(text: extractedText, destinationURL: destinationURL, completion: completion)
    }
    
    func convertPDFToXLSX(pdfDocument: PDFDocument, destinationURL: URL, completion: @escaping (Bool, String) -> Void) {
        // Extract text from all pages
        var extractedText = ""
        for i in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: i) {
                if let pageText = page.string {
                    extractedText += pageText
                    if i < pdfDocument.pageCount - 1 {
                        extractedText += "\n"
                    }
                }
            }
        }
        
        guard !extractedText.isEmpty else {
            completion(false, "No text could be extracted from PDF")
            return
        }
        
        // Create a basic XLSX file (ZIP archive with XML)
        createBasicXLSX(text: extractedText, destinationURL: destinationURL, completion: completion)
    }
    
    func convertPDFToPPTX(pdfDocument: PDFDocument, destinationURL: URL, completion: @escaping (Bool, String) -> Void) {
        // Extract text from pages (each page becomes a slide)
        var slides: [String] = []
        for i in 0..<pdfDocument.pageCount {
            if let page = pdfDocument.page(at: i) {
                if let pageText = page.string {
                    slides.append(pageText)
                }
            }
        }
        
        guard !slides.isEmpty else {
            completion(false, "No text could be extracted from PDF")
            return
        }
        
        // Create a basic PPTX file (ZIP archive with XML)
        createBasicPPTX(slides: slides, destinationURL: destinationURL, completion: completion)
    }
    
    // Create a basic DOCX file
    func createBasicDOCX(text: String, destinationURL: URL, completion: @escaping (Bool, String) -> Void) {
        // DOCX is a ZIP file containing XML files
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            
            // Create [Content_Types].xml
            let contentTypes = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
                <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
                <Default Extension="xml" ContentType="application/xml"/>
                <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
            </Types>
            """
            try contentTypes.write(to: tempDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)
            
            // Create _rels/.rels
            let relsDir = tempDir.appendingPathComponent("_rels")
            try FileManager.default.createDirectory(at: relsDir, withIntermediateDirectories: true)
            let rels = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
                <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
            </Relationships>
            """
            try rels.write(to: relsDir.appendingPathComponent(".rels"), atomically: true, encoding: .utf8)
            
            // Create word directory
            let wordDir = tempDir.appendingPathComponent("word")
            try FileManager.default.createDirectory(at: wordDir, withIntermediateDirectories: true)
            
            // Create word/_rels directory
            let wordRelsDir = wordDir.appendingPathComponent("_rels")
            try FileManager.default.createDirectory(at: wordRelsDir, withIntermediateDirectories: true)
            let wordRels = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
            </Relationships>
            """
            try wordRels.write(to: wordRelsDir.appendingPathComponent("document.xml.rels"), atomically: true, encoding: .utf8)
            
            // Create word/document.xml with extracted text
            let escapedText = text
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
                .replacingOccurrences(of: "\"", with: "&quot;")
                .replacingOccurrences(of: "'", with: "&apos;")
            
            let paragraphs = escapedText.components(separatedBy: "\n").map { line in
                "<w:p><w:r><w:t>\(line.isEmpty ? " " : line)</w:t></w:r></w:p>"
            }.joined()
            
            let documentXML = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
                <w:body>
                    \(paragraphs)
                </w:body>
            </w:document>
            """
            try documentXML.write(to: wordDir.appendingPathComponent("document.xml"), atomically: true, encoding: .utf8)
            
            // Create required Office metadata files
            // Create docProps/app.xml
            let docPropsDir = tempDir.appendingPathComponent("docProps")
            try FileManager.default.createDirectory(at: docPropsDir, withIntermediateDirectories: true)
            let appXML = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
                <Application>yyDrive</Application>
                <TotalTime>0</TotalTime>
            </Properties>
            """
            try appXML.write(to: docPropsDir.appendingPathComponent("app.xml"), atomically: true, encoding: .utf8)
            
            // Create docProps/core.xml
            let coreXML = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <dc:creator>yyDrive</dc:creator>
                <dcterms:created xsi:type="dcterms:W3CDTF">\(ISO8601DateFormatter().string(from: Date()))</dcterms:created>
                <dcterms:modified xsi:type="dcterms:W3CDTF">\(ISO8601DateFormatter().string(from: Date()))</dcterms:modified>
            </cp:coreProperties>
            """
            try coreXML.write(to: docPropsDir.appendingPathComponent("core.xml"), atomically: true, encoding: .utf8)
            
            // Update [Content_Types].xml to include docProps
            let updatedContentTypes = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
                <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
                <Default Extension="xml" ContentType="application/xml"/>
                <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
                <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
                <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
            </Types>
            """
            try updatedContentTypes.write(to: tempDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)
            
            // Update _rels/.rels to include docProps
            let updatedRels = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
                <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
                <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
                <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
            </Relationships>
            """
            try updatedRels.write(to: relsDir.appendingPathComponent(".rels"), atomically: true, encoding: .utf8)
            
            // Create ZIP file (DOCX is a ZIP archive) using ZIPFoundation
            guard let archive = Archive(url: destinationURL, accessMode: .create) else {
                try? FileManager.default.removeItem(at: tempDir)
                completion(false, "Failed to create ZIP archive")
                return
            }
            
            // Add all files to the archive
            try addFilesToArchive(archive: archive, from: tempDir, basePath: "")
            
            // Clean up temp directory
            try? FileManager.default.removeItem(at: tempDir)
            
            completion(true, "PDF converted to DOCX successfully")
        } catch {
            try? FileManager.default.removeItem(at: tempDir)
            completion(false, "Failed to create DOCX: \(error.localizedDescription)")
        }
    }
    
    // Create a basic XLSX file
    func createBasicXLSX(text: String, destinationURL: URL, completion: @escaping (Bool, String) -> Void) {
        // XLSX is a ZIP file containing XML
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            
            // Create [Content_Types].xml
            let contentTypes = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
                <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
                <Default Extension="xml" ContentType="application/xml"/>
                <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
                <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
            </Types>
            """
            try contentTypes.write(to: tempDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)
            
            // Create _rels/.rels
            let relsDir = tempDir.appendingPathComponent("_rels")
            try FileManager.default.createDirectory(at: relsDir, withIntermediateDirectories: true)
            let rels = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
                <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
            </Relationships>
            """
            try rels.write(to: relsDir.appendingPathComponent(".rels"), atomically: true, encoding: .utf8)
            
            // Create xl directory
            let xlDir = tempDir.appendingPathComponent("xl")
            try FileManager.default.createDirectory(at: xlDir, withIntermediateDirectories: true)
            
            // Create xl/_rels/workbook.xml.rels
            let xlRelsDir = xlDir.appendingPathComponent("_rels")
            try FileManager.default.createDirectory(at: xlRelsDir, withIntermediateDirectories: true)
            let xlRels = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
                <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
            </Relationships>
            """
            try xlRels.write(to: xlRelsDir.appendingPathComponent("workbook.xml.rels"), atomically: true, encoding: .utf8)
            
            // Create xl/workbook.xml
            let workbookXML = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
                <sheets>
                    <sheet name="Sheet1" sheetId="1" r:id="rId1"/>
                </sheets>
            </workbook>
            """
            try workbookXML.write(to: xlDir.appendingPathComponent("workbook.xml"), atomically: true, encoding: .utf8)
            
            // Create xl/worksheets directory
            let worksheetsDir = xlDir.appendingPathComponent("worksheets")
            try FileManager.default.createDirectory(at: worksheetsDir, withIntermediateDirectories: true)
            
            // Create xl/worksheets/sheet1.xml with text in rows
            let lines = text.components(separatedBy: "\n")
            var rows: [String] = []
            for (index, line) in lines.enumerated() {
                let escapedLine = line
                    .replacingOccurrences(of: "&", with: "&amp;")
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: ">", with: "&gt;")
                    .replacingOccurrences(of: "\"", with: "&quot;")
                    .replacingOccurrences(of: "'", with: "&apos;")
                let rowNum = index + 1
                rows.append("<row r=\"\(rowNum)\"><c r=\"A\(rowNum)\" t=\"str\"><v>\(escapedLine.isEmpty ? " " : escapedLine)</v></c></row>")
            }
            
            let sheetXML = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
                <sheetData>
                    \(rows.joined())
                </sheetData>
            </worksheet>
            """
            try sheetXML.write(to: worksheetsDir.appendingPathComponent("sheet1.xml"), atomically: true, encoding: .utf8)
            
            // Create required Office metadata files
            // Create docProps/app.xml
            let docPropsDir = tempDir.appendingPathComponent("docProps")
            try FileManager.default.createDirectory(at: docPropsDir, withIntermediateDirectories: true)
            let appXML = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
                <Application>yyDrive</Application>
                <TotalTime>0</TotalTime>
            </Properties>
            """
            try appXML.write(to: docPropsDir.appendingPathComponent("app.xml"), atomically: true, encoding: .utf8)
            
            // Create docProps/core.xml
            let coreXML = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <dc:creator>yyDrive</dc:creator>
                <dcterms:created xsi:type="dcterms:W3CDTF">\(ISO8601DateFormatter().string(from: Date()))</dcterms:created>
                <dcterms:modified xsi:type="dcterms:W3CDTF">\(ISO8601DateFormatter().string(from: Date()))</dcterms:modified>
            </cp:coreProperties>
            """
            try coreXML.write(to: docPropsDir.appendingPathComponent("core.xml"), atomically: true, encoding: .utf8)
            
            // Update [Content_Types].xml to include docProps
            let updatedContentTypes = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
                <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
                <Default Extension="xml" ContentType="application/xml"/>
                <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
                <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
                <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
                <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
            </Types>
            """
            try updatedContentTypes.write(to: tempDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)
            
            // Update _rels/.rels to include docProps
            let updatedRels = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
                <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
                <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
                <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
            </Relationships>
            """
            try updatedRels.write(to: relsDir.appendingPathComponent(".rels"), atomically: true, encoding: .utf8)
            
            // Create ZIP file (XLSX is a ZIP archive) using ZIPFoundation
            guard let archive = Archive(url: destinationURL, accessMode: .create) else {
                try? FileManager.default.removeItem(at: tempDir)
                completion(false, "Failed to create ZIP archive")
                return
            }
            
            // Add all files to the archive
            try addFilesToArchive(archive: archive, from: tempDir, basePath: "")
            
            // Clean up temp directory
            try? FileManager.default.removeItem(at: tempDir)
            
            completion(true, "PDF converted to XLSX successfully")
        } catch {
            try? FileManager.default.removeItem(at: tempDir)
            completion(false, "Failed to create XLSX: \(error.localizedDescription)")
        }
    }
    
    // Create a basic PPTX file
    func createBasicPPTX(slides: [String], destinationURL: URL, completion: @escaping (Bool, String) -> Void) {
        // PPTX is a ZIP file containing XML
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            
            // Create [Content_Types].xml
            var contentTypeOverrides = ""
            for i in 0..<slides.count {
                contentTypeOverrides += "<Override PartName=\"/ppt/slides/slide\(i+1).xml\" ContentType=\"application/vnd.openxmlformats-officedocument.presentationml.slide+xml\"/>"
            }
            
            let contentTypes = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
                <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
                <Default Extension="xml" ContentType="application/xml"/>
                <Override PartName="/ppt/presentation.xml" ContentType="application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml"/>
                \(contentTypeOverrides)
            </Types>
            """
            try contentTypes.write(to: tempDir.appendingPathComponent("[Content_Types].xml"), atomically: true, encoding: .utf8)
            
            // Create _rels/.rels
            let relsDir = tempDir.appendingPathComponent("_rels")
            try FileManager.default.createDirectory(at: relsDir, withIntermediateDirectories: true)
            let rels = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
                <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="ppt/presentation.xml"/>
            </Relationships>
            """
            try rels.write(to: relsDir.appendingPathComponent(".rels"), atomically: true, encoding: .utf8)
            
            // Create ppt directory
            let pptDir = tempDir.appendingPathComponent("ppt")
            try FileManager.default.createDirectory(at: pptDir, withIntermediateDirectories: true)
            
            // Create ppt/_rels/presentation.xml.rels
            let pptRelsDir = pptDir.appendingPathComponent("_rels")
            try FileManager.default.createDirectory(at: pptRelsDir, withIntermediateDirectories: true)
            var slideRels = ""
            for i in 0..<slides.count {
                slideRels += "<Relationship Id=\"rId\(i+1)\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/slide\" Target=\"slides/slide\(i+1).xml\"/>"
            }
            
            let pptRels = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
                \(slideRels)
            </Relationships>
            """
            try pptRels.write(to: pptRelsDir.appendingPathComponent("presentation.xml.rels"), atomically: true, encoding: .utf8)
            
            // Create ppt/presentation.xml
            var slideIds = ""
            for i in 0..<slides.count {
                slideIds += "<p:sldId id=\"\(256 + i)\" r:id=\"rId\(i+1)\"/>"
            }
            
            let presentationXML = """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <p:presentation xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
                <p:sldMasterIdLst>
                    <p:sldMasterId id="2147483648" r:id="rId1"/>
                </p:sldMasterIdLst>
                <p:sldIdLst>
                    \(slideIds)
                </p:sldIdLst>
            </p:presentation>
            """
            try presentationXML.write(to: pptDir.appendingPathComponent("presentation.xml"), atomically: true, encoding: .utf8)
            
            // Create ppt/slides directory
            let slidesDir = pptDir.appendingPathComponent("slides")
            try FileManager.default.createDirectory(at: slidesDir, withIntermediateDirectories: true)
            
            // Create slide XML files
            for (index, slideText) in slides.enumerated() {
                let escapedText = slideText
                    .replacingOccurrences(of: "&", with: "&amp;")
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: ">", with: "&gt;")
                    .replacingOccurrences(of: "\"", with: "&quot;")
                    .replacingOccurrences(of: "'", with: "&apos;")
                
                let slideXML = """
                <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
                <p:sld xmlns:p="http://schemas.openxmlformats.org/presentationml/2006/main">
                    <p:cSld>
                        <p:spTree>
                            <p:nvGrpSpPr>
                                <p:cNvPr id="1" name=""/>
                                <p:cNvGrpSpPr/>
                                <p:nvPr/>
                            </p:nvGrpSpPr>
                            <p:grpSpPr/>
                            <p:sp>
                                <p:nvSpPr>
                                    <p:cNvPr id="2" name="Text Placeholder"/>
                                    <p:cNvSpPr txBox="1"/>
                                    <p:nvPr/>
                                </p:nvSpPr>
                                <p:spPr/>
                                <p:txBody>
                                    <a:bodyPr/>
                                    <a:p>
                                        <a:r>
                                            <a:t>\(escapedText.isEmpty ? " " : escapedText)</a:t>
                                        </a:r>
                                    </a:p>
                                </p:txBody>
                            </p:sp>
                        </p:spTree>
                    </p:cSld>
                </p:sld>
                """
                try slideXML.write(to: slidesDir.appendingPathComponent("slide\(index+1).xml"), atomically: true, encoding: .utf8)
            }
            
            // Create ZIP file (PPTX is a ZIP archive) using ZIPFoundation
            guard let archive = Archive(url: destinationURL, accessMode: .create) else {
                try? FileManager.default.removeItem(at: tempDir)
                completion(false, "Failed to create ZIP archive")
                return
            }
            
            // Add all files to the archive
            try addFilesToArchive(archive: archive, from: tempDir, basePath: "")
            
            // Clean up temp directory
            try? FileManager.default.removeItem(at: tempDir)
            
            completion(true, "PDF converted to PPTX successfully")
        } catch {
            try? FileManager.default.removeItem(at: tempDir)
            completion(false, "Failed to create PPTX: \(error.localizedDescription)")
        }
    }
    
    // Helper function to add files to ZIP archive using ZIPFoundation
    func addFilesToArchive(archive: Archive, from directory: URL, basePath: String) throws {
        let fileManager = FileManager.default
        var allFiles: [(path: String, url: URL)] = []
        
        // Collect all files recursively
        func collectFiles(from dir: URL, basePath: String = "") throws {
            let contents = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isDirectoryKey], options: [])
            
            for fileURL in contents {
                // Use forward slashes for ZIP file paths (Office format requirement)
                let fileName = fileURL.lastPathComponent
                let relativePath = basePath.isEmpty ? fileName : "\(basePath)/\(fileName)"
                
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                    // Recursively collect directory contents
                    try collectFiles(from: fileURL, basePath: relativePath)
                } else {
                    allFiles.append((path: relativePath, url: fileURL))
                }
            }
        }
        
        try collectFiles(from: directory, basePath: basePath)
        
        // Sort files: [Content_Types].xml should be first, then _rels/.rels, then others
        allFiles.sort { first, second in
            if first.path == "[Content_Types].xml" { return true }
            if second.path == "[Content_Types].xml" { return false }
            if first.path == "_rels/.rels" { return true }
            if second.path == "_rels/.rels" { return false }
            return first.path < second.path
        }
        
        // Add files to archive in sorted order
        for (relativePath, fileURL) in allFiles {
            let fileData = try Data(contentsOf: fileURL)
            try archive.addEntry(with: relativePath, type: .file, uncompressedSize: Int64(fileData.count), bufferSize: 4096, provider: { (position, size) -> Data in
                let start = Int(position)
                let end = min(start + size, fileData.count)
                return fileData.subdata(in: start..<end)
            })
        }
    }
    
    // OLD Helper function to create ZIP archive (replaced by ZIPFoundation)
    func createZipArchive_OLD(from directory: URL, to zipURL: URL) throws {
        // Create ZIP file manually (iOS doesn't have zip command)
        let fileManager = FileManager.default
        let zipData = NSMutableData()
        var fileEntries: [(offset: UInt32, fileName: String, fileData: Data, crc32: UInt32, size: UInt32)] = []
        
        // Collect all files first, then sort to ensure [Content_Types].xml comes first
        var allFiles: [(path: String, url: URL)] = []
        
        func collectFiles(from dir: URL, basePath: String = "") throws {
            let contents = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isDirectoryKey], options: [])
            
            for fileURL in contents {
                // Use forward slashes for ZIP file paths (Office format requirement)
                let fileName = fileURL.lastPathComponent
                let relativePath = basePath.isEmpty ? fileName : "\(basePath)/\(fileName)"
                
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                    // Recursively collect directory contents
                    try collectFiles(from: fileURL, basePath: relativePath)
                } else {
                    allFiles.append((path: relativePath, url: fileURL))
                }
            }
        }
        
        try collectFiles(from: directory)
        
        // Sort files: [Content_Types].xml should be first, then _rels/.rels, then others
        allFiles.sort { first, second in
            if first.path == "[Content_Types].xml" { return true }
            if second.path == "[Content_Types].xml" { return false }
            if first.path == "_rels/.rels" { return true }
            if second.path == "_rels/.rels" { return false }
            return first.path < second.path
        }
        
        // Add files to ZIP in sorted order
        for (relativePath, fileURL) in allFiles {
            let fileData = try Data(contentsOf: fileURL)
            let crc32 = calculateCRC32(data: fileData)
            let offset = UInt32(zipData.length)
            let size = UInt32(fileData.count)
            
            try addFileToZip(zipData: zipData, fileData: fileData, fileName: relativePath, crc32: crc32)
            
            fileEntries.append((offset: offset, fileName: relativePath, fileData: fileData, crc32: crc32, size: size))
        }
        
        // Add Central Directory
        let centralDirOffset = UInt32(zipData.length)
        for entry in fileEntries {
            try addCentralDirectoryEntry(zipData: zipData, entry: entry)
        }
        let centralDirSize = UInt32(zipData.length) - centralDirOffset
        
        // Add End of Central Directory Record
        try addEndOfCentralDirectory(zipData: zipData, 
                                    totalEntries: UInt16(fileEntries.count),
                                    centralDirOffset: centralDirOffset,
                                    centralDirSize: centralDirSize)
        
        // Write ZIP data to file
        try zipData.write(to: zipURL)
    }
    
    // Helper to add a file to ZIP data
    func addFileToZip(zipData: NSMutableData, fileData: Data, fileName: String, crc32: UInt32) throws {
        let uncompressedSize = UInt32(fileData.count)
        let compressedSize = UInt32(fileData.count) // Stored uncompressed
        let fileNameData = fileName.data(using: .utf8)!
        let fileNameLength = UInt16(fileNameData.count)
        
        // Local File Header (30 bytes + filename length)
        var header = Data()
        header.append(contentsOf: [0x50, 0x4B, 0x03, 0x04]) // Local file header signature
        header.append(contentsOf: [0x14, 0x00]) // Version needed to extract (20 = 2.0)
        header.append(contentsOf: [0x00, 0x00]) // General purpose bit flag
        header.append(contentsOf: [0x00, 0x00]) // Compression method (0 = stored/uncompressed)
        
        // CRC-32 (4 bytes, little-endian)
        var crc32Bytes = Data()
        withUnsafeBytes(of: crc32.littleEndian) { bytes in
            crc32Bytes.append(contentsOf: bytes)
        }
        header.append(crc32Bytes)
        
        // Compressed size (4 bytes, little-endian)
        var compressedSizeBytes = Data()
        withUnsafeBytes(of: compressedSize.littleEndian) { bytes in
            compressedSizeBytes.append(contentsOf: bytes)
        }
        header.append(compressedSizeBytes)
        
        // Uncompressed size (4 bytes, little-endian)
        var uncompressedSizeBytes = Data()
        withUnsafeBytes(of: uncompressedSize.littleEndian) { bytes in
            uncompressedSizeBytes.append(contentsOf: bytes)
        }
        header.append(uncompressedSizeBytes)
        
        // File name length (2 bytes, little-endian)
        var fileNameLengthBytes = Data()
        withUnsafeBytes(of: fileNameLength.littleEndian) { bytes in
            fileNameLengthBytes.append(contentsOf: bytes)
        }
        header.append(fileNameLengthBytes)
        
        // Extra field length (2 bytes, always 0)
        header.append(contentsOf: [0x00, 0x00])
        
        // File name
        header.append(fileNameData)
        
        zipData.append(header)
        zipData.append(fileData)
    }
    
    // Add Central Directory Entry
    func addCentralDirectoryEntry(zipData: NSMutableData, entry: (offset: UInt32, fileName: String, fileData: Data, crc32: UInt32, size: UInt32)) throws {
        let fileNameData = entry.fileName.data(using: .utf8)!
        let fileNameLength = UInt16(fileNameData.count)
        
        var cdEntry = Data()
        cdEntry.append(contentsOf: [0x50, 0x4B, 0x01, 0x02]) // Central file header signature
        cdEntry.append(contentsOf: [0x14, 0x00]) // Version made by (20 = 2.0)
        cdEntry.append(contentsOf: [0x14, 0x00]) // Version needed to extract (20 = 2.0)
        cdEntry.append(contentsOf: [0x00, 0x00]) // General purpose bit flag
        cdEntry.append(contentsOf: [0x00, 0x00]) // Compression method (0 = stored)
        
        // CRC-32 (4 bytes, little-endian)
        var crc32Bytes = Data()
        withUnsafeBytes(of: entry.crc32.littleEndian) { bytes in
            crc32Bytes.append(contentsOf: bytes)
        }
        cdEntry.append(crc32Bytes)
        
        // Compressed size (4 bytes, little-endian)
        var compressedSizeBytes = Data()
        withUnsafeBytes(of: entry.size.littleEndian) { bytes in
            compressedSizeBytes.append(contentsOf: bytes)
        }
        cdEntry.append(compressedSizeBytes)
        
        // Uncompressed size (4 bytes, little-endian)
        var uncompressedSizeBytes = Data()
        withUnsafeBytes(of: entry.size.littleEndian) { bytes in
            uncompressedSizeBytes.append(contentsOf: bytes)
        }
        cdEntry.append(uncompressedSizeBytes)
        
        // File name length (2 bytes, little-endian)
        var fileNameLengthBytes = Data()
        withUnsafeBytes(of: fileNameLength.littleEndian) { bytes in
            fileNameLengthBytes.append(contentsOf: bytes)
        }
        cdEntry.append(fileNameLengthBytes)
        
        // Extra field length (2 bytes)
        cdEntry.append(contentsOf: [0x00, 0x00])
        
        // File comment length (2 bytes)
        cdEntry.append(contentsOf: [0x00, 0x00])
        
        // Disk number start (2 bytes)
        cdEntry.append(contentsOf: [0x00, 0x00])
        
        // Internal file attributes (2 bytes)
        cdEntry.append(contentsOf: [0x00, 0x00])
        
        // External file attributes (4 bytes, little-endian)
        var externalAttrsBytes = Data()
        withUnsafeBytes(of: UInt32(0).littleEndian) { bytes in
            externalAttrsBytes.append(contentsOf: bytes)
        }
        cdEntry.append(externalAttrsBytes)
        
        // Relative offset of local header (4 bytes, little-endian)
        var offsetBytes = Data()
        withUnsafeBytes(of: entry.offset.littleEndian) { bytes in
            offsetBytes.append(contentsOf: bytes)
        }
        cdEntry.append(offsetBytes)
        
        // File name
        cdEntry.append(fileNameData)
        
        zipData.append(cdEntry)
    }
    
    // Add End of Central Directory Record
    func addEndOfCentralDirectory(zipData: NSMutableData, totalEntries: UInt16, centralDirOffset: UInt32, centralDirSize: UInt32) throws {
        var eocd = Data()
        eocd.append(contentsOf: [0x50, 0x4B, 0x05, 0x06]) // End of central directory signature
        
        // Number of this disk (2 bytes)
        eocd.append(contentsOf: [0x00, 0x00])
        
        // Number of disk with start of central directory (2 bytes)
        eocd.append(contentsOf: [0x00, 0x00])
        
        // Total entries in central dir on this disk (2 bytes, little-endian)
        var totalEntriesBytes = Data()
        withUnsafeBytes(of: totalEntries.littleEndian) { bytes in
            totalEntriesBytes.append(contentsOf: bytes)
        }
        eocd.append(totalEntriesBytes)
        
        // Total entries in central dir (2 bytes, little-endian)
        eocd.append(totalEntriesBytes)
        
        // Size of central directory (4 bytes, little-endian)
        var centralDirSizeBytes = Data()
        withUnsafeBytes(of: centralDirSize.littleEndian) { bytes in
            centralDirSizeBytes.append(contentsOf: bytes)
        }
        eocd.append(centralDirSizeBytes)
        
        // Offset of start of central directory (4 bytes, little-endian)
        var centralDirOffsetBytes = Data()
        withUnsafeBytes(of: centralDirOffset.littleEndian) { bytes in
            centralDirOffsetBytes.append(contentsOf: bytes)
        }
        eocd.append(centralDirOffsetBytes)
        
        // ZIP file comment length (2 bytes)
        eocd.append(contentsOf: [0x00, 0x00])
        
        zipData.append(eocd)
    }
    
    // Calculate CRC32 checksum
    func calculateCRC32(data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFFFFFF
        let table: [UInt32] = (0..<256).map { i in
            var c = UInt32(i)
            for _ in 0..<8 {
                c = (c & 1) != 0 ? (c >> 1) ^ 0xEDB88320 : c >> 1
            }
            return c
        }
        
        for byte in data {
            crc = table[Int((crc ^ UInt32(byte)) & 0xFF)] ^ (crc >> 8)
        }
        return crc ^ 0xFFFFFFFF
    }
}


