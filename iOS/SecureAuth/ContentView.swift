import SwiftUI

struct ContentView: View {
    @EnvironmentObject var accountManager: AccountManager
    @State private var showingAddAccount = false
    @State private var showingScanner = false
    @State private var isAuthenticated = false

    var body: some View {
        NavigationView {
            Group {
                if isAuthenticated {
                    AccountListView(showingAddAccount: $showingAddAccount, showingScanner: $showingScanner)
                } else {
                    BiometricAuthView(isAuthenticated: $isAuthenticated)
                }
            }
            .navigationTitle("SecureAuth")
            .toolbar {
                if isAuthenticated {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddAccount = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddAccount) {
                AddAccountView()
            }
            .sheet(isPresented: $showingScanner) {
                QRScannerView()
            }
        }
    }
}

struct AccountListView: View {
    @EnvironmentObject var accountManager: AccountManager
    @Binding var showingAddAccount: Bool
    @Binding var showingScanner: Bool
    @State private var searchText = ""

    var filteredAccounts: [TOTPAccount] {
        if searchText.isEmpty {
            return accountManager.accounts
        }
        return accountManager.accounts.filter {
            $0.issuer.localizedCaseInsensitiveContains(searchText) ||
            $0.accountName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            if accountManager.accounts.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No Accounts Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Add your first 2FA account by scanning a QR code or entering manually")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: { showingScanner = true }) {
                        Label("Scan QR Code", systemImage: "qrcode.viewfinder")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Button(action: { showingAddAccount = true }) {
                        Label("Enter Manually", systemImage: "keyboard")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            } else {
                ForEach(filteredAccounts) { account in
                    AccountRowView(account: account)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        accountManager.deleteAccount(filteredAccounts[index])
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search accounts")
    }
}

struct AccountRowView: View {
    let account: TOTPAccount
    @State private var currentCode = "------"
    @State private var timeRemaining = 30
    @State private var timer: Timer?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.issuer)
                    .font(.headline)
                Text(account.accountName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(currentCode)
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.bold)

                ProgressView(value: Double(timeRemaining), total: 30)
                    .frame(width: 80)
                    .tint(timeRemaining <= 5 ? .red : .accentColor)
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            updateCode()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func updateCode() {
        currentCode = TOTPGenerator.generateCode(secret: account.secret)
        timeRemaining = 30 - (Int(Date().timeIntervalSince1970) % 30)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateCode()
        }
    }
}
