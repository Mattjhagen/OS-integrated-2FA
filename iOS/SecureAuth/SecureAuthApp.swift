import SwiftUI

@main
struct SecureAuthApp: App {
    @StateObject private var accountManager = AccountManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(accountManager)
        }
    }
}
