import SwiftUI
import CoreData

struct AddProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @State private var nom = ""
    @State private var prix: Double = 0.0
    @State private var quantiteEnStock: Int32 = 0
    @State private var seuilAlerte: Int32 = 5
    @State private var emplacement = ""
    @State private var categorieName = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("INFORMATIONS GÉNÉRALES")) {
                    TextField("Nom du produit", text: $nom)

                    HStack {
                        Text("Prix")
                        Spacer()
                        TextField("0.00", value: $prix, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section(header: Text("GESTION DU STOCK")) {
                    Group {
                        HStack {
                            Text("Quantité en stock")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(quantiteEnStock)")
                                .foregroundColor(.primary)
                            HStack(spacing: 12) {
                                Button(action: { if quantiteEnStock > 0 { quantiteEnStock -= 1 } }) {
                                    Image(systemName: "minus")
                                        .frame(width: 30, height: 30)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Button(action: { quantiteEnStock += 1 }) {
                                    Image(systemName: "plus")
                                        .frame(width: 30, height: 30)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal)
                        .padding(.vertical, 8)

                        HStack {
                            Text("Seuil d'alerte")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(seuilAlerte)")
                                .foregroundColor(.primary)
                            HStack(spacing: 12) {
                                Button(action: { if seuilAlerte > 0 { seuilAlerte -= 1 } }) {
                                    Image(systemName: "minus")
                                        .frame(width: 30, height: 30)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                
                                Button(action: { seuilAlerte += 1 }) {
                                    Image(systemName: "plus")
                                        .frame(width: 30, height: 30)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal)
                        .padding(.vertical, 8)

                        TextField("Emplacement", text: $emplacement)
                            .padding(.vertical, 8)
                    }
                }

                Section(header: Text("CATÉGORIE")) {
                    TextField("Saisir une catégorie", text: $categorieName)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Nouveau Produit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        saveProduit()
                    }
                    .disabled(nom.isEmpty)
                }
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func saveProduit() {
        guard !nom.isEmpty else {
            showError = true
            errorMessage = "Le nom du produit est requis"
            return
        }

        let fetchRequest: NSFetchRequest<Categorie> = Categorie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nom == %@", categorieName)

        var categorie: Categorie

        do {
            let results = try viewContext.fetch(fetchRequest)
            if let existingCategorie = results.first {
                categorie = existingCategorie
            } else {
                categorie = Categorie.create(in: viewContext, nom: categorieName)
            }

            let nouveauProduit = Produit.create(
                in: viewContext,
                nom: nom,
                prix: prix,
                quantiteEnStock: quantiteEnStock,
                seuilAlerte: seuilAlerte,
                categorie: categorie
            )

            try viewContext.save()
            dismiss()
        } catch {
            showError = true
            errorMessage = "Erreur lors de la sauvegarde: \(error.localizedDescription)"
        }
    }
}

struct AddProductView_Previews: PreviewProvider {
    static var previews: some View {
        AddProductView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
