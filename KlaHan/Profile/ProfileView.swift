import SwiftUI

struct ProfileView: View {
    @AppStorage("selectedOutfit") var selectedOutfitName: String = ""
     

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 20) {
                    Spacer().frame(height: 20)

                    // Title
                    HStack {
                        NavigationLink(destination: TopUpView()) {
                            Text("Top Up")
                                .font(.headline)
                                .foregroundColor(Color(red: 1.0, green: 0.701, blue: 0.0))
                        }
                        Spacer()
                        Text("Profile")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                        NavigationLink(destination: InformationView()) {
                            VStack(spacing: 2) {
                                Image("Lion")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }

                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Avatar with outfit overlay
                    ZStack {
                        Image("Lion")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 30))

                        if !selectedOutfitName.isEmpty {
                            Image(selectedOutfitName)
                                .resizable()
                                .frame(width: 200, height: 200)
                        }
                    }
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.top, 30)

                    // Customize Button
                    NavigationLink(destination: CustomizeView()) {
                        Text("Customize Profile")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 1.0, green: 0.701, blue: 0.0))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .padding(.horizontal, 40)
                    }

                    Spacer()
                }
                .padding(.bottom, 80)

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
            if tab == .profile {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(Color(red: 1.0, green: 0.701, blue: 0.0))
            } else {
                NavigationLink(destination: destination()) {
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
    ProfileView()
}
