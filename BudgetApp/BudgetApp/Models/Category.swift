import Foundation

struct Category: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let name: String
    let color: String?
    let icon: String?
    let type: String

    enum CodingKeys: String, CodingKey {
        case id, name, color, icon, type
        case userId = "user_id"
    }
}
