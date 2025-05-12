import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct InformationView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""

    @State private var isEditingName = false
    @State private var isEditingEmail = false
    @State private var isEditingPhone = false
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true

    @State private var navigateToChangePass = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToContent = false

    let db = Firestore.firestore()
    let user = Auth.auth().currentUser

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Account Information")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0/255, green: 105/255, blue: 92/255))
                        .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 24) {
                        profileField(
                            title: "Full Name",
                            value: $fullName,
                            isEditing: $isEditingName
                        )
                        profileField(
                            title: "Email",
                            value: $email,
                            isEditing: $isEditingEmail,
                            keyboardType: .emailAddress
                        )
                        profileField(
                            title: "Phone Number",
                            value: $phone,
                            isEditing: $isEditingPhone,
                            keyboardType: .phonePad
                        )
                    }
                    .padding(.horizontal, 24)

                    VStack(spacing: 16) {
                        customButton(title: "Change Password", color: .blue) {
                            navigateToChangePass = true
                        }

                        Button(action: logout) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Logout")
                            }
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 24)

                    NavigationLink(destination: ChangePassView(), isActive: $navigateToChangePass) { EmptyView() }


                    Spacer()
                }
            }
            .navigationBarTitle("Information", displayMode: .inline)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear(perform: fetchUserData)
        }
    }

    func profileField(title: String, value: Binding<String>, isEditing: Binding<Bool>, keyboardType: UIKeyboardType = .default) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if isEditing.wrappedValue {
                    TextField(title, text: value)
                        .keyboardType(keyboardType)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: value.wrappedValue) { newValue in
                            if title == "Phone Number" {
                                value.wrappedValue = newValue.filter { $0.isNumber }
                            }
                        }
                } else {
                    Text(value.wrappedValue)
                        .font(.body)
                }
            }
            Spacer()
            Button(action: {
                if isEditing.wrappedValue {
                    // Validate
                    if title == "Email", !isValidEmail(value.wrappedValue) {
                        alertMessage = "Please enter a valid email ending in .com."
                        showAlert = true
                        return
                    }
                    if title == "Phone Number", !isValidPhone(value.wrappedValue) {
                        alertMessage = "Phone number must be exactly 10 digits (numbers only)."
                        showAlert = true
                        return
                    }
                    updateField(title: title, value: value.wrappedValue)
                }
                isEditing.wrappedValue.toggle()
            }) {
                Image(systemName: isEditing.wrappedValue ? "checkmark.circle.fill" : "pencil")
                    .foregroundColor(.blue)
            }
        }
    }

    func updateField(title: String, value: String) {
        guard let uid = user?.uid else { return }

        var field = ""
        switch title {
        case "Full Name": field = "Username"
        case "Email": field = "Email"
        case "Phone Number": field = "PhoneNum"
        default: return
        }

        db.collection("Users").document(uid).updateData([field: value]) { error in
            if let error = error {
                print("❌ Failed to update \(field): \(error.localizedDescription)")
            } else {
                print("✅ Updated \(field)")
            }
        }
    }

    func fetchUserData() {
        guard let uid = user?.uid else { return }

        db.collection("Users").document(uid).getDocument { doc, error in
            guard let data = doc?.data(), error == nil else { return }
            self.fullName = data["Username"] as? String ?? ""
            self.email = data["Email"] as? String ?? ""
            self.phone = data["PhoneNum"] as? String ?? ""
        }
    }

    func customButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.opacity(0.1))
                .foregroundColor(color)
                .cornerRadius(10)
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.com"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }

    func isValidPhone(_ phone: String) -> Bool {
        return phone.count == 10 && phone.allSatisfy { $0.isNumber }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "userSession")
            isLoggedIn = false
        } catch {
            print("❌ Logout failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    InformationView()
}
