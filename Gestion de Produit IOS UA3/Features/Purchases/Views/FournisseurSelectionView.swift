import SwiftUI
import CoreData

struct FournisseurSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedFournisseur: Fournisseur?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Fournisseur.nom, ascending: true)],
        predicate: NSPredicate(format: "statut != %@", "INACTIF"),
        animation: .default)
    private var fournisseurs: FetchedResults<Fournisseur>
    
    var body: some View {
        List(fournisseurs, id: \.self) { fournisseur in
            Button(action: {
                selectedFournisseur = fournisseur
                dismiss()
            }) {
                VStack(alignment: .leading) {
                    Text(fournisseur.nom ?? "Sans nom")
                        .font(.headline)
                    if let categorie = fournisseur.categorie {
                        Text(categorie)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .foregroundColor(.primary)
        }
        .navigationTitle("Sélectionner un fournisseur")
    }
} 