import SwiftUI
import CoreData

struct InventoryListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var searchText = ""
    @State private var showingNewMouvement = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Produit.nom, ascending: true)],
        animation: .default)
    private var produits: FetchedResults<Produit>
    
    var filteredProduits: [Produit] {
        if searchText.isEmpty {
            return Array(produits)
        } else {
            return produits.filter { produit in
                produit.wrappedNom.localizedCaseInsensitiveContains(searchText) ||
                (produit.categorie?.wrappedNom ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Barre de recherche
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher des produits...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // En-têtes des colonnes
                HStack(spacing: 12) {
                    Text("Produit")
                        .frame(width: UIScreen.main.bounds.width * 0.35, alignment: .leading)
                    Text("Catégorie")
                        .frame(width: UIScreen.main.bounds.width * 0.35, alignment: .leading)
                    Text("Stock")
                        .frame(width: UIScreen.main.bounds.width * 0.2, alignment: .trailing)
                }
                .font(.subheadline.bold())
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                
                if filteredProduits.isEmpty {
                    ContentUnavailableView("Aucun produit",
                        systemImage: "box.fill",
                        description: Text("Ajoutez des produits pour gérer votre inventaire"))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredProduits) { produit in
                                Button(action: {
                                    selectedProduit = produit
                                    showingNewMouvement = true
                                }) {
                                    InventoryRowView(produit: produit)
                                }
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Gestion des Stocks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        selectedProduit = nil
                        showingNewMouvement = true 
                    }) {
                        Text("+ Nouveau")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                }
            }
            .sheet(isPresented: $showingNewMouvement) {
                NouveauMouvementView(selectedProduit: selectedProduit)
            }
        }
    }
    
    @State private var selectedProduit: Produit?
}

struct InventoryRowView: View {
    let produit: Produit
    
    var stockStatus: Color {
        if produit.quantiteEnStock <= 0 {
            return .red
        } else if produit.quantiteEnStock <= produit.seuilAlerte {
            return .orange
        } else {
            return .green
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Produit
            HStack(spacing: 8) {
                Image(systemName: "cube.box.fill")
                    .foregroundColor(.gray)
                Text(produit.wrappedNom)
                    .lineLimit(1)
            }
            .frame(width: UIScreen.main.bounds.width * 0.35, alignment: .leading)
            
            // Catégorie
            Text(produit.categorie?.wrappedNom ?? "Sans catégorie")
                .lineLimit(1)
                .frame(width: UIScreen.main.bounds.width * 0.35, alignment: .leading)
                .foregroundColor(.secondary)
            
            // Stock
            Text("\(produit.quantiteEnStock)")
                .frame(width: UIScreen.main.bounds.width * 0.2, alignment: .trailing)
                .foregroundColor(stockStatus)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .background(Color.white)
    }
}
