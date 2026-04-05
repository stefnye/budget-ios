import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var stats: MonthlyStats?
    @Published var recentTransactions: [Transaction] = []
    @Published var categories: [Category] = []
    @Published var categoryStats: [CategoryStats] = []
    @Published var isLoading = false

    private let api = APIClient.shared

    var currentMonth: String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: now)
    }

    func load() async {
        isLoading = true
        do {
            async let statsTask = api.getMonthlyStats(month: currentMonth)
            async let transactionsTask = api.getTransactions(month: currentMonth)
            async let categoriesTask = api.getCategories()
            async let categoryStatsTask = api.getStatsByCategory(month: currentMonth)

            stats = try await statsTask
            let allTxns = try await transactionsTask
            recentTransactions = Array(allTxns.prefix(10))
            categories = try await categoriesTask
            categoryStats = try await categoryStatsTask
        } catch {
            print("Dashboard load error: \(error)")
        }
        isLoading = false
    }
}
