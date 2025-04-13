import SwiftUI
import CoreData

struct NouveauMouvementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Produit.nom, ascending: true)],
        animation: .default)
    private var produits: FetchedResults<Produit>
    
    @State private var quantite = ""
    @State private var motif = ""
    @State private var isEntree = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // État local pour le produit sélectionné, initialisé avec le paramètre
    @State private var selectedProduit: Produit?
    
    // Initialisation avec un produit optionnel
    init(selectedProduit: Produit? = nil) {
        _selectedProduit = State(initialValue: selectedProduit)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Produit
                VStack(alignment: .leading, spacing: 8) {
                    Text("Produit")
                        .foregroundColor(.secondary)
                    Menu {
                        ForEach(produits) { produit in
                            Button(action: {
                                selectedProduit = produit
                            }) {
                                Text("\(produit.wrappedNom) (Stock actuel: \(produit.quantiteEnStock))")
                            }
                        }
                    } label: {
                        HStack {
                            if let produit = selectedProduit {
                                Text("\(produit.wrappedNom) (Stock actuel: \(produit.quantiteEnStock))")
                            } else {
                                Text("Sélectionner un produit")
                            }
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                
                // Type de mouvement
                VStack(alignment: .leading, spacing: 8) {
                    Text("Type de mouvement")
                        .foregroundColor(.secondary)
                    HStack(spacing: 20) {
                        HStack {
                            Circle()
                                .stroke(isEntree ? Color.gray : Color.gray, lineWidth: 1)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .fill(isEntree ? Color.blue : Color.clear)
                                        .frame(width: 12, height: 12)
                                )
                            Text("Entrée")
                        }
                        .onTapGesture {
                            isEntree = true
                        }
                        
                        HStack {
                            Circle()
                                .stroke(!isEntree ? Color.gray : Color.gray, lineWidth: 1)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle()
                                        .fill(!isEntree ? Color.orange : Color.clear)
                                        .frame(width: 12, height: 12)
                                )
                            Text("Sortie")
                        }
                        .onTapGesture {
                            isEntree = false
                        }
                    }
                }
                
                // Quantité
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantité")
                        .foregroundColor(.secondary)
                    TextField("", text: $quantite)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                // Motif
                VStack(alignment: .leading, spacing: 8) {
                    Text("Motif")
                        .foregroundColor(.secondary)
                    TextEditor(text: $motif)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange, lineWidth: 1)
                        )
                }
                
                Spacer()
                
                // Boutons
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Annuler")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        sauvegarderMouvement()
                    }) {
                        Text("Confirmer")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .navigationTitle("Nouveau Mouvement de Stock")
            .navigationBarTitleDisplayMode(.inline)
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func sauvegarderMouvement() {
        // Validation du produit
        guard let produit = selectedProduit else {
            alertTitle = "Erreur"
            alertMessage = "Veuillez sélectionner un produit"
            showAlert = true
            return
        }
        
        // Validation de la quantité
        guard let quantiteNombre = Int32(quantite), quantiteNombre > 0 else {
            alertTitle = "Erreur"
            alertMessage = "La quantité doit être un nombre positif"
            showAlert = true
            return
        }
        
        // Validation du motif
        guard !motif.isEmpty else {
            alertTitle = "Erreur"
            alertMessage = "Veuillez saisir un motif"
            showAlert = true
            return
        }
        
        // Gestion du stock
        if isEntree {
            // Entrée de stock
            let ancienStock = produit.quantiteEnStock
            produit.quantiteEnStock += quantiteNombre
            
            do {
                try viewContext.save()
                alertTitle = "Succès"
                alertMessage = "Entrée de \(quantiteNombre) unités enregistrée. Nouveau stock : \(produit.quantiteEnStock)"
                showAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } catch {
                // En cas d'erreur, on revient à l'ancien stock
                produit.quantiteEnStock = ancienStock
                alertTitle = "Erreur"
                alertMessage = "Erreur lors de la sauvegarde: \(error.localizedDescription)"
                showAlert = true
            }
        } else {
            // Sortie de stock
            if produit.quantiteEnStock >= quantiteNombre {
                let ancienStock = produit.quantiteEnStock
                produit.quantiteEnStock -= quantiteNombre
                
                do {
                    try viewContext.save()
                    alertTitle = "Succès"
                    alertMessage = "Sortie de \(quantiteNombre) unités enregistrée. Nouveau stock : \(produit.quantiteEnStock)"
                    showAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                } catch {
                    // En cas d'erreur, on revient à l'ancien stock
                    produit.quantiteEnStock = ancienStock
                    alertTitle = "Erreur"
                    alertMessage = "Erreur lors de la sauvegarde: \(error.localizedDescription)"
                    showAlert = true
                }
            } else {
                alertTitle = "Stock insuffisant"
                alertMessage = "Stock actuel (\(produit.quantiteEnStock)) insuffisant pour une sortie de \(quantiteNombre) unités"
                showAlert = true
            }
        }
    }
} 