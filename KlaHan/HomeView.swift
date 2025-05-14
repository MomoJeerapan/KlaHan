import SwiftUI

struct HomeView: View {
    enum TabItem {
        case home, community, trend, customize, activity, profile
    }

    struct Fortune {
        let message: String
        let emoji: String
        let lionQuote: String
    }

    struct MoneyMission: Identifiable {
        let id = UUID()
        let title: String
        let coinReward: Int
    }

    @State private var currentTab: TabItem = .home
    @State private var dailyFortune: String = "กดปุ่มด้านล่างเพื่อดูดวงวันนี้"
    @State private var fortuneEmoji: String = "🔮"
    @State private var lionComment: String = ""
    @State private var missions: [MoneyMission] = [
        .init(title: "จ่ายเงินให้เพื่อนภายใน 5 นาที", coinReward: 10),
        .init(title: "แสกนบิลและบันทึกสำเร็จ", coinReward: 12),
        .init(title: "บันทึกรายการเงินคืน 1 รายการ", coinReward: 8),
        .init(title: "ชวนเพื่อนมาใช้แอพ 1 คน", coinReward: 20)
    ]
    @State private var completedMissions: Set<UUID> = []
    @State private var totalCoins: Int = 0

    let fortunes: [Fortune] = [
        Fortune(message: "วันนี้คุณจะได้รับเงินคืนแบบไม่คาดคิด!", emoji: "💸", lionQuote: "โชคหล่นใส่แน่นอน เตรียมรับตังค์!"),
        Fortune(message: "เพื่อนจะเลี้ยงกาแฟฟรี", emoji: "☕️", lionQuote: "ดื่มกาแฟให้สมศักดิ์ศรีสิงโตมั่งคั่ง!"),
        Fortune(message: "วันนี้อาจจะต้องจ่ายแทนเพื่อนนะ...", emoji: "😡", lionQuote: "เดือดหน่อยนะ แต่ใจดีไว้ เดี๋ยวได้คืน!"),
        Fortune(message: "คุณคือเศรษฐีแฝงตัว", emoji: "🦁✨", lionQuote: "มีทองอยู่ในใจ ถึงยังไม่เห็นในบัญชี!"),
        Fortune(message: "ระวังโดนเท ไม่ได้เงินคืนนะ", emoji: "🥲", lionQuote: "ใจเย็นไว้... อย่าให้สิงโตออกโรง!"),
        Fortune(message: "ดวงการเงินแข็งแรง!", emoji: "💰", lionQuote: "เงินเข้าแน่นอน! สิงโตคอนเฟิร์ม!")
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 20) {
                    // Top Bar
                    HStack {
                        NavigationLink(destination: NotificationView()) {
                            Image(systemName: "bell.badge.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("Welcome")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.701, blue: 0.0))
                        Spacer()
                        NavigationLink(destination: ProfileView()) {
                            VStack(spacing: 2) {
                                Image("Lion")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                                Text("M.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }

                    }
                    .padding(.horizontal)

                    // Card
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(height: 100)
                        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        .overlay(
                            HStack {
                                Image(systemName: "creditcard.fill")
                                    .resizable()
                                    .frame(width: 50, height: 35)
                                    .padding()
                                    .foregroundColor(Color(red: 1.0, green: 0.701, blue: 0.0))

                                VStack(alignment: .leading) {
                                    Text("คะแนนความมั่งคั่ง")
                                        .font(.headline)
                                        .foregroundColor(.black)

                                    HStack {
                                        ForEach(0..<5) { _ in
                                            Image(systemName: "star.fill")
                                                .foregroundColor(Color(red: 1.0, green: 0.701, blue: 0.0))
                                        }
                                    }
                                }
                            }
                        )

                    // Fortune Section
                    VStack(spacing: 10) {
                        Text("\(fortuneEmoji) ดวงประจำวันของคุณ")
                            .font(.headline)
                            .foregroundColor(.gray)

                        Text(dailyFortune)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 1.0, green: 0.701, blue: 0.0))
                            .padding(.horizontal)

                        if !lionComment.isEmpty {
                            Text("🦁: \(lionComment)")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        }

                        Button(action: {
                            if let selected = fortunes.randomElement() {
                                withAnimation(.spring()) {
                                    dailyFortune = selected.message
                                    fortuneEmoji = selected.emoji
                                    lionComment = selected.lionQuote
                                }
                            }
                        }) {
                            Text("สุ่มดวงวันนี้ 🔮")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(Color(red: 1.0, green: 0.701, blue: 0.0))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.top)

                    // Missions
                    Divider().padding(.vertical, 10)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("💼 ภารกิจเงินทองประจำวัน")
                            .font(.headline)
                            .foregroundColor(.gray)

                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(missions) { mission in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(alignment: .top) {
                                            Image(systemName: completedMissions.contains(mission.id) ? "checkmark.seal.fill" : "target")
                                                .resizable()
                                                .frame(width: 24, height: 24)
                                                .foregroundColor(completedMissions.contains(mission.id) ? .green : Color(red: 1.0, green: 0.701, blue: 0.0))

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(mission.title)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)

                                                if completedMissions.contains(mission.id) {
                                                    Text("✅ รับ \(mission.coinReward) coins แล้ว")
                                                        .font(.subheadline)
                                                        .foregroundColor(.green)
                                                } else {
                                                    Button(action: {
                                                        withAnimation {
                                                            completedMissions.insert(mission.id)
                                                            totalCoins += mission.coinReward
                                                        }
                                                    }) {
                                                        HStack {
                                                            Image(systemName: "bitcoinsign.circle.fill")
                                                            Text("รับ \(mission.coinReward) coins")
                                                        }
                                                        .font(.subheadline.bold())
                                                        .padding(.vertical, 6)
                                                        .padding(.horizontal, 12)
                                                        .background(Color.green.opacity(0.85))
                                                        .foregroundColor(.white)
                                                        .cornerRadius(10)
                                                        .shadow(radius: 2)
                                                    }
                                                }
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                        .background(
                                            LinearGradient(gradient: Gradient(colors: [Color.white, Color(.systemGray6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color(red: 1.0, green: 0.701, blue: 0.0), lineWidth: 1.5)
                                        )
                                        .cornerRadius(15)
                                        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .frame(maxHeight: 250)

                        HStack(spacing: 6) {
                            Image(systemName: "star.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.yellow)
                            Text("เหรียญสะสมทั้งหมด: \(totalCoins)")
                                .font(.footnote.bold())
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                    }
                    .padding(.top)

                    Spacer()
                }
                .padding()
                .background(Color.white)
                .ignoresSafeArea(edges: .bottom)

                // Tab Bar
                HStack(spacing: 0) {
                    tabBarButton(tab: .home, icon: "house.fill") { HomeView() }
                    tabBarButton(tab: .community, icon: "person.2.fill") { CommunityView() }

                    NavigationLink(destination: ScanView()) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 1.0, green: 0.701, blue: 0.0))
                                .frame(width: 60, height: 60)
                                .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 3)
                            Image(systemName: "qrcode.viewfinder")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    tabBarButton(tab: .activity, icon: "clock.arrow.circlepath") { TrendView() }
                    tabBarButton(tab: .profile, icon: "person.crop.circle") { ProfileView() }
                }
                .frame(height: 70)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, y: -2)
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }

    @ViewBuilder
    func tabBarButton<Destination: View>(tab: TabItem, icon: String, destination: @escaping () -> Destination) -> some View {
        Group {
            if currentTab == tab {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(Color(red: 1.0, green: 0.701, blue: 0.0))
            } else {
                NavigationLink(destination: destination().onAppear { currentTab = tab }) {
                    Image(systemName: icon)
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    HomeView()
}
