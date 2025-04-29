//
//  GroupListView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI

struct GroupListView: View {
    let groups = [
        ("Family Trip", 150000),
        ("Work Group", 220000),
        ("Friends Party", 180000)
    ]

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                // Create group action
            }) {
                Text("Create Group")
                    .foregroundColor(.blue)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }

            List(groups, id: \.0) { group in
                NavigationLink(destination: GroupDetailView(groupName: group.0)) {
                    HStack {
                        Circle()
                            .fill(Color.teal)
                            .frame(width: 40, height: 40)
                        Text(group.0)
                            .font(.headline)
                        Spacer()
                        Text("฿\(group.1)")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
}
