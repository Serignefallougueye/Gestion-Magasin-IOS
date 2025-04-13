import SwiftUI
import CoreData

struct CurrentPurchaseOrdersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CommandeAchat.dateCommande, ascending: false)],
        predicate: NSPredicate(format: "statut != %@", "LIVREE"),
        animation: .default)
    private var commandes: FetchedResults<CommandeAchat>
    
    var body: some View {
        List {
            ForEach(commandes) { commande in
                NavigationLink(destination: PurchaseOrderDetailView(commande: commande)) {
                    VStack(alignment: .leading) {
                        Text(commande.fournisseur?.nom ?? "Fournisseur inconnu")
                            .font(.headline)
                        Text("Date: \(commande.dateCommande?.formatted(date: .abbreviated, time: .omitted) ?? "Non définie")")
                            .font(.subheadline)
                        Text("Statut: \(commande.statut ?? "En attente")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .onDelete(perform: deleteCommandes)
        }
        .navigationTitle("Commandes en cours")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: NewPurchaseOrderView()) {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private func deleteCommandes(offsets: IndexSet) {
        withAnimation {
            offsets.map { commandes[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Erreur lors de la suppression: \(error)")
            }
        }
    }
} 
