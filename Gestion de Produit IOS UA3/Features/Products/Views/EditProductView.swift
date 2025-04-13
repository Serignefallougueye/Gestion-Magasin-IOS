import SwiftUI
import CoreData

struct EditProductView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    let produit: Produit
    
    @State private var nom: String
    @State private var prix: Double
    @State private var quantiteEnStock: Int32
    @State private var seuilAlerte: Int32
    @State private var emplacement: String
    @State private var selectedCategorie: Categorie?
    @State private var showError = false
    @State private var errorMessage = ""
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Categorie.nom, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Categorie>
    
    init(produit: Produit) {
        self.produit = produit
        _nom = State(initialValue: produit.wrappedNom)
        _prix = State(initialValue: produit.prix)
        _quantiteEnStock = State(initialValue: produit.quantiteEnStock)
        _seuilAlerte = State(initialValue: produit.seuilAlerte)
        _emplacement = State(initialValue: "Rayon X") // À remplacer par l'emplacement réel
        _selectedCategorie = State(initialValue: produit.categorie)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations générales")) {
                    TextField("Nom du produit", text: $nom)
                    
                    HStack {
                        Text("Prix")
                        Spacer()
                        TextField("0.00", value: $prix, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Gestion du stock")) {
                    Stepper("Quantité en stock: \(quantiteEnStock)", value: $quantiteEnStock, in: 0...1000)
                    Stepper("Seuil d'alerte: \(seuilAlerte)", value: $seuilAlerte, in: 0...100)
                    TextField("Emplacement", text: $emplacement)
                }
                
                Section(header: Text("Catégorie")) {
                    Picker("Sélectionner une catégorie", selection: $selectedCategorie) {
                        Text("Aucune catégorie")
                            .tag(Optional<Categorie>.none)
                        ForEach(categories) { categorie in
                            Text(categorie.wrappedNom)
                                .tag(Optional(categorie))
                        }
                    }
                }
            }
            .navigationTitle("Modifier le Produit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        updateProduit()
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
    
    private func updateProduit() {
        guard !nom.isEmpty else {
            showError = true
            errorMessage = "Le nom du produit est requis"
            return
        }
        
        produit.nom = nom
        produit.prix = prix
        produit.quantiteEnStock = quantiteEnStock
        produit.seuilAlerte = seuilAlerte
        produit.categorie = selectedCategorie
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            showError = true
            errorMessage = "Erreur lors de la sauvegarde: \(error.localizedDescription)"
        }
    }
}

struct EditProductView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let produit = Produit.create(
            in: context,
            nom: "Produit Test",
            prix: 19.99,
            quantiteEnStock: 10,
            seuilAlerte: 5,
            categorie: Categorie.create(in: context, nom: "Test")
        )
        
        return EditProductView(produit: produit)
            .environment(\.managedObjectContext, context)
    }
} 