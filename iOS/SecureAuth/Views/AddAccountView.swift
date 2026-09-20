import SwiftUI

struct AddAccountView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var accountManager: AccountManager

    @State private var issuer = ""
    @State private var accountName = ""
    @State private var secret = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Information")) {
                    TextField("Issuer (e.g., Google, GitHub)", text: $issuer)
                    TextField("Account (e.g., user@example.com)", text: $accountName)
                }

                Section(header: Text("Secret Key"), footer: Text("The secret key is usually provided as a Base32 encoded string")) {
                    TextField("Secret Key", text: $secret)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }

                Section {
                    Button(action: addAccount) {
                        Text("Add Account")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.accentColor)
                    .disabled(issuer.isEmpty || accountName.isEmpty || secret.isEmpty)
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func addAccount() {
        let cleanSecret = secret.replacingOccurrences(of: " ", with: "").uppercased()

        if TOTPGenerator.base32Decode(cleanSecret) == nil {
            errorMessage = "Invalid secret key. Please check and try again."
            showError = true
            return
        }

        let account = TOTPAccount(
            issuer: issuer,
            accountName: accountName,
            secret: cleanSecret
        )

        accountManager.addAccount(account)
        dismiss()
    }
}
