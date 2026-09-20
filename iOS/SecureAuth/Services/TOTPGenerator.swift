import Foundation
import CryptoKit

class TOTPGenerator {
    static func generateCode(secret: String, time: Date = Date(), digits: Int = 6, period: Int = 30) -> String {
        guard let secretData = base32Decode(secret) else {
            return "------"
        }

        let counter = UInt64(time.timeIntervalSince1970) / UInt64(period)

        var counterBytes = withUnsafeBytes(of: counter.bigEndian) { Array($0) }

        let key = SymmetricKey(data: secretData)
        let hmac = HMAC<Insecure.SHA1>.authenticationCode(for: counterBytes, using: key)
        let hmacBytes = Array(hmac)

        let offset = Int(hmacBytes[hmacBytes.count - 1] & 0x0f)

        let truncatedHash = hmacBytes[offset..<offset + 4]
        let value = truncatedHash.reduce(0) { ($0 << 8) | UInt32($1) } & 0x7fffffff

        let otp = value % UInt32(pow(10.0, Double(digits)))

        return String(format: "%0\(digits)d", otp)
    }

    static func base32Decode(_ string: String) -> Data? {
        let base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        var bits = ""
        let cleanString = string.uppercased().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "=", with: "")

        for char in cleanString {
            if let index = base32Alphabet.firstIndex(of: char) {
                let value = base32Alphabet.distance(from: base32Alphabet.startIndex, to: index)
                bits += String(value, radix: 2).padLeft(toLength: 5, withPad: "0")
            } else {
                return nil
            }
        }

        var bytes = [UInt8]()
        for i in stride(from: 0, to: bits.count, by: 8) {
            let endIndex = min(i + 8, bits.count)
            let byte = bits[bits.index(bits.startIndex, offsetBy: i)..<bits.index(bits.startIndex, offsetBy: endIndex)]
            if byte.count == 8, let value = UInt8(byte, radix: 2) {
                bytes.append(value)
            }
        }

        return Data(bytes)
    }

    static func parseOTPAuthURL(_ url: String) -> TOTPAccount? {
        guard let urlComponents = URLComponents(string: url),
              urlComponents.scheme == "otpauth",
              urlComponents.host == "totp",
              let secret = urlComponents.queryItems?.first(where: { $0.name == "secret" })?.value else {
            return nil
        }

        let path = urlComponents.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let components = path.components(separatedBy: ":")

        let issuer = urlComponents.queryItems?.first(where: { $0.name == "issuer" })?.value ?? (components.count > 1 ? components[0] : "Unknown")
        let accountName = components.count > 1 ? components[1] : components[0]

        let algorithm = urlComponents.queryItems?.first(where: { $0.name == "algorithm" })?.value ?? "SHA1"
        let digits = Int(urlComponents.queryItems?.first(where: { $0.name == "digits" })?.value ?? "6") ?? 6
        let period = Int(urlComponents.queryItems?.first(where: { $0.name == "period" })?.value ?? "30") ?? 30

        return TOTPAccount(issuer: issuer, accountName: accountName, secret: secret, algorithm: algorithm, digits: digits, period: period)
    }
}

extension String {
    func padLeft(toLength: Int, withPad: String) -> String {
        let padding = String(repeating: withPad, count: max(0, toLength - count))
        return padding + self
    }
}
