import SwiftUI

// ✅ Global enum shared across views
enum TabItem {
    case home, community, trend, customize, activity, profile
}

struct CommunityView: View {
    enum CommunityTab {
        case friend, group
    }

    @State private var selectedTab: CommunityTab = .friend
    @State private var currentTab: TabItem = .community

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    // Top Bar with Notification and Profile
                    HStack {
                        NavigationLink(destination: NotificationView()) {
                            Image(systemName: "bell.badge.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("Community")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        NavigationLink(destination: ProfileView()) {
                            VStack(spacing: 2) {
                                Image("Lion")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                                Text("M.")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)

                    // Toggle Tabs (Friend / Group)
                    HStack(spacing: 0) {
                        Button(action: {
                            selectedTab = .friend
                        }) {
                            Text("Friend")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedTab == .friend ? Color(red: 1.0, green: 0.701, blue: 0.0) : Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                        }

                        Button(action: {
                            selectedTab = .group
                        }) {
                            Text("Group")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedTab == .group ? Color(red: 1.0, green: 0.701, blue: 0.0) : Color.gray.opacity(0.2))
                                .foregroundColor(.white)
                        }
                    }

                    // Content View
                    if selectedTab == .friend {
                        FriendListView()
                    } else {
                        GroupListView()
                    }

                    Spacer(minLength: 100)
                }
                .padding(.bottom, 80)

                // Tab Bar with shared style
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

// Dummy Views

#Preview {
    CommunityView()
}
