import SwiftUI
import CoreData

struct NewPurchaseOrderView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedFournisseur: Fournisseur?
    @State private var dateCommande = Date()
    @State private var notes = ""
    @State private var selectedProducts = Set<Produit>()
    @State private var productQuantities: [Produit: Int] = [:]
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("INFORMATIONS GÉNÉRALES")) {
                NavigationLink(destination: FournisseurSelectionView(selectedFournisseur: $selectedFournisseur)) {
                    HStack {
                        Text("Fournisseur")
                        Spacer()
                        if let fournisseur = selectedFournisseur {
                            Text(fournisseur.nom ?? "")
                                .foregroundColor(.gray)
                        } else {
                            Text("Sélectionner")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                DatePicker("Date de commande",
                          selection: $dateCommande,
                          displayedComponents: .date)
                
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section(header: Text("PRODUITS")) {
                NavigationLink(destination: ProductSelectionView(selectedProducts: $selectedProducts)) {
                    HStack {
                        Text("Ajouter des produits")
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                    }
                }
                
                ForEach(Array(selectedProducts), id: \.self) { produit in
                    HStack(alignment: .center, spacing: 12) {
                        // Informations du produit
                        VStack(alignment: .leading) {
                            Text(produit.nom ?? "Sans nom")
                                .font(.headline)
                            Text("En stock: \(produit.quantiteEnStock)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Contrôles de quantité
                        HStack(spacing: 15) {
                            Button {
                                if productQuantities[produit, default: 1] > 1 {
                                    productQuantities[produit] = productQuantities[produit, default: 1] - 1
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.borderless)
                            
                            Text("\(productQuantities[produit, default: 1])")
                                .frame(minWidth: 30)
                                .font(.headline)
                            
                            Button {
                                productQuantities[produit] = (productQuantities[produit, default: 1] + 1)
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
                .onDelete { indexSet in
                    let productsToRemove = indexSet.map { Array(selectedProducts)[$0] }
                    for product in productsToRemove {
                        selectedProducts.remove(product)
                        productQuantities.removeValue(forKey: product)
                    }
                }
            }
            
            Section {
                Button("Créer la commande") {
                    createOrder()
                }
                .disabled(selectedFournisseur == nil || selectedProducts.isEmpty)
            }
        }
        .navigationTitle("Nouvelle Commande")
        .navigationBarTitleDisplayMode(.large)
        .alert("Attention", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func createOrder() {
        let newOrder = CommandeAchat(context: viewContext)
        newOrder.id = UUID()
        newOrder.dateCommande = dateCommande
        newOrder.notes = notes.isEmpty ? nil : notes
        newOrder.statut = "EN_ATTENTE"
        newOrder.fournisseur = selectedFournisseur
        
        // Créer les lignes de commande
        for produit in selectedProducts {
            let quantity = productQuantities[produit, default: 1]
            
            let ligneCommande = LigneCommande(context: viewContext)
            ligneCommande.id = UUID()
            ligneCommande.quantite = Int32(quantity)
            ligneCommande.produit = produit
            ligneCommande.commande = newOrder
            
            // Mettre à jour le stock
            produit.quantiteEnStock += Int32(quantity)
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            alertMessage = "Erreur lors de la création de la commande: \(error.localizedDescription)"
            showingAlert = true
        }
    }
} 
