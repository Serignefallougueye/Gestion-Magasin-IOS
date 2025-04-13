import SwiftUI
import CoreData

struct ProductSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @Binding var selectedProducts: Set<Produit>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Produit.nom, ascending: true)],
        animation: .default)
    private var produits: FetchedResults<Produit>
    
    var filteredProduits: [Produit] {
        if searchText.isEmpty {
            return Array(produits)
        } else {
            return produits.filter { produit in
                (produit.nom ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredProduits, id: \.self) { produit in
                HStack {
                    VStack(alignment: .leading) {
                        Text(produit.nom ?? "Sans nom")
                            .font(.headline)
                        Text("En stock: \(produit.quantiteEnStock)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if selectedProducts.contains(produit) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedProducts.contains(produit) {
                        selectedProducts.remove(produit)
                    } else {
                        selectedProducts.insert(produit)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Rechercher un produit")
        .navigationTitle("Ajouter des produits")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Terminé") {
                    dismiss()
                }
            }
        }
    }
} 