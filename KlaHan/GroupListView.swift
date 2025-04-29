//
//  GroupListView.swift
//  KlaHan
//
//  Created by Jeerapan Chirachanchai on 30/4/2568 BE.
//

import SwiftUI

struct GroupListView: View {
    let groups = Array(repeating: ("Group", 300000), count: 6)

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                // Action สำหรับสร้างกลุ่ม
            }) {
                Text("Create Group")
                    .foregroundColor(.blue)
                    .padding(.horizontal)
                    .padding(.top, 10)
            }

            List(groups, id: \.0) { group in
                HStack {
                    Circle()
                        .fill(Color.teal)
                        .frame(width: 40, height: 40)
                    Text(group.0)
                        .font(.headline)
                    Spacer()
                    Text("\(group.1)")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5)
            }
        }
    }
}


#Preview {
    GroupListView()
}
