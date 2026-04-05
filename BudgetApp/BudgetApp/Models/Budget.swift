import Foundation

struct Budget: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let categoryId: UUID
    let amountLimit: Double
    let month: String

    enum CodingKeys: String, CodingKey {
        case id, month
        case userId = "user_id"
        case categoryId = "category_id"
        case amountLimit = "amount_limit"
    }
}

struct MonthlyStats: Codable {
    let year: Int
    let month: Int
    let income: Double
    let expenses: Double
    let balance: Double
}

struct CategoryStats: Codable, Identifiable {
    let categoryId: String
    let categoryName: String
    let color: String?
    let total: Double

    var id: String { categoryId }

    enum CodingKeys: String, CodingKey {
        case total, color
        case categoryId = "category_id"
        case categoryName = "category_name"
    }
}
