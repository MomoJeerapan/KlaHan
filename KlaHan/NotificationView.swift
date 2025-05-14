import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let color: Color
}

struct NotificationView: View {
    @State private var currentTab: TabItem = .activity

    let notifications: [NotificationItem] = [
        .init(icon: "person.badge.plus", title: "คำขอเป็นเพื่อน", subtitle: "น้ำ ได้ส่งคำขอมา", time: "5 นาทีที่แล้ว", color: .blue),
        .init(icon: "bitcoinsign.circle", title: "ได้รับเงินคืน", subtitle: "จาก ปลั๊ก จำนวน ฿120", time: "15 นาทีที่แล้ว", color: .green),
        .init(icon: "checkmark.circle", title: "คุณยืนยันรายการแล้ว", subtitle: "ในกลุ่ม ทริปเชียงใหม่", time: "เมื่อวานนี้", color: .orange)
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    HStack {
                        Text("การแจ้งเตือน")
                            .font(.title2)
                            .bold()
                        Spacer()
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(red: 1.0, green: 0.701, blue: 0.0))
                        }
                    }
                    .padding()

                    List(notifications) { item in
                        HStack(alignment: .top) {
                            Image(systemName: item.icon)
                                .foregroundColor(item.color)
                                .font(.system(size: 24))
                                .frame(width: 40, height: 40)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(item.time)
                                    .font(.caption)
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                    .padding(.bottom, 80)
                }

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

                    tabBarButton(tab: .activity, icon: "clock.arrow.circlepath") { NotificationView() }
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
                NavigationLink(destination: destination().onAppear {
                    currentTab = tab
                }) {
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
    NotificationView()
}
