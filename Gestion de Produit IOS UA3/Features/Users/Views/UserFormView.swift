import SwiftUI
import CoreData

struct UserFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let utilisateur: Utilisateur?
    let isEditing: Bool
    
    @State private var email = ""
    @State private var nom = ""
    @State private var role = "Magasinier"
    @State private var statut = "Actif"
    @State private var motDePasse = ""
    @State private var confirmationMotDePasse = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let roles = ["Magasinier", "Gestionnaire de Stock", "Responsable Achats"]
    let statuts = ["Actif", "Inactif"]
    
    init(utilisateur: Utilisateur? = nil) {
        self.utilisateur = utilisateur
        self.isEditing = utilisateur != nil
        
        if let utilisateur = utilisateur {
            _email = State(initialValue: utilisateur.wrappedEmail)
            _nom = State(initialValue: utilisateur.wrappedNom)
            _role = State(initialValue: utilisateur.wrappedRole)
            _statut = State(initialValue: utilisateur.wrappedStatut)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations de l'utilisateur")) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    TextField("Nom", text: $nom)
                        .textContentType(.name)
                    
                    Picker("Rôle", selection: $role) {
                        ForEach(roles, id: \.self) { role in
                            Text(role).tag(role)
                        }
                    }
                    
                    Picker("Statut", selection: $statut) {
                        ForEach(statuts, id: \.self) { statut in
                            Text(statut).tag(statut)
                        }
                    }
                }
                
                if !isEditing {
                    Section(header: Text("Mot de passe")) {
                        SecureField("Mot de passe", text: $motDePasse)
                            .textContentType(.newPassword)
                        
                        SecureField("Confirmer le mot de passe", text: $confirmationMotDePasse)
                            .textContentType(.newPassword)
                    }
                }
            }
            .navigationTitle(isEditing ? "Modifier l'utilisateur" : "Nouvel utilisateur")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Enregistrer" : "Ajouter") {
                        saveUser()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert("Erreur", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        let emailIsValid = email.contains("@") && email.contains(".")
        let nomIsValid = !nom.isEmpty
        let passwordsMatch = isEditing || (motDePasse == confirmationMotDePasse && !motDePasse.isEmpty)
        
        return emailIsValid && nomIsValid && passwordsMatch
    }
    
    private func saveUser() {
        // Vérifier si l'email existe déjà
        let fetchRequest = NSFetchRequest<Utilisateur>(entityName: "Utilisateur")
        fetchRequest.predicate = NSPredicate(format: "email == %@ AND id != %@", 
                                           email,
                                           utilisateur?.id as CVarArg? ?? NSNull())
        
        do {
            let existingUsers = try viewContext.fetch(fetchRequest)
            if !existingUsers.isEmpty {
                alertMessage = "Un utilisateur avec cet email existe déjà."
                showAlert = true
                return
            }
            
            let user: Utilisateur
            if let existingUser = utilisateur {
                user = existingUser
            } else {
                user = Utilisateur(context: viewContext)
                user.dateCreation = Date()
            }
            
            user.email = email
            user.nom = nom
            user.role = role
            user.statut = statut
            
            if !isEditing {
                user.motDePasse = hashPassword(motDePasse)
            }
            
            try viewContext.save()
            dismiss()
            
        } catch {
            alertMessage = "Erreur lors de la sauvegarde : \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func hashPassword(_ password: String) -> String {
        // TODO: Implémenter un vrai hachage de mot de passe
        // Pour l'instant, on retourne simplement le mot de passe
        return password
    }
}

struct UserFormView_Previews: PreviewProvider {
    static var previews: some View {
        UserFormView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 