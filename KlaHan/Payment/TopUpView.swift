//
//  TopUpView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 28/4/2568 BE.
//

import SwiftUI

struct TopUpView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Top Up")
                .font(.largeTitle)
                .bold()
                .padding()
            
            ForEach([100, 200, 500, 1000], id: \.self) { amount in
                Button(action: {
                    // ใส่โค้ดทำ top-up
                }) {
                    HStack {
                        Image(systemName: "creditcard.fill")
                        Text("\(amount) ฿")
                    }
                    .frame(width: 200, height: 50)
                    .background(Color.yellow)
                    .cornerRadius(10)
                    .foregroundColor(.black)
                }
            }
        }
        .navigationTitle("Top Up")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    TopUpView()
}
