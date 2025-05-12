//
//  ExchangeView.swift
//  KlaHan
//
//  Created by COSCI_LAB on 12/5/2568 BE.
//

import SwiftUI

struct ExchangeView: View {
    @State private var amount: String = ""
    @State private var selectedCurrency: String = "USD"
    @State private var convertedAmount: String = ""
    @State private var conversionDirection: String = "ต่างประเทศ → THB"
    
    let currencies = ["USD", "EUR", "JPY", "GBP", "AUD"]
    let directions = ["ต่างประเทศ → THB", "THB → ต่างประเทศ"]
    
    let conversionRates: [String: Double] = [
        "USD": 34.5,
        "EUR": 37.5,
        "JPY": 0.25,
        "GBP": 43.0,
        "AUD": 23.5
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("แปลงค่าเงิน")
                .font(.title2)
                .bold()
            
            // Direction Picker
            Picker("ทิศทางการแปลง", selection: $conversionDirection) {
                ForEach(directions, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Input Amount
            TextField("ใส่จำนวนเงิน", text: $amount)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Currency Picker
            Picker("เลือกสกุลเงิน", selection: $selectedCurrency) {
                ForEach(currencies, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal)
            
            // Convert Button
            Button("แปลงเงิน") {
                convertCurrency()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Result
            if !convertedAmount.isEmpty {
                Text("ผลลัพธ์: \(convertedAmount)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.teal)
            }

            Spacer()
        }
        .padding(.top)
        .navigationTitle("แปลงค่าเงิน")
    }
    
    func convertCurrency() {
        guard let input = Double(amount),
              let rate = conversionRates[selectedCurrency] else {
            convertedAmount = "กรุณากรอกจำนวนเงินที่ถูกต้อง"
            return
        }
        
        if conversionDirection == "ต่างประเทศ → THB" {
            let result = input * rate
            convertedAmount = "฿\(String(format: "%.2f", result))บาท"
        } else {
            let result = input / rate
            convertedAmount = "\(String(format: "%.2f", result)) \(selectedCurrency)"
        }
    }
}

#Preview {
    NavigationView {
        ExchangeView()
    }
}
