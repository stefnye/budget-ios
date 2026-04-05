import Foundation

struct Account: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let name: String
    let balance: Double
    let currency: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, balance, currency
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

struct AccountCreate: Codable {
    let name: String
    var balance: Double = 0
    var currency: String = "EUR"
}
