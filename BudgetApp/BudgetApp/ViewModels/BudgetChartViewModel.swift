import Foundation

@MainActor
class BudgetChartViewModel: ObservableObject {
    @Published var categoryStats: [CategoryStats] = []
    @Published var budgets: [Budget] = []
    @Published var selectedMonth: String
    @Published var isLoading = false

    private let api = APIClient.shared

    var totalSpent: Double {
        categoryStats.reduce(0) { $0 + $1.total }
    }

    var totalBudget: Double? {
        guard !budgets.isEmpty else { return nil }
        return budgets.reduce(0) { $0 + $1.amountLimit }
    }

    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        self.selectedMonth = formatter.string(from: Date())
    }

    func load() async {
        isLoading = true
        do {
            async let statsTask = api.getStatsByCategory(month: selectedMonth)
            async let budgetsTask = api.getBudgets(month: selectedMonth)
            categoryStats = try await statsTask
            budgets = try await budgetsTask
        } catch {
            print("BudgetChart load error: \(error)")
        }
        isLoading = false
    }

    func recentMonths() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let cal = Calendar.current
        return (0..<12).compactMap { offset in
            guard let date = cal.date(byAdding: .month, value: -offset, to: Date()) else { return nil }
            return formatter.string(from: date)
        }
    }
}
