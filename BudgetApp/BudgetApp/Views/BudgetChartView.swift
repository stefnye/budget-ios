import SwiftUI
import Charts

struct BudgetChartView: View {
    @StateObject private var vm = BudgetChartViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Month picker
                    Picker("Mois", selection: $vm.selectedMonth) {
                        ForEach(vm.recentMonths(), id: \.self) { month in
                            Text(month).tag(month)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: vm.selectedMonth) { _ in
                        Task { await vm.load() }
                    }
                    .padding(.horizontal)

                    // Summary cards
                    HStack(spacing: 12) {
                        SummaryCardView(
                            title: "Total dépensé",
                            value: String(format: "%.2f €", vm.totalSpent),
                            color: .red
                        )
                        SummaryCardView(
                            title: "Budget total",
                            value: vm.totalBudget.map { String(format: "%.2f €", $0) } ?? "Non défini",
                            color: vm.totalBudget != nil ? Color(hex: "1D9E75") : .secondary
                        )
                    }
                    .padding(.horizontal)

                    if vm.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if vm.categoryStats.isEmpty {
                        Text("Aucune dépense pour ce mois.")
                            .foregroundColor(.secondary)
                            .padding(.top, 40)
                    } else {
                        // Donut chart
                        PieChartSection(stats: vm.categoryStats, total: vm.totalSpent)
                            .padding(.horizontal)

                        // Legend
                        LegendSection(stats: vm.categoryStats, total: vm.totalSpent)
                            .padding(.horizontal)

                        // Detail table
                        DetailTableSection(stats: vm.categoryStats, total: vm.totalSpent)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Répartition")
            .refreshable { await vm.load() }
            .task { await vm.load() }
        }
    }
}

// MARK: - Summary Card

private struct SummaryCardView: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
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

// MARK: - Pie Chart (Donut)

private struct PieChartSection: View {
    let stats: [CategoryStats]
    let total: Double

    var body: some View {
        Chart(stats) { item in
            SectorMark(
                angle: .value("Montant", item.total),
                innerRadius: .ratio(0.55),
                angularInset: 1.5
            )
            .foregroundStyle(Color(hex: item.color ?? "CCCCCC"))
            .annotation(position: .overlay) {
                let pct = total > 0 ? (item.total / total) * 100 : 0
                if pct >= 5 {
                    Text(String(format: "%.0f%%", pct))
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
        }
        .chartBackground { _ in
            VStack {
                Text("Total")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(String(format: "%.2f €", total))
                    .font(.headline)
                    .fontWeight(.bold)
            }
        }
        .frame(height: 260)
    }
}

// MARK: - Legend

private struct LegendSection: View {
    let stats: [CategoryStats]
    let total: Double

    private var sorted: [CategoryStats] {
        stats.sorted { $0.total > $1.total }
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(sorted) { item in
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: item.color ?? "CCCCCC"))
                        .frame(width: 10, height: 10)
                    Text(item.categoryName)
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Detail Table

private struct DetailTableSection: View {
    let stats: [CategoryStats]
    let total: Double

    private var sorted: [CategoryStats] {
        stats.sorted { $0.total > $1.total }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Détail par catégorie")
                .font(.headline)
                .padding(.bottom, 12)

            // Header
            HStack {
                Text("Catégorie")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Montant")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 80, alignment: .trailing)
                Text("Part")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .trailing)
            }
            .padding(.bottom, 6)

            Divider()

            ForEach(sorted) { item in
                let pct = total > 0 ? (item.total / total) * 100 : 0
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: item.color ?? "CCCCCC"))
                            .frame(width: 10, height: 10)
                        Text(item.categoryName)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(String(format: "%.2f €", item.total))
                        .font(.subheadline)
                        .frame(width: 80, alignment: .trailing)
                    Text(String(format: "%.1f%%", pct))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 50, alignment: .trailing)
                }
                .padding(.vertical, 8)
                Divider()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}
