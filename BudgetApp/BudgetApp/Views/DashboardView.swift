import SwiftUI

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Metric cards
                    HStack(spacing: 12) {
                        MetricCardView(
                            title: "Solde",
                            value: vm.stats?.balance ?? 0,
                            color: .primary
                        )
                        MetricCardView(
                            title: "Dépenses",
                            value: vm.stats?.expenses ?? 0,
                            color: .red
                        )
                        MetricCardView(
                            title: "Revenus",
                            value: vm.stats?.income ?? 0,
                            color: .green
                        )
                    }
                    .padding(.horizontal)

                    // Category breakdown
                    if !vm.categoryStats.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dépenses par catégorie")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(vm.categoryStats) { cs in
                                CategoryBarView(
                                    name: cs.categoryName,
                                    spent: cs.total,
                                    color: Color(hex: cs.color ?? "1D9E75")
                                )
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Recent transactions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dernières transactions")
                            .font(.headline)
                            .padding(.horizontal)

                        if vm.recentTransactions.isEmpty {
                            Text("Aucune transaction ce mois-ci.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            ForEach(vm.recentTransactions) { txn in
                                TransactionRowView(
                                    transaction: txn,
                                    category: vm.categories.first { $0.id == txn.categoryId }
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Tableau de bord")
            .refreshable { await vm.load() }
            .task { await vm.load() }
        }
    }
}

// MARK: - Subviews

struct MetricCardView: View {
    let title: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(String(format: "%.2f €", value))
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

struct CategoryBarView: View {
    let name: String
    let spent: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.2f €", spent))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    Rectangle()
                        .fill(color)
                        .frame(width: min(geo.size.width, geo.size.width), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    let category: Category?

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: category?.color ?? "CCCCCC"))
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description ?? "Sans description")
                    .font(.subheadline)
                Text("\(category?.name ?? "Non catégorisé") · \(transaction.date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(String(format: "%@%.2f €", transaction.amount >= 0 ? "+" : "", transaction.amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(transaction.amount < 0 ? .red : .green)
        }
        .padding(.vertical, 4)
    }
}
