//
//  ContentView.swift
//  KlaHan
//
//  Created by COSCI_LAB on 26/4/2568 BE.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            HomeView()
        } else {
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}


#Preview {
    ContentView()
}
