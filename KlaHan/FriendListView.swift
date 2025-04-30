//
//  FriendListView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI

struct FriendListView: View {
    let friends = [
        ("Nene", 300000),
        ("Tan", 300000),
        ("Momo", 300000)
    ]

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                // Add friend action
            }) {
                Text("Add friend")
                    .foregroundColor(.blue)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }

            List(friends, id: \.0) { friend in
                NavigationLink(destination: FriendDetailView(name: friend.0)) {
                    HStack {
                        Circle()
                            .fill(Color.teal)
                            .frame(width: 40, height: 40)
                        Text(friend.0)
                            .font(.headline)
                        Spacer()
                        Text("฿\(friend.1)")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
}

#Preview {
    FriendListView()
}
