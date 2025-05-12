//
//  PromptpayView.swift
//  KlaHan
//
//  Created by COSCI_LAB on 12/5/2568 BE.
//

import SwiftUI
import PhotosUI

struct PromptpayView: View {
    var payerName: String
    var receiverName: String
    var payerImage: Image
    var receiverImage: Image
    
    @State private var amount: String = ""
    @State private var currentStep: Step = .inputAmount
    @State private var qrImage: UIImage?
    @State private var slipImage: UIImage?
    @State private var isFullScreenImagePresented: Bool = false
    @State private var selectedImage: UIImage?
    
    enum Step {
        case inputAmount
        case uploadQR
        case uploadSlip
        case previewAndConfirm
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            switch currentStep {
            case .inputAmount:
                inputAmountView
            case .uploadQR:
                uploadQRView
            case .uploadSlip:
                uploadSlipView
            case .previewAndConfirm:
                previewAndConfirmView
            }
        }
        .navigationTitle("การคืนเงิน")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            fullScreenImageView
        )
    }
    
    private var inputAmountView: some View {
        VStack(spacing: 20) {
            HStack(spacing: 40) {
                VStack {
                    payerImage
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    Text(payerName)
                }
                
                Image(systemName: "arrow.right")
                    .font(.largeTitle)
                
                VStack {
                    receiverImage
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    Text(receiverName)
                }
            }
            
            TextField("จำนวนเงิน", text: $amount)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            Button(action: {
                currentStep = .uploadQR
            }) {
                Text("ชำระเงิน")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.teal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
    }
    
    private var uploadQRView: some View {
        VStack(spacing: 20) {
            Text("แนบรูป QR Code")
                .font(.headline)
            
            ZStack {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 300)
                    .overlay(Text(qrImage == nil ? "ยังไม่ได้เลือกรูป" : ""))
                
                if let qrImage = qrImage {
                    Image(uiImage: qrImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .onTapGesture {
                            selectedImage = qrImage
                            isFullScreenImagePresented = true
                        }
                }
            }
            .animation(.easeInOut, value: qrImage)
            
            PhotosPicker(selection: Binding(
                get: { nil },
                set: { newItem in
                    if let newItem {
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                qrImage = image
                            }
                        }
                    }
                }
            ), matching: .images) {
                Text("เลือกรูป QR Code")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button("ถัดไป") {
                currentStep = .uploadSlip
            }
            .disabled(qrImage == nil)
            .padding()
            .background(qrImage == nil ? Color.gray : Color.teal)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
    
    private var uploadSlipView: some View {
        VStack(spacing: 20) {
            Text("แนบสลิปการโอน")
                .font(.headline)
            
            ZStack {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 300)
                    .overlay(Text(slipImage == nil ? "ยังไม่ได้เลือกรูป" : ""))
                
                if let slipImage = slipImage {
                    Image(uiImage: slipImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .onTapGesture {
                            selectedImage = slipImage
                            isFullScreenImagePresented = true
                        }
                }
            }
            .animation(.easeInOut, value: slipImage)
            
            PhotosPicker(selection: Binding(
                get: { nil },
                set: { newItem in
                    if let newItem {
                        Task {
                            if let data = try? await newItem.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                slipImage = image
                            }
                        }
                    }
                }
            ), matching: .images) {
                Text("เลือกรูปสลิป")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Button("ยืนยัน") {
                currentStep = .previewAndConfirm
                }
                            .disabled(slipImage == nil)
                            .padding()
                            .background(slipImage == nil ? Color.gray : Color.teal)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            
                            Spacer()
                        }
                        .padding()
    }
    
    private var previewAndConfirmView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("ตรวจสอบข้อมูล")
                    .font(.headline)
                
                HStack(spacing: 40) {
                    VStack {
                        payerImage
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        Text(payerName)
                    }
                    
                    Image(systemName: "arrow.right")
                        .font(.largeTitle)
                    
                    VStack {
                        receiverImage
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        Text(receiverName)
                    }
                }
                
                Text("จำนวนเงิน: \(amount) บาท")
                    .font(.title3)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("QR Code ที่เลือก:")
                        .font(.subheadline)
                    if let qrImage = qrImage {
                        Image(uiImage: qrImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .onTapGesture {
                                selectedImage = qrImage
                                isFullScreenImagePresented = true
                            }
                    }
                    
                    Text("สลิปการโอนที่เลือก:")
                        .font(.subheadline)
                    if let slipImage = slipImage {
                        Image(uiImage: slipImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .onTapGesture {
                                selectedImage = slipImage
                                isFullScreenImagePresented = true
                            }
                    }
                }
                
                Button("ยืนยัน") {
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)  // ทำให้ปุ่มขยายเต็ม
                .padding()
                .background(Color.teal)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }
    
    private var fullScreenImageView: some View {
        Group {
            if isFullScreenImagePresented, let selectedImage = selectedImage {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                        
                        Button(action: {
                            isFullScreenImagePresented = false
                        }) {
                            Text("ปิด")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
        }
    }
}

