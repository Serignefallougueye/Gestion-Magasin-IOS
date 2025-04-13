import SwiftUI

struct PurchasesView: View {
    var body: some View {
        List {
            NavigationLink(destination: NewPurchaseOrderView()) {
                Label {
                    VStack(alignment: .leading) {
                        Text("Nouvelle Commande")
                            .font(.headline)
                        Text("Créer une nouvelle commande d'achat")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } icon: {
                    Image(systemName: "cart.badge.plus")
                        .foregroundColor(.blue)
                }
            }
            
            NavigationLink(destination: CurrentPurchaseOrdersView()) {
                Label {
                    VStack(alignment: .leading) {
                        Text("Commandes en Cours")
                            .font(.headline)
                        Text("Suivre les commandes en cours")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } icon: {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                }
            }
            
            NavigationLink(destination: PurchaseHistoryView()) {
                Label {
                    VStack(alignment: .leading) {
                        Text("Historique des Achats")
                            .font(.headline)
                        Text("Consulter l'historique des commandes")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } icon: {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Achats")
    }
}