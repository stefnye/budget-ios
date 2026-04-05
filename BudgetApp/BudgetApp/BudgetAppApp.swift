import SwiftUI

@main
struct BudgetAppApp: App {
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authVM.isAuthenticated {
                TabView {
                    DashboardView()
                        .tabItem {
                            Label("Accueil", systemImage: "house.fill")
                        }
                    TransactionListView()
                        .tabItem {
                            Label("Transactions", systemImage: "list.bullet")
                        }
                    BudgetView()
                        .tabItem {
                            Label("Budgets", systemImage: "chart.bar.fill")
                        }
                }
                .environmentObject(authVM)
            } else {
                LoginView()
                    .environmentObject(authVM)
            }
        }
    }
}
