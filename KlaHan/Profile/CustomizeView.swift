import SwiftUI

struct OutfitItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let price: Int
}

struct CustomizeView: View {
    @State private var selectedItem: OutfitItem? = nil
    @State private var showConfirmation = false
    @State private var coinBalance: Int = 1000
    @State private var usedCoins: Int = 0

    @AppStorage("selectedOutfit") var selectedOutfitName: String = ""

    let items: [OutfitItem] = [
        OutfitItem(imageName: "", title: "ไม่ใส่ชุด", price: 0),
        OutfitItem(imageName: "Bra", title: "ชุดที่ 1", price: 100),
        OutfitItem(imageName: "Skirt", title: "ชุดที่ 2", price: 200),
        OutfitItem(imageName: "Clothes", title: "ชุดที่ 3", price: 500)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("💰 เหรียญคงเหลือ: \(coinBalance) coins")
                    .font(.headline)
                    .padding(.top)

                Text("เลือกเสื้อผ้าให้ตัวการ์ตูน")
                    .font(.title2)
                    .bold()

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 20) {
                    ForEach(items) { item in
                        VStack(spacing: 10) {
                            if item.imageName.isEmpty {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 100, height: 100)
                                    Text("No outfit")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            } else {
                                Image(item.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(radius: 2)
                            }

                            Text(item.title)
                                .font(.headline)

                            Text("ราคา \(item.price) coins")
                                .font(.subheadline)

                            Button(action: {
                                selectedItem = item
                                showConfirmation = true
                            }) {
                                Image(systemName: "cart.fill.badge.plus")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.green)
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Customize")
        .alert(isPresented: $showConfirmation) {
            let item = selectedItem!
            return Alert(
                title: Text("ยืนยันการซื้อ"),
                message: Text("คุณต้องการซื้อ \(item.title) ในราคา \(item.price) coins ใช่ไหม?"),
                primaryButton: .default(Text("ซื้อ")) {
                    if coinBalance >= item.price {
                        coinBalance -= item.price
                        usedCoins += item.price
                        selectedOutfitName = item.imageName
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    CustomizeView()
}
