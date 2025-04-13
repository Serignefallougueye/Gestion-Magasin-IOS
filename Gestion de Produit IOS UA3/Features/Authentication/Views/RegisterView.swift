import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var nom = ""
    @State private var role = "Magasinier"
    @State private var showError = false
    @State private var errorMessage = ""
    
    let roles = ["Magasinier", "Gestionnaire de Stock", "Responsable Achats"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations de connexion")) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Mot de passe", text: $password)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirmer le mot de passe", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
                
                Section(header: Text("Informations personnelles")) {
                    TextField("Nom", text: $nom)
                        .textContentType(.name)
                    
                    Picker("Rôle", selection: $role) {
                        ForEach(roles, id: \.self) { role in
                            Text(role).tag(role)
                        }
                    }
                }
                
                Section {
                    Button(action: register) {
                        HStack {
                            Spacer()
                            Text("S'inscrire")
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Inscription")
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func register() {
        // Validation des champs
        guard !email.isEmpty && email.contains("@") else {
            errorMessage = "Veuillez entrer une adresse email valide"
            showError = true
            return
        }
        
        guard !nom.isEmpty else {
            errorMessage = "Veuillez entrer votre nom"
            showError = true
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Veuillez entrer un mot de passe"
            showError = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Les mots de passe ne correspondent pas"
            showError = true
            return
        }
        
        // Tentative d'inscription
        if authService.register(email: email, password: password, nom: nom, role: role) {
            presentationMode.wrappedValue.dismiss()
        } else {
            errorMessage = "Cet email est déjà utilisé"
            showError = true
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthService(context: PersistenceController.preview.container.viewContext))
    }
} 