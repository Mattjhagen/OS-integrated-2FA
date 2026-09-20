import Foundation

struct TOTPAccount: Identifiable, Codable {
    let id: UUID
    let issuer: String
    let accountName: String
    let secret: String
    let algorithm: String
    let digits: Int
    let period: Int

    init(id: UUID = UUID(), issuer: String, accountName: String, secret: String, algorithm: String = "SHA1", digits: Int = 6, period: Int = 30) {
        self.id = id
        self.issuer = issuer
        self.accountName = accountName
        self.secret = secret
        self.algorithm = algorithm
        self.digits = digits
        self.period = period
    }
}
