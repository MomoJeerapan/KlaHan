//
//  PromptpayView.swift
//  KlaHan
//
//  Created by COSCI_LAB on 12/5/2568 BE.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseAuth

struct PromptpayView: View {
    var payerName: String
    var receiverName: String
    var payerImage: Image
    var receiverImage: Image
    var context: PromptpayContext
    
    @State private var amount: String = ""
    @State private var currentStep: Step = .inputAmount
    @State private var qrImage: UIImage?
    @State private var slipImage: UIImage?
    @State private var isFullScreenImagePresented: Bool = false
    @State private var selectedImage: UIImage?
    @State private var showConfirmationAlert = false
    
    enum Step {
        case inputAmount, uploadQR, uploadSlip, previewAndConfirm
    }
    
    enum PromptpayContext {
        case group(groupId: String, receiverUID: String)
        case friend(friendUID: String)
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            switch currentStep {
            case .inputAmount: inputAmountView
            case .uploadQR: uploadQRView
            case .uploadSlip: uploadSlipView
            case .previewAndConfirm: previewAndConfirmView
            }
        }
        .navigationTitle("การคืนเงิน")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(fullScreenImageView)
        .alert(isPresented: $showConfirmationAlert) {
            Alert(
                title: Text("สำเร็จ"),
                message: Text("ชำระหนี้เรียบร้อยแล้ว"),
                dismissButton: .default(Text("ตกลง")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private var inputAmountView: some View {
        VStack(spacing: 20) {
            personRow
            TextField("จำนวนเงิน", text: $amount)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            Button("ชำระเงิน") {
                currentStep = .uploadQR
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.teal)
            .foregroundColor(.white)
            .cornerRadius(10)
            Spacer()
        }
    }
    
    private var uploadQRView: some View {
        VStack(spacing: 20) {
            Text("แนบรูป QR Code").font(.headline)
            imageUploadBox(image: qrImage, label: "ยังไม่ได้เลือกรูป")
            pickerButton(for: .qr)
            nextStepButton(condition: qrImage != nil) {
                currentStep = .uploadSlip
            }
            Spacer()
        }.padding()
    }
    
    private var uploadSlipView: some View {
        VStack(spacing: 20) {
            Text("แนบสลิปการโอน").font(.headline)
            imageUploadBox(image: slipImage, label: "ยังไม่ได้เลือกรูป")
            pickerButton(for: .slip)
            nextStepButton(condition: slipImage != nil) {
                currentStep = .previewAndConfirm
            }
            Spacer()
        }.padding()
    }
    
    private var previewAndConfirmView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("ตรวจสอบข้อมูล").font(.headline)
                personRow
                Text("จำนวนเงิน: \(amount) บาท").font(.title3).padding(.top)
                if let qrImage = qrImage {
                    Text("QR Code:")
                    imageThumbnail(image: qrImage)
                }
                if let slipImage = slipImage {
                    Text("สลิปการโอน:")
                    imageThumbnail(image: slipImage)
                }
                Button("ยืนยัน") {
                    settleDebt()
                }
                .frame(maxWidth: .infinity)
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
                    Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)
                    VStack {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(10)
                            .shadow(radius: 10)
                        Button("ปิด") {
                            isFullScreenImagePresented = false
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
    }
    
    private var personRow: some View {
        HStack(spacing: 40) {
            VStack {
                payerImage.resizable().frame(width: 80, height: 80).clipShape(Circle())
                Text(payerName)
            }
            Image(systemName: "arrow.right").font(.largeTitle)
            VStack {
                receiverImage.resizable().frame(width: 80, height: 80).clipShape(Circle())
                Text(receiverName)
            }
        }
    }
    
    private func imageUploadBox(image: UIImage?, label: String) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 300)
                .overlay(Text(image == nil ? label : ""))
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .onTapGesture {
                        selectedImage = image
                        isFullScreenImagePresented = true
                    }
            }
        }
        .animation(.easeInOut, value: image)
    }
    
    private enum PickerType { case qr, slip }
    
    private func pickerButton(for type: PickerType) -> some View {
        PhotosPicker(selection: Binding(
            get: { nil },
            set: { newItem in
                if let newItem {
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            if type == .qr { qrImage = image }
                            else { slipImage = image }
                        }
                    }
                }
            }
        ), matching: .images) {
            Text(type == .qr ? "เลือกรูป QR Code" : "เลือกรูปสลิป")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    private func nextStepButton(condition: Bool, action: @escaping () -> Void) -> some View {
        Button("ถัดไป") {
            action()
        }
        .disabled(!condition)
        .padding()
        .background(condition ? Color.teal : Color.gray)
        .foregroundColor(.white)
        .cornerRadius(10)
    }
    
    private func imageThumbnail(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(height: 300)
            .onTapGesture {
                selectedImage = image
                isFullScreenImagePresented = true
            }
    }
    
    // ✅ ปรับ settleDebt() สำหรับ FRIEND ให้ทำงานเฉพาะฝั่ง consumer
    private func settleDebt() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            presentationMode.wrappedValue.dismiss()
            return
        }
        
        let db = Firestore.firestore()
        let currentUserID = Auth.auth().currentUser?.uid ?? ""
        
        switch context {
        case .group(let groupId, let receiverUID):
            let docId = "\(currentUserID)_to_\(receiverUID)"
            let balancesRef = db.collection("Groups").document(groupId).collection("Balances").document(docId)
            
            balancesRef.getDocument { snapshot, _ in
                let currentDebt = snapshot?.data()? ["amount"] as? Double ?? 0.0
                let newDebt = max(0, currentDebt - amountValue)
                
                if newDebt == 0 {
                    balancesRef.setData([
                        "amount": 0,
                        "isPaid": true,
                        "consumer": ["uid": currentUserID, "name": payerName],
                        "payer": ["uid": receiverUID, "name": receiverName]
                    ]) { _ in showConfirmationAlert = true }
                } else {
                    balancesRef.updateData(["amount": newDebt]) { _ in showConfirmationAlert = true }
                }
            }
            
            db.collection("Users").document(currentUserID).collection("TransactionHistory")
                .addDocument(data: [
                    "date": Timestamp(date: Date()),
                    "amount": amountValue,
                    "description": "คืนเงินให้ \(receiverName)",
                    "isIncome": false,
                    "relatedUID": receiverUID
                ])
            
            db.collection("Users").document(receiverUID).collection("TransactionHistory")
                .addDocument(data: [
                    "date": Timestamp(date: Date()),
                    "amount": amountValue,
                    "description": "ได้รับเงินจาก \(payerName)",
                    "isIncome": true,
                    "relatedUID": currentUserID
                ])
            
        case .friend(let friendUID):
            let docId = "\(currentUserID)_to_\(friendUID)"
            let ref = db.collection("Users").document(currentUserID).collection("FriendBalances").document(docId)
            
            ref.getDocument { snap, _ in
                let currentDebt = snap?.data()? ["amount"] as? Double ?? 0.0
                let newDebt = max(0, currentDebt - amountValue)
                
                if newDebt == 0 {
                    ref.updateData([
                        "amount": 0,
                        "isPaid": true
                    ]) { _ in
                        showConfirmationAlert = true
                    }
                } else {
                    ref.updateData(["amount": newDebt]) { _ in
                        showConfirmationAlert = true
                    }
                }
            }
            
            // ✅ เพิ่ม log แค่ฝั่งเราเท่านั้น (consumer)
            let record: [String: Any] = [
                "date": Timestamp(date: Date()),
                "amount": amountValue,
                "description": "คืนเงินให้ \(receiverName)",
                "isIncome": false,
                "relatedUID": friendUID
            ]
            db.collection("Users").document(currentUserID)
                .collection("TransactionHistory").addDocument(data: record)
            
            // ❌ ไม่เขียน log ฝั่ง friendUID เพราะ rules ไม่อนุญาต และไม่จำเป็น
        }
    }
    
    private func alertInvalidTransaction() {
        // กรณีห้ามคืนเงินให้ตัวเอง
        showConfirmationAlert = true
    }
}
