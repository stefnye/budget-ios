import SwiftUI

struct TransactionListView: View {
    @StateObject private var vm = TransactionViewModel()
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Mois", selection: $vm.selectedMonth) {
                        ForEach(recentMonths(), id: \.self) { month in
                            Text(month).tag(month)
                        }
                    }
                    .onChange(of: vm.selectedMonth) { _ in
                        Task { await vm.load() }
                    }
                }

                Section("Transactions") {
                    if vm.transactions.isEmpty {
                        Text("Aucune transaction.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(vm.transactions) { txn in
                            TransactionRowView(
                                transaction: txn,
                                category: vm.categories.first { $0.id == txn.categoryId }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddTransactionView(
                    accounts: vm.accounts,
                    categories: vm.categories
                ) { data in
                    Task {
                        await vm.createTransaction(data)
                        showAddSheet = false
                    }
                }
            }
            .refreshable { await vm.load() }
            .task { await vm.load() }
        }
    }

    private func recentMonths() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let cal = Calendar.current
        return (0..<12).compactMap { offset in
            guard let date = cal.date(byAdding: .month, value: -offset, to: Date()) else { return nil }
            return formatter.string(from: date)
        }
    }
}
