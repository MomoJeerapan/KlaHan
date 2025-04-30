//
//  CommunityView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI

struct CommunityView: View {
    enum Tab {
        case friend, group
    }

    @State private var selectedTab: Tab = .friend

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Top Bar
                HStack {
                    Image(systemName: "gear")
                    Spacer()
                    Text("Community")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "magnifyingglass")
                }
                .padding()

                // Tab Bar
                HStack(spacing: 0) {
                    Button(action: {
                        selectedTab = .friend
                    }) {
                        Text("Friend")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedTab == .friend ? Color.teal : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                    }

                    Button(action: {
                        selectedTab = .group
                    }) {
                        Text("Group")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedTab == .group ? Color.teal : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                    }
                }

                // Content View
                if selectedTab == .friend {
                    FriendListView()
                } else {
                    GroupListView()
                }

                Spacer()

                // Bottom Tab Bar Placeholder
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
}

#Preview {
    CommunityView()
}
