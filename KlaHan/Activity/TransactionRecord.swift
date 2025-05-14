////
////  TransactionRecord.swift
////  KlaHan
////
////  Created by Jeerapan Chirachanchai on 14/5/2568 BE.
////
//
//
//import SwiftUI
//import Charts
//import FirebaseFirestore
//import FirebaseAuth
//
//struct TransactionRecord: Identifiable, Hashable {
//    var id = UUID()
//    var date: Date
//    var description: String
//    var amount: Double
//    var isIncome: Bool
//}
//
//enum TabItem {
//    case community, trend, customize, profile
//}
//
//struct TrendView: View {
//    @State private var transactions: [TransactionRecord] = []
//    @State private var currentTab: TabItem = .trend
//
//    var body: some View {
//        NavigationStack {
//            ZStack(alignment: .bottom) {
//                VStack(spacing: 20) {
//                    Text("แนวโน้มยอดเงิน")
//                        .font(.title2)
//                        .bold()
//                        .padding(.top)
//
//                    if transactions.isEmpty {
//                        ProgressView("กำลังโหลด...")
//                            .padding()
//                    } else {
//                        Chart(transactions) { item in
//                            LineMark(
//                                x: .value("วันที่", item.date),
//                                y: .value("จำนวนเงิน", item.amount)
//                            )
//                            .interpolationMethod(.catmullRom)
//                            .foregroundStyle(item.isIncome ? .green : .red)
//                            .symbol(Circle())
//                        }
//                        .frame(height: 250)
//                        .padding()
//                    }
//
//                    Divider().padding(.vertical)
//
//                    Text("ประวัติการชำระ / รับเงิน")
//                        .font(.headline)
//                        .padding(.horizontal)
//
//                    List(transactions.sorted(by: { $0.date > $1.date })) { record in
//                        HStack {
//                            VStack(alignment: .leading) {
//                                Text(record.description)
//                                    .font(.subheadline)
//                                Text(formattedDate(record.date))
//                                    .font(.caption)
//                                    .foregroundColor(.gray)
//                            }
//                            Spacer()
//                            Text("฿\(record.amount, specifier: "%.2f")")
//                                .foregroundColor(record.isIncome ? .green : .red)
//                        }
//                        .padding(.vertical, 4)
//                    }
//                    .listStyle(.plain)
//                }
//                .onAppear(perform: fetchHistory)
//                .padding(.horizontal)
//                .padding(.bottom, 80) // ปรับ padding เพื่อไม่ทับกับ Tab Bar
//
//                // ✅ Tab Bar
//                HStack(spacing: 0) {
//                    tabBarButton(tab: .community, icon: "house.fill") { CommunityView() }
//                    tabBarButton(tab: .trend, icon: "chart.line.uptrend.xyaxis") { TrendView() }
//
//                    NavigationLink(destination: ScanView()) {
//                        ZStack {
//                            Circle()
//                                .fill(Color(red: 1.0, green: 0.701, blue: 0.0))
//                                .frame(width: 60, height: 60)
//                                .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 3)
//                            Image(systemName: "qrcode.viewfinder")
//                                .resizable()
//                                .frame(width: 30, height: 30)
//                                .foregroundColor(.white)
//                        }
//                        .frame(maxWidth: .infinity)
//                    }
//
//                    tabBarButton(tab: .customize, icon: "slider.horizontal.3") { CustomizeView() }
//                    tabBarButton(tab: .profile, icon: "person.crop.circle") { ProfileView() }
//                }
//                .frame(height: 70)
//                .background(Color.white)
//                .shadow(color: Color.black.opacity(0.1), radius: 5, y: -2)
//                .ignoresSafeArea(edges: .bottom)
//            }
//        }
//    }
//
//    // MARK: - Tab Button
//    @ViewBuilder
//    func tabBarButton<Destination: View>(tab: TabItem, icon: String, destination: @escaping () -> Destination) -> some View {
//        Group {
//            if currentTab == tab {
//                Image(systemName: icon)
//                    .resizable()
//                    .frame(width: 25, height: 25)
//                    .foregroundColor(Color(red: 1.0, green: 0.701, blue: 0.0))
//            } else {
//                NavigationLink(destination: destination().onAppear {
//                    currentTab = tab
//                }) {
//                    Image(systemName: icon)
//                        .resizable()
//                        .frame(width: 25, height: 25)
//                        .foregroundColor(.gray)
//                }
//            }
//        }
//        .frame(maxWidth: .infinity)
//    }
//
//    func fetchHistory() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        let db = Firestore.firestore()
//        db.collection("Users").document(uid).collection("TransactionHistory")
//            .order(by: "date", descending: true)
//            .getDocuments { snapshot, error in
//                guard let docs = snapshot?.documents else { return }
//                self.transactions = docs.compactMap { doc in
//                    let data = doc.data()
//                    guard let timestamp = data["date"] as? Timestamp,
//                          let amount = data["amount"] as? Double,
//                          let description = data["description"] as? String,
//                          let isIncome = data["isIncome"] as? Bool else { return nil }
//
//                    return TransactionRecord(
//                        date: timestamp.dateValue(),
//                        description: description,
//                        amount: amount,
//                        isIncome: isIncome
//                    )
//                }
//            }
//    }
//
//    func formattedDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
//        return formatter.string(from: date)
//    }
//}
//
//// MARK: - Dummy Views
//struct CommunityView: View { var body: some View { Text("Community View") } }
//struct CustomizeView: View { var body: some View { Text("Customize View") } }
//struct ProfileView: View { var body: some View { Text("Profile View") } }
//struct ScanView: View { var body: some View { Text("Scan View") } }
//
//#Preview {
//    TrendView()
//}
