import SwiftUI
import CoreData

struct PurchaseOrderDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var commande: CommandeAchat
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let statutOptions = ["EN_ATTENTE", "EN_COURS", "LIVREE", "ANNULEE"]
    
    var body: some View {
        Form {
            Section(header: Text("INFORMATIONS GÉNÉRALES")) {
                if isEditing {
                    DatePicker("Date de commande",
                             selection: Binding(
                                get: { commande.dateCommande ?? Date() },
                                set: { commande.dateCommande = $0 }
                             ),
                             displayedComponents: .date)
                    
                    Picker("Statut", selection: Binding(
                        get: { commande.statut ?? "EN_ATTENTE" },
                        set: { newStatus in
                            let oldStatus = commande.statut
                            commande.statut = newStatus
                            
                            // Si on passe au statut LIVREE
                            if newStatus == "LIVREE" && oldStatus != "LIVREE" {
                                updateStock(increment: true)
                            }
                            // Si on annule le statut LIVREE
                            else if oldStatus == "LIVREE" && newStatus != "LIVREE" {
                                updateStock(increment: false)
                            }
                        }
                    )) {
                        ForEach(statutOptions, id: \.self) { statut in
                            Text(statut).tag(statut)
                        }
                    }
                    
                    TextField("Notes", text: Binding(
                        get: { commande.notes ?? "" },
                        set: { commande.notes = $0 }
                    ))
                } else {
                    LabeledContent("Date", value: commande.dateCommande?.formatted(date: .long, time: .omitted) ?? "Non définie")
                    LabeledContent("Statut", value: commande.statut ?? "Non défini")
                    if let notes = commande.notes, !notes.isEmpty {
                        Text("Notes: \(notes)")
                    }
                }
            }
            
            Section(header: Text("FOURNISSEUR")) {
                if let fournisseur = commande.fournisseur {
                    LabeledContent("Entreprise", value: fournisseur.nom ?? "Non défini")
                    if let contact = fournisseur.contact {
                        LabeledContent("Contact", value: contact)
                    }
                    if let email = fournisseur.email {
                        LabeledContent("Email", value: email)
                    }
                    if let telephone = fournisseur.telephone {
                        LabeledContent("Téléphone", value: telephone)
                    }
                } else {
                    Text("Aucun fournisseur associé")
                }
            }
            
            Section(header: Text("PRODUITS COMMANDÉS")) {
                if let lignesCommande = commande.lignesCommande?.allObjects as? [LigneCommande],
                   !lignesCommande.isEmpty {
                    ForEach(lignesCommande, id: \.self) { ligne in
                        if let produit = ligne.produit {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(produit.nom ?? "Sans nom")
                                        .font(.headline)
                                    Text("Quantité: \(ligne.quantite)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else {
                    Text("Aucun produit dans la commande")
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Détails de la commande")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Enregistrer" : "Modifier") {
                    if isEditing {
                        do {
                            try viewContext.save()
                        } catch {
                            alertMessage = "Erreur lors de la sauvegarde: \(error.localizedDescription)"
                            showingAlert = true
                        }
                    }
                    isEditing.toggle()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Erreur", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("Supprimer la commande", isPresented: $showingDeleteAlert) {
            Button("Supprimer", role: .destructive) {
                // Si la commande était LIVREE, on annule la mise à jour du stock
                if commande.statut == "LIVREE" {
                    updateStock(increment: false)
                }
                deleteCommande()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Êtes-vous sûr de vouloir supprimer cette commande ?")
        }
    }
    
    private func updateStock(increment: Bool) {
        if let lignesCommande = commande.lignesCommande?.allObjects as? [LigneCommande] {
            for ligne in lignesCommande {
                if let produit = ligne.produit {
                    if increment {
                        produit.quantiteEnStock += ligne.quantite
                    } else {
                        produit.quantiteEnStock -= ligne.quantite
                    }
                }
            }
            
            do {
                try viewContext.save()
            } catch {
                alertMessage = "Erreur lors de la mise à jour du stock: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    private func deleteCommande() {
        viewContext.delete(commande)
        do {
            try viewContext.save()
        } catch {
            alertMessage = "Erreur lors de la suppression: \(error.localizedDescription)"
            showingAlert = true
        }
    }
} 