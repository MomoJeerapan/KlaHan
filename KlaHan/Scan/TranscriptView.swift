//
//  TranscriptView.swift
//  KlaHan
//
//  Created by COSCI_LAB on 12/5/2568 BE.
//

//ตัวที่จะไปเชื่อมหน้า contact คืนเงินแต่ละคน

import SwiftUI
import Vision

struct TranscriptView: View {
    @Binding var imageOCR: OCR
    @State private var transcriptText: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if imageOCR.observations.isEmpty {
                    Text("No text found")
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    Text("Text extracted from the image:")
                        .font(.title2)
                        .padding(.top)

                    TextEditor(text: $transcriptText)
                        .frame(minHeight: 300)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4)))

                    Button(action: {
                        UIPasteboard.general.string = transcriptText
                    }) {
                        Label("คัดลอกทั้งหมด", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .navigationTitle("Transcript")
            .onAppear {
                // Combine OCR text into a single editable string
                if transcriptText.isEmpty {
                    transcriptText = imageOCR.observations
                        .map { $0.topCandidates(1).first?.string ?? "" }
                        .joined(separator: "\n")
                }
            }
        }
    }
}

