import SwiftUI
import QuickLook

struct QLPreviewRepresented: UIViewControllerRepresentable {
    let fileURL: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        // Store the fileURL in coordinator
        context.coordinator.fileURL = fileURL
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        // In case the file changed, update the coordinator.
        context.coordinator.fileURL = fileURL
        uiViewController.reloadData()
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        var fileURL: URL?

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return fileURL == nil ? 0 : 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return fileURL! as QLPreviewItem
        }
    }
}
