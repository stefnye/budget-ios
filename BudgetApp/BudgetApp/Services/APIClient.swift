import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case serverError(Int, String)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .unauthorized: return "Session expired"
        case .serverError(let code, let detail): return "Server error \(code): \(detail)"
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        case .networkError(let error): return error.localizedDescription
        }
    }
}

actor APIClient {
    static let shared = APIClient()

    private let baseURL = Config.apiBaseURL
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    private var accessToken: String? {
        KeychainHelper.read(forKey: "access_token")
    }

    // MARK: - Generic request

    private func request<T: Decodable>(
        _ method: String,
        path: String,
        body: (any Encodable)? = nil,
        authenticated: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if authenticated, let token = accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            req.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: req)
        } catch {
            throw APIError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        if http.statusCode == 401 {
            throw APIError.unauthorized
        }

        if http.statusCode == 204 {
            // Return an empty-ish value for Void-like responses
            if let empty = EmptyResponse() as? T {
                return empty
            }
        }

        guard (200..<300).contains(http.statusCode) else {
            let detail = (try? JSONDecoder().decode(ErrorDetail.self, from: data))?.detail ?? "Unknown error"
            throw APIError.serverError(http.statusCode, detail)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Auth

    func login(email: String, password: String) async throws -> TokenResponse {
        let body = LoginRequest(email: email, password: password)
        let token: TokenResponse = try await request("POST", path: "/auth/login", body: body, authenticated: false)
        KeychainHelper.save(token.accessToken, forKey: "access_token")
        KeychainHelper.save(token.refreshToken, forKey: "refresh_token")
        return token
    }

    func register(email: String, password: String) async throws -> User {
        let body = LoginRequest(email: email, password: password)
        return try await request("POST", path: "/auth/register", body: body, authenticated: false)
    }

    func logout() {
        KeychainHelper.delete(forKey: "access_token")
        KeychainHelper.delete(forKey: "refresh_token")
    }

    var hasToken: Bool {
        accessToken != nil
    }

    // MARK: - Transactions

    func getTransactions(month: String? = nil, categoryId: UUID? = nil) async throws -> [Transaction] {
        var params: [String] = []
        if let month { params.append("month=\(month)") }
        if let categoryId { params.append("category_id=\(categoryId.uuidString)") }
        let query = params.isEmpty ? "" : "?\(params.joined(separator: "&"))"
        return try await request("GET", path: "/transactions\(query)")
    }

    func createTransaction(_ data: TransactionCreate) async throws -> Transaction {
        return try await request("POST", path: "/transactions", body: data)
    }

    // MARK: - Accounts

    func getAccounts() async throws -> [Account] {
        return try await request("GET", path: "/accounts")
    }

    func createAccount(_ data: AccountCreate) async throws -> Account {
        return try await request("POST", path: "/accounts", body: data)
    }

    // MARK: - Categories

    func getCategories() async throws -> [Category] {
        return try await request("GET", path: "/categories")
    }

    // MARK: - Budgets

    func getBudgets(month: String? = nil) async throws -> [Budget] {
        let query = month.map { "?month=\($0)" } ?? ""
        return try await request("GET", path: "/budgets\(query)")
    }

    // MARK: - Stats

    func getMonthlyStats(month: String? = nil) async throws -> MonthlyStats {
        let query = month.map { "?month=\($0)" } ?? ""
        return try await request("GET", path: "/stats/monthly\(query)")
    }

    func getStatsByCategory(month: String? = nil) async throws -> [CategoryStats] {
        let query = month.map { "?month=\($0)" } ?? ""
        return try await request("GET", path: "/stats/by-category\(query)")
    }
}

// MARK: - Helpers

private struct ErrorDetail: Decodable {
    let detail: String
}

struct EmptyResponse: Decodable {}
