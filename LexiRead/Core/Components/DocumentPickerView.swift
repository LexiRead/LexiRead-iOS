//
//  DocumentPickerView.swift
//  LexiRead
//
//  Created by Abd Elrahman Atallah on 03/03/2025.
//


import SwiftUI
import UIKit
import UniformTypeIdentifiers
import MobileCoreServices


// MARK: - Document Picker View
struct DocumentPickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let onPick: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Define document types to pick (PDF files)
        let supportedTypes: [UTType]
        if #available(iOS 14, *) {
            supportedTypes = [UTType.pdf]
        } else {
            // For iOS 13 and earlier we use the older API
            let picker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
            picker.allowsMultipleSelection = false
            picker.delegate = context.coordinator
            return picker
        }
        
        // Create the document picker with the new API (iOS 14+)
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator class to handle the delegate methods
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView
        
        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }
        
        // Called when the user selects a document
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Start accessing the security-scoped resource
            let securityGranted = url.startAccessingSecurityScopedResource()
            defer {
                if securityGranted {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            // Call the completion handler with the selected URL
            parent.onPick(url)
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        // Called when the user cancels the document picker
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

