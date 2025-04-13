import SwiftUI

struct AddFournisseurView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var nom = ""
    @State private var contact = ""
    @State private var email = ""
    @State private var telephone = ""
    @State private var siteWeb = ""
    @State private var categorie = ""
    @State private var statut = "Actif"
    
    private let statusOptions = ["Actif", "Inactif"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations générales")) {
                    TextField("Nom", text: $nom)
                    TextField("Contact", text: $contact)
                    Picker("Statut", selection: $statut) {
                        ForEach(statusOptions, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                }
                
                Section(header: Text("Coordonnées")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Téléphone", text: $telephone)
                        .keyboardType(.phonePad)
                    TextField("Site Web", text: $siteWeb)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Catégorie")) {
                    TextField("Catégorie", text: $categorie)
                }
            }
            .navigationTitle("Nouveau Fournisseur")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        addFournisseur()
                    }
                    .disabled(nom.isEmpty || contact.isEmpty)
                }
            }
        }
    }
    
    private func addFournisseur() {
        withAnimation {
            _ = Fournisseur.create(
                in: viewContext,
                nom: nom,
                contact: contact,
                email: email,
                telephone: telephone,
                siteWeb: siteWeb,
                categorie: categorie,
                statut: statut
            )
            
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Erreur lors de la création : \(error)")
            }
        }
    }
} 