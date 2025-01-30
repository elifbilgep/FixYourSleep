//
//  RelaxView.swift
//  FixYourSleep
//
//  Created by Elif Parlak on 30.01.2025.
//

import SwiftUI

struct RelaxView: View {
    @State private var isCameraPresented = false
    @State private var capturedImage: UIImage?
    @State private var imageDescription: String = ""
    @State private var detectionState: DetectionState = .idle

    var body: some View {
        VStack(spacing: 32) {
            headerSection
            capturedImageSection
            captureButton
            cancelButton
        }
        .padding(.horizontal, 24)
        .background(Color(UIColor.systemBackground).ignoresSafeArea())
        .navigationTitle("Relax Mode")
    }
    
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Relax and Unwind")
                .font(.largeTitle.weight(.semibold))
                .multilineTextAlignment(.center)

            Text("Take time to relax and read a book. Please capture a photo of your book.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }

      //MARK: Captured Image Section
    private var capturedImageSection: some View {
        VStack(spacing: 20) {
            if let capturedImage = capturedImage {
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(16)
                    .shadow(radius: 5)

                Text("Image Description: \(imageDescription)")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)

                if detectionState == .processing {
                    ProgressView("Processing Image...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.top, 8)
                }

                Text(detectionState.message)
                    .foregroundColor(detectionState.color)
                    .font(.subheadline.weight(.medium))
                    .padding(.top, 4)
            } else {
                Text("No image captured yet.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }

    private var captureButton: some View {
        CustomButton(title: "Capture Photo") {
            isCameraPresented = true
            detectionState = .processing
        }
        .sheet(isPresented: $isCameraPresented) {
            CameraPicker(
                image: $capturedImage,
                imageDescription: $imageDescription,
                detectionState: $detectionState
            )
        }
        .padding(.top, 20)
    }

    // Cancel Butonu
    private var cancelButton: some View {
        Text("Cancel Sleep")
            .foregroundColor(.red)
            .font(.headline)
            .padding(.top, 16)
            .onTapGesture {
                cancelTheSleep()
            }
    }

    private func cancelTheSleep() {
        // Handle sleep cancellation logic
    }
}

