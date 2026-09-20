import SwiftUI
import LocalAuthentication

struct BiometricAuthView: View {
    @Binding var isAuthenticated: Bool
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "faceid")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("SecureAuth")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your 2FA codes are protected")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: authenticate) {
                Label("Unlock", systemImage: "lock.open")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
        .alert("Authentication Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            authenticate()
        }
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your 2FA codes"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        isAuthenticated = true
                    } else {
                        errorMessage = error?.localizedDescription ?? "Authentication failed"
                        showError = true
                    }
                }
            }
        } else {
            isAuthenticated = true
        }
    }
}
