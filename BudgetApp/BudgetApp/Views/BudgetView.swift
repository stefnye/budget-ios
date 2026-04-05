import SwiftUI

struct BudgetView: View {
    @State private var budgets: [Budget] = []
    @State private var categoryStats: [CategoryStats] = []
    @State private var categories: [Category] = []
    @State private var isLoading = false

    private let api = APIClient.shared

    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            List {
                if budgets.isEmpty && !isLoading {
                    Text("Aucun budget défini pour ce mois.")
                        .foregroundColor(.secondary)
                }

                ForEach(budgets) { budget in
                    let cat = categories.first { $0.id == budget.categoryId }
                    let stat = categoryStats.first { $0.categoryId == budget.categoryId.uuidString }
                    let spent = stat?.total ?? 0
                    let limit = budget.amountLimit
                    let pct = limit > 0 ? min(spent / limit, 1.0) : 0

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(cat?.name ?? "Catégorie inconnue")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text(String(format: "%.2f € / %.2f €", spent, limit))
                                .font(.caption)
                                .foregroundColor(spent > limit ? .red : .secondary)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 10)
                                    .cornerRadius(5)
                                Rectangle()
                                    .fill(spent > limit ? Color.red : Color(hex: cat?.color ?? "1D9E75"))
                                    .frame(width: geo.size.width * pct, height: 10)
                                    .cornerRadius(5)
                            }
                        }
                        .frame(height: 10)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Budgets")
            .refreshable { await load() }
            .task { await load() }
        }
    }

    private func load() async {
        isLoading = true
        do {
            async let b = api.getBudgets(month: currentMonth)
            async let cs = api.getStatsByCategory(month: currentMonth)
            async let cats = api.getCategories()
            budgets = try await b
            categoryStats = try await cs
            categories = try await cats
        } catch {
            print("Budget load error: \(error)")
        }
        isLoading = false
    }
}
