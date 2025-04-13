import SwiftUI

struct FournisseurDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var fournisseur: Fournisseur
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    
    private let statusOptions = ["Actif", "Inactif"]
    
    var body: some View {
        Form {
            Section(header: Text("Informations générales")) {
                if isEditing {
                    TextField("Nom", text: $fournisseur.wrappedNom)
                        .onChange(of: fournisseur.wrappedNom) { _ in
                            saveChanges()
                        }
                    TextField("Contact", text: $fournisseur.wrappedContact)
                        .onChange(of: fournisseur.wrappedContact) { _ in
                            saveChanges()
                        }
                    Picker("Statut", selection: $fournisseur.wrappedStatut) {
                        ForEach(statusOptions, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    .onChange(of: fournisseur.wrappedStatut) { _ in
                        saveChanges()
                    }
                } else {
                    LabeledContent("Nom", value: fournisseur.wrappedNom)
                    LabeledContent("Contact", value: fournisseur.wrappedContact)
                    LabeledContent("Statut", value: fournisseur.wrappedStatut)
                }
            }
            
            Section(header: Text("Coordonnées")) {
                if isEditing {
                    TextField("Email", text: $fournisseur.wrappedEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .onChange(of: fournisseur.wrappedEmail) { _ in
                            saveChanges()
                        }
                    TextField("Téléphone", text: $fournisseur.wrappedTelephone)
                        .keyboardType(.phonePad)
                        .onChange(of: fournisseur.wrappedTelephone) { _ in
                            saveChanges()
                        }
                    TextField("Site Web", text: $fournisseur.wrappedSiteWeb)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .onChange(of: fournisseur.wrappedSiteWeb) { _ in
                            saveChanges()
                        }
                } else {
                    LabeledContent("Email", value: fournisseur.wrappedEmail)
                    LabeledContent("Téléphone", value: fournisseur.wrappedTelephone)
                    if !fournisseur.wrappedSiteWeb.isEmpty {
                        Link("Site Web", destination: URL(string: fournisseur.wrappedSiteWeb) ?? URL(string: "https://")!)
                    }
                }
            }
            
            Section(header: Text("Catégorie")) {
                if isEditing {
                    TextField("Catégorie", text: $fournisseur.wrappedCategorie)
                        .onChange(of: fournisseur.wrappedCategorie) { _ in
                            saveChanges()
                        }
                } else {
                    LabeledContent("Catégorie", value: fournisseur.wrappedCategorie)
                }
            }
            
            if !isEditing {
                Section(header: Text("Informations système")) {
                    LabeledContent("Date de création", value: fournisseur.wrappedDateCreation.formatted(.dateTime))
                }
            }
        }
        .navigationTitle(fournisseur.wrappedNom)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        isEditing.toggle()
                    }
                } label: {
                    Text(isEditing ? "Terminer" : "Modifier")
                }
            }
        }
    }
    
    private func saveChanges() {
        withAnimation {
            do {
                try viewContext.save()
            } catch {
                print("Erreur lors de la sauvegarde : \(error)")
            }
        }
    }
} 