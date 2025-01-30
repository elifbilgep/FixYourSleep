//
//  CameraView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 30.01.2025.
//

import AVFoundation
import SwiftUI

enum DetectionState {
    case idle
    case processing
    case success
    case failure
    
    var message: String {
        switch self {
        case .idle: return ""
        case .processing: return "Checking the image..."
        case .success: return "Book detected!"
        case .failure: return "No book detected."
        }
    }
    
    var color: Color {
        switch self {
        case .idle, .processing: return .orange
        case .success: return .green
        case .failure: return .red
        }
    }
}
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var imageDescription: String
    @Binding var detectionState: DetectionState
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                processImage(uiImage)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        private func processImage(_ image: UIImage) {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Görüntü verisi oluşturulamadı.")
                parent.detectionState = .failure
                return
            }
            
            GoogleVisionService.shared.detectLabels(from: imageData) { result in
                DispatchQueue.main.async {
                    
                    switch result {
                    case .success(let labels):
                        print("Algılanan Etiketler: \(labels)")
                        self.parent.imageDescription = labels.joined(separator: ", ")
                        
                        if labels.contains(where: { $0.lowercased() == "book" }) {
                            self.parent.detectionState = .success
                        } else {
                            self.parent.detectionState = .failure
                        }
                        
                    case .failure(let error):
                        print("Hata oluştu: \(error)")
                        self.parent.detectionState = .failure
                    }
                }
            }
        }
    }
}
