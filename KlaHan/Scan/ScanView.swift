//
//  ScanView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 28/4/2568 BE.
//

import SwiftUI

struct ScanView: View {
    var body: some View {
        VStack {
            Text("Scan Receipt")
                .font(.title)
                .bold()
                .padding()
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 300, height: 400)
                .overlay(Text("กล้องจะอยู่ตรงนี้"))
                .padding()
            
            Button(action: {
                // ใส่โค้ดเปิดกล้อง (ยังไม่ได้ทำ OCR จริง)
            }) {
                Text("เปิดกล้องเพื่อแสกน")
                    .padding()
                    .background(Color(red: 0/255, green: 105/255, blue: 92/255))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Scan")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ScanView()
}

