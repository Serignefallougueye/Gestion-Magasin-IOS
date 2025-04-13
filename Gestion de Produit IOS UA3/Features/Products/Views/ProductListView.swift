import SwiftUI
import CoreData

struct ProductListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Produit.nom, ascending: true)],
        animation: .default)
    private var produits: FetchedResults<Produit>
    
    @State private var searchText = ""
    @State private var showAddProduct = false
    @State private var showEditProduct = false
    @State private var showDeleteConfirmation = false
    @State private var productToDelete: Produit?
    @State private var productToEdit: Produit?
    
    var filteredProduits: [Produit] {
        if searchText.isEmpty {
            return Array(produits)
        }
        return produits.filter { produit in
            produit.wrappedNom.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                // Barre de recherche
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher des produits...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Liste des produits
                List {
                    ForEach(filteredProduits) { produit in
                        ProductRow(
                            produit: produit,
                            onEdit: {
                                productToEdit = produit
                                showEditProduct = true
                            },
                            onDelete: {
                                productToDelete = produit
                                showDeleteConfirmation = true
                            }
                        )
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Produits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddProduct = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button(role: .destructive, action: {
                            // Action pour supprimer tous les produits
                        }) {
                            Label("Supprimer Tout", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddProduct) {
            AddProductView()
        }
        .sheet(item: $productToEdit) { produit in
            EditProductView(produit: produit)
        }
        .alert("Confirmer la suppression", isPresented: $showDeleteConfirmation) {
            Button("Supprimer", role: .destructive) {
                if let produit = productToDelete {
                    viewContext.delete(produit)
                    try? viewContext.save()
                }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Voulez-vous vraiment supprimer ce produit ?")
        }
    }
}

struct ProductRow: View {
    let produit: Produit
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "cube.fill")
                    .foregroundColor(.blue)
                Text(produit.wrappedNom)
                    .font(.headline)
                Spacer()
                Menu {
                    Button(action: onEdit) {
                        Label("Modifier", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label("Supprimer", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(produit.categorie?.wrappedNom ?? "Sans catégorie")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Rayon X")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(format: "$%.2f", produit.prix))
                        .font(.subheadline)
                        .bold()
                    
                    HStack {
                        Text("Stock: \(produit.quantiteEnStock)")
                            .font(.caption)
                        if produit.quantiteEnStock <= produit.seuilAlerte {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 