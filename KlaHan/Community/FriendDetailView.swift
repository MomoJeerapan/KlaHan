//
//  FriendDetailView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct FriendDetailView: View {
    let friendID: String
    
    @State private var friendName: String = "ไม่มีประวัติการยืมเงิน"
    @State private var transactions: [TransactionRecord] = []
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.teal)
            
            Text(friendName)
                .font(.title.bold())
                .foregroundColor(.gray)
            
            TabView {
                ForEach(transactions) { item in
                    VStack {
                        Text("วันที่ \(formattedDate(item.date))")
                            .font(.headline)
                        Text(item.description)
                            .font(.title2)
                        Text("฿\(item.amount, specifier: "%.2f")")
                            .font(.title)
                            .bold()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.teal.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 160)
            
            Spacer()
            
            HStack(spacing: 12) {
                NavigationLink(destination:
                                PromptpayView(
                                    payerName: "ฉัน",
                                    receiverName: friendName,
                                    payerImage: Image(systemName: "person.circle.fill"),
                                    receiverImage: Image(systemName: "person.circle.fill"),
                                    context: .friend(friendUID: friendID)
                                )
                ) {
                    Text("คืนเงิน")
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.teal.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: ExchangeView()) {
                    Text("แปลงเงิน")
                        .font(.subheadline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.teal.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.bottom)
        }
        .padding(.top)
        .navigationTitle(friendName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchFriendInfo()
            fetchMyTransactionsWithFriend()
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func fetchFriendInfo() {
        let db = Firestore.firestore()
        db.collection("Users").document(friendID).getDocument { snap, error in
            if let data = snap?.data(), let name = data["Username"] as? String {
                self.friendName = name
            }
        }
    }
    
    func fetchMyTransactionsWithFriend() {
        guard let myUID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("Users").document(myUID)
            .collection("TransactionHistory")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                
                self.transactions = docs.compactMap { doc in
                    let data = doc.data()
                    
                    guard
                        let amount = data["amount"] as? Double,
                        let description = data["description"] as? String,
                        let timestamp = data["date"] as? Timestamp,
                        let relatedUID = data["relatedUID"] as? String,
                        relatedUID == friendID
                    else {
                        return nil
                    }
                    
                    let isIncome = data["isIncome"] as? Bool ?? false
                    
                    return TransactionRecord(
                        date: timestamp.dateValue(),
                        description: description,
                        amount: amount,
                        isIncome: isIncome
                    )
                }
            }
    }

}

