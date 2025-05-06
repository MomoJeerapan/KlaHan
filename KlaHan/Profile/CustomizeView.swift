//
//  CustomizeView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 28/4/2568 BE.
//

import SwiftUI

struct CustomizeView: View {
    var body: some View {
        ScrollView {
            Text("เลือกเสื้อผ้าให้ตัวการ์ตูน")
                .font(.title2)
                .bold()
                .padding()
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                ForEach(0..<6) { index in
                    VStack {
                        Rectangle()
                            .fill(Color.blue.opacity(0.5))
                            .frame(width: 80, height: 80)
                            .overlay(Text("ชุด \(index + 1)").foregroundColor(.white))
                        
                        Text("ราคา 100฿")
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Customize")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    CustomizeView()
}

