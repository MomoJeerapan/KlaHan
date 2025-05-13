//
//  TrendView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI
import Charts
import FirebaseFirestore
import FirebaseAuth

struct TransactionRecord: Identifiable {
    var id = UUID()
    var date: Date
    var description: String
    var amount: Double
    var isIncome: Bool
}

struct TrendView: View {
    @State private var transactions: [TransactionRecord] = []

    var body: some View {
        VStack {
            Text("แนวโน้มยอดเงิน")
                .font(.title2)
                .bold()
                .padding(.top)

            if transactions.isEmpty {
                ProgressView("กำลังโหลด...")
                    .padding()
            } else {
                Chart(transactions) { item in
                    LineMark(
                        x: .value("วันที่", item.date),
                        y: .value("จำนวนเงิน", item.amount)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(item.isIncome ? .green : .red)
                    .symbol(Circle())
                }
                .frame(height: 250)
                .padding()
            }

            Divider().padding(.vertical)

            Text("ประวัติการชำระ / รับเงิน")
                .font(.headline)
                .padding(.horizontal)

            List(transactions.sorted(by: { $0.date > $1.date })) { record in
                HStack {
                    VStack(alignment: .leading) {
                        Text(record.description)
                            .font(.subheadline)
                        Text(formattedDate(record.date))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("฿\(record.amount, specifier: "%.2f")")
                        .foregroundColor(record.isIncome ? .green : .red)
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
        }
        .onAppear(perform: fetchHistory)
        .padding(.horizontal)
    }

    func fetchHistory() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()
        db.collection("Users").document(uid).collection("TransactionHistory")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.transactions = docs.compactMap { doc in
                    let data = doc.data()
                    guard let timestamp = data["date"] as? Timestamp,
                          let amount = data["amount"] as? Double,
                          let description = data["description"] as? String,
                          let isIncome = data["isIncome"] as? Bool else { return nil }

                    return TransactionRecord(
                        date: timestamp.dateValue(),
                        description: description,
                        amount: amount,
                        isIncome: isIncome
                    )
                }
            }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
