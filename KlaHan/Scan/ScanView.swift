//
//  ScanView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 28/4/2568 BE.
//

import AVFoundation
import SwiftUI

struct ScanView: View {
    @State private var showCamera: Bool = false
    @State private var hasPhoto: Bool = false
    @State private var imageData: Data? = nil
    @State private var showAccessError: Bool = false

    var body: some View {
        if showAccessError {
            VStack {
                Image(systemName: "lock.trianglebadge.exclamationmark.fill")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.gray)

                Text("This app needs access to the camera for it to function properly. You can update this at:")
                Text("Settings > Privacy and Security > Camera")
            }
        } else {
            VStack {
                if hasPhoto {
                    ImageView(showCamera: $showCamera, imageData: $imageData)
                } else {
                    Spacer()

                    Image(systemName: "text.aligncenter")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .opacity(0.50)
                        .frame(width: 150, height: 150)

                    Spacer()

                    Button("Scan") {
                        showCamera = true
                    }
                    .padding()
                    .font(.title2)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())

                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraUI(showCamera: $showCamera, showAccessError: $showAccessError, hasPhoto: $hasPhoto, imageData: $imageData)
            }
        }
    }
}


