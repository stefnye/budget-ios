import SwiftUI

struct AddTransactionView: View {
    let accounts: [Account]
    let categories: [Category]
    let onSubmit: (TransactionCreate) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var amount = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var selectedAccountId: UUID?
    @State private var selectedCategoryId: UUID?

    var body: some View {
        NavigationStack {
            Form {
                Section("Détails") {
                    TextField("Montant (€)", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("Description", text: $description)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Compte") {
                    Picker("Compte", selection: $selectedAccountId) {
                        Text("Sélectionner...").tag(nil as UUID?)
                        ForEach(accounts) { account in
                            Text(account.name).tag(account.id as UUID?)
                        }
                    }
                }

                Section("Catégorie") {
                    Picker("Catégorie", selection: $selectedCategoryId) {
                        Text("Aucune").tag(nil as UUID?)
                        ForEach(categories) { cat in
                            Text(cat.name).tag(cat.id as UUID?)
                        }
                    }
                }
            }
            .navigationTitle("Nouvelle transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")),
                              let accountId = selectedAccountId else { return }
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let data = TransactionCreate(
                            accountId: accountId,
                            categoryId: selectedCategoryId,
                            amount: amountValue,
                            description: description.isEmpty ? nil : description,
                            date: formatter.string(from: date)
                        )
                        onSubmit(data)
                    }
                    .disabled(amount.isEmpty || selectedAccountId == nil)
                }
            }
        }
    }
}
