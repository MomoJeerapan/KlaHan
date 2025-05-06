//
//  TrendView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI
import Charts

struct TrendData: Identifiable {
    var id = UUID()
    var date: Date
    var amount: Double
}

struct TrendView: View {
    // ตัวอย่างข้อมูลยอดหนี้ในแต่ละวัน
    let trendData: [TrendData] = [
        TrendData(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, amount: 10000),
        TrendData(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, amount: 15000),
        TrendData(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, amount: 12000),
        TrendData(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, amount: 18000),
        TrendData(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, amount: 22000),
        TrendData(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, amount: 21000),
        TrendData(date: Date(), amount: 25000)
    ]

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "chart.bar")
                Spacer()
                Text("Trend")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "magnifyingglass")
            }
            .padding()

            Text("Debt Trend Over Time")
                .font(.headline)
                .padding(.top)

            Chart(trendData) { data in
                LineMark(
                    x: .value("Date", data.date),
                    y: .value("Debt", data.amount)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.teal)
                .symbol(Circle())
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .frame(height: 250)
            .padding()

            Spacer()

            // Bottom Tab Bar (แบบเดียวกับ CommunityView)
            HStack {
                Image(systemName: "person")
                Spacer()
                Image(systemName: "chart.bar")
                Spacer()
                Image(systemName: "qrcode.viewfinder")
                Spacer()
                Image(systemName: "dollarsign.circle")
                Spacer()
                Image(systemName: "photo")
            }
            .padding()
        }
    }
}

