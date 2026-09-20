import Foundation
import Combine

class AccountManager: ObservableObject {
    static let shared = AccountManager()

    @Published var accounts: [TOTPAccount] = []

    private let keychainService = KeychainService()
    private let accountsKey = "totp_accounts"

    init() {
        loadAccounts()
    }

    func loadAccounts() {
        if let data = keychainService.load(key: accountsKey),
           let decoded = try? JSONDecoder().decode([TOTPAccount].self, from: data) {
            accounts = decoded
        }
    }

    func addAccount(_ account: TOTPAccount) {
        accounts.append(account)
        saveAccounts()
    }

    func deleteAccount(_ account: TOTPAccount) {
        accounts.removeAll { $0.id == account.id }
        saveAccounts()
    }

    func updateAccount(_ account: TOTPAccount) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
            saveAccounts()
        }
    }

    private func saveAccounts() {
        if let encoded = try? JSONEncoder().encode(accounts) {
            keychainService.save(key: accountsKey, data: encoded)
        }
    }

    func getCode(for accountId: UUID) -> String? {
        guard let account = accounts.first(where: { $0.id == accountId }) else {
            return nil
        }
        return TOTPGenerator.generateCode(secret: account.secret, digits: account.digits, period: account.period)
    }
}
