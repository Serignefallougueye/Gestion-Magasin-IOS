import SwiftUI
import CoreData

struct PurchaseHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CommandeAchat.dateCommande, ascending: false)],
        predicate: NSPredicate(format: "statut == %@", "LIVREE"),
        animation: .default)
    private var commandesLivrees: FetchedResults<CommandeAchat>
    
    var body: some View {
        List {
            ForEach(commandesLivrees, id: \.self) { commande in
                NavigationLink(destination: PurchaseOrderDetailView(commande: commande)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(commande.fournisseur?.nom ?? "Fournisseur inconnu")
                                .font(.headline)
                            Spacer()
                            Text(commande.dateCommande?.formatted(date: .numeric, time: .omitted) ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        if let lignesCommande = commande.lignesCommande?.allObjects as? [LigneCommande] {
                            Text("\(lignesCommande.count) produit(s)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            // Afficher les 2 premiers produits
                            ForEach(lignesCommande.prefix(2), id: \.self) { ligne in
                                if let produit = ligne.produit {
                                    Text("• \(produit.nom ?? ""): \(ligne.quantite) unités")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            // Si plus de 2 produits, afficher "et X autres..."
                            if lignesCommande.count > 2 {
                                Text("et \(lignesCommande.count - 2) autre(s)...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Historique des Achats")
        .overlay {
            if commandesLivrees.isEmpty {
                ContentUnavailableView(
                    "Aucune commande livrée",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Les commandes livrées apparaîtront ici")
                )
            }
        }
    }
} 