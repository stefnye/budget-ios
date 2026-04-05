import Foundation

struct Transaction: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let accountId: UUID
    let categoryId: UUID?
    let amount: Double
    let description: String?
    let date: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, amount, description, date
        case userId = "user_id"
        case accountId = "account_id"
        case categoryId = "category_id"
        case createdAt = "created_at"
    }
}

struct TransactionCreate: Codable {
    let accountId: UUID
    let categoryId: UUID?
    let amount: Double
    let description: String?
    let date: String

    enum CodingKeys: String, CodingKey {
        case amount, description, date
        case accountId = "account_id"
        case categoryId = "category_id"
    }
}
