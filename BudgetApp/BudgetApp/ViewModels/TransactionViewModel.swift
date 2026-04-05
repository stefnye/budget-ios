import Foundation

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categories: [Category] = []
    @Published var accounts: [Account] = []
    @Published var selectedMonth: String
    @Published var isLoading = false

    private let api = APIClient.shared

    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        self.selectedMonth = formatter.string(from: Date())
    }

    func load() async {
        isLoading = true
        do {
            async let txnTask = api.getTransactions(month: selectedMonth)
            async let catTask = api.getCategories()
            async let accTask = api.getAccounts()

            transactions = try await txnTask
            categories = try await catTask
            accounts = try await accTask
        } catch {
            print("Transaction load error: \(error)")
        }
        isLoading = false
    }

    func createTransaction(_ data: TransactionCreate) async {
        do {
            _ = try await api.createTransaction(data)
            await load()
        } catch {
            print("Create transaction error: \(error)")
        }
    }
}
