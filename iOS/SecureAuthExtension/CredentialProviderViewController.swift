import AuthenticationServices
import LocalAuthentication

class CredentialProviderViewController: ASCredentialProviderViewController {
    private let accountManager = AccountManager.shared
    private let keychainService = KeychainService()

    override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
        accountManager.loadAccounts()
        extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
    }

    override func provideCredentialWithoutUserInteraction(for credentialIdentity: ASPasswordCredentialIdentity) {
        authenticateAndProvideCode(for: credentialIdentity, requireUserInteraction: false)
    }

    override func prepareInterfaceToProvideCredential(for credentialIdentity: ASPasswordCredentialIdentity) {
        authenticateAndProvideCode(for: credentialIdentity, requireUserInteraction: true)
    }

    private func authenticateAndProvideCode(for credentialIdentity: ASPasswordCredentialIdentity, requireUserInteraction: Bool) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userInteractionRequired.rawValue))
            return
        }

        let reason = "Authenticate to autofill your 2FA code"

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if success {
                    self.provideCode(for: credentialIdentity)
                } else {
                    self.extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.userCanceled.rawValue))
                }
            }
        }
    }

    private func provideCode(for credentialIdentity: ASPasswordCredentialIdentity) {
        guard let accountIdString = credentialIdentity.recordIdentifier,
              let accountId = UUID(uuidString: accountIdString),
              let code = accountManager.getCode(for: accountId) else {
            extensionContext.cancelRequest(withError: NSError(domain: ASExtensionErrorDomain, code: ASExtensionError.credentialIdentityNotFound.rawValue))
            return
        }

        let passwordCredential = ASPasswordCredential(user: credentialIdentity.user, password: code)
        extensionContext.completeRequest(withSelectedCredential: passwordCredential)
    }

    override func prepareInterfaceForExtensionConfiguration() {
        // Configuration UI would go here
    }
}
