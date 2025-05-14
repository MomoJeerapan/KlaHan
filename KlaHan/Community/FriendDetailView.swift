import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FriendDetailView: View {
    let friendID: String
    
    @State private var friendName: String = "ไม่มีประวัติการยืมเงิน"
    @State private var unpaidBalances: [SummaryEntry] = []
    @State private var paidBalances: [SummaryEntry] = []
    @State private var currentUserName: String = "ฉัน"
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable().frame(width: 100, height: 100).foregroundColor(.teal)
            
            Text(friendName).font(.title.bold()).foregroundColor(.gray)
            
            Text("สรุปยอดคืนเงิน (ยังไม่จ่าย)").font(.headline).padding(.top)
            balanceSection(entries: unpaidBalances, symbol: "❌", color: .red)
            
            Text("ประวัติการชำระ (จ่ายแล้ว)").font(.headline).padding(.top)
            balanceSection(entries: paidBalances, symbol: "✅", color: .green)
            
            Spacer()
            
            HStack(spacing: 12) {
                NavigationLink(destination:
                                PromptpayView(
                                    payerName: currentUserName,
                                    receiverName: friendName,
                                    payerImage: Image(systemName: "person.circle.fill"),
                                    receiverImage: Image(systemName: "person.circle.fill"),
                                    context: .friend(friendUID: friendID)
                                )
                ) {
                    Text("คืนเงิน")
                        .padding().background(Color.teal)
                        .foregroundColor(.white).cornerRadius(10)
                }
                
                NavigationLink(destination: ExchangeView()) {
                    Text("แปลงเงิน")
                        .padding().background(Color.teal)
                        .foregroundColor(.white).cornerRadius(10)
                }
            }.padding(.bottom)
        }
        .padding(.top)
        .navigationTitle(friendName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchFriendInfo()
            fetchCurrentUserName()
            fetchFriendBalances()
        }
    }
    
    private func balanceSection(entries: [SummaryEntry], symbol: String, color: Color) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(entries, id: \ .self) { entry in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(entry.consumer.name) → \(entry.payer.name)").font(.subheadline)
                            Text("฿\(abs(entry.amount), specifier: "%.2f")")
                                .font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(symbol).foregroundColor(color)
                    }
                    Divider()
                }
            }.padding(.horizontal)
        }
    }
    
    private func fetchFriendInfo() {
        Firestore.firestore().collection("Users").document(friendID).getDocument { snap, _ in
            if let name = snap?.data()? ["Username"] as? String {
                self.friendName = name
            }
        }
    }
    
    private func fetchCurrentUserName() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("Users").document(uid).getDocument { snap, _ in
            if let name = snap?.data()? ["Username"] as? String {
                self.currentUserName = name
            }
        }
    }
    
    private func fetchFriendBalances() {
        guard let myUID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        let docID = "\(myUID)_to_\(friendID)"
        db.collection("Users").document(myUID)
            .collection("FriendBalances")
            .document(docID)
            .getDocument { snap, _ in
                guard let data = snap?.data(),
                      let consumer = data["consumer"] as? [String: String],
                      let payer = data["payer"] as? [String: String],
                      let amount = data["amount"] as? Double,
                      let isPaid = data["isPaid"] as? Bool,
                      consumer["uid"] == myUID,    // ✅ ต้องเป็น consumer
                      payer["uid"] == friendID else { return }
                
                let consumerUID = consumer["uid"] ?? ""
                let payerUID = payer["uid"] ?? ""
                let consumerName = consumer["name"] ?? consumerUID
                let payerName = payer["name"] ?? payerUID
                
                guard consumerUID == myUID, payerUID == friendID else { return }
                
                let entry = SummaryEntry(
                    consumer: UserIdentity(uid: consumerUID, name: consumerName),
                    payer: UserIdentity(uid: payerUID, name: payerName),
                    amount: amount,
                    isPaid: isPaid
                )
                
                if isPaid {
                    self.paidBalances = [entry]
                } else {
                    self.unpaidBalances = [entry]
                }
            }
    }
}

