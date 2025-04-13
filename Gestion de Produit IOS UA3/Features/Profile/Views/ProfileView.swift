import SwiftUI
import CoreData

struct ProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var authService: AuthService
    
    @State private var isEditing = false
    @State private var nom = ""
    @State private var email = ""
    @State private var role = ""
    @State private var statut = ""
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Profil")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("INFORMATIONS PERSONNELLES")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 15) {
                    if isEditing {
                        // Mode édition
                        TextField("Nom", text: $nom)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        Picker("Rôle", selection: $role) {
                            Text("Magasinier").tag("Magasinier")
                            Text("Gestionnaire de Stock").tag("Gestionnaire de Stock")
                            Text("Responsable Achats").tag("Responsable Achats")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal)
                        
                        Picker("Statut", selection: $statut) {
                            Text("Actif").tag("Actif")
                            Text("Inactif").tag("Inactif")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal)
                    } else {
                        // Mode affichage
                        InfoRow(label: "Nom", value: authService.currentUser?.wrappedNom ?? "")
                        InfoRow(label: "Email", value: authService.currentUser?.wrappedEmail ?? "")
                        InfoRow(label: "Rôle", value: authService.currentUser?.wrappedRole ?? "")
                        InfoRow(label: "Statut", value: authService.currentUser?.wrappedStatut ?? "")
                        InfoRow(label: "Date d'inscription", value: formatDate(authService.currentUser?.dateCreation))
                        InfoRow(label: "Dernière connexion", value: formatDate(authService.currentUser?.derniereConnexion))
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5)
            }
            
            if isEditing {
                HStack {
                    Button(action: {
                        isEditing = false
                    }) {
                        Text("Annuler")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                    
                    Button(action: saveChanges) {
                        Text("Enregistrer")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            } else {
                Button(action: {
                    // Initialiser les champs avec les valeurs actuelles
                    nom = authService.currentUser?.wrappedNom ?? ""
                    email = authService.currentUser?.wrappedEmail ?? ""
                    role = authService.currentUser?.wrappedRole ?? "Magasinier"
                    statut = authService.currentUser?.wrappedStatut ?? "Actif"
                    isEditing = true
                }) {
                    Label("Modifier le profil", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                authService.logout()
            }) {
                HStack {
                    Text("Se déconnecter")
                        .foregroundColor(.red)
                    Spacer()
                    Image(systemName: "arrow.right.square")
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .background(Color(.systemGray6))
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func saveChanges() {
        // Vérifier si l'email est déjà utilisé par un autre utilisateur
        let request: NSFetchRequest<Utilisateur> = Utilisateur.fetchRequest()
        if let userId = authService.currentUser?.id {
            request.predicate = NSPredicate(format: "email == %@ AND id != %@", email, userId as CVarArg)
        } else {
            request.predicate = NSPredicate(format: "email == %@", email)
        }
        
        do {
            let existingUsers = try viewContext.fetch(request)
            if !existingUsers.isEmpty {
                alertTitle = "Erreur"
                alertMessage = "Cet email est déjà utilisé par un autre utilisateur"
                showingAlert = true
                return
            }
            
            // Mettre à jour les informations de l'utilisateur
            if let user = authService.currentUser {
                user.nom = nom
                user.email = email
                user.role = role
                user.statut = statut
                
                try viewContext.save()
                
                alertTitle = "Succès"
                alertMessage = "Vos informations ont été mises à jour"
                showingAlert = true
                isEditing = false
            }
        } catch {
            alertTitle = "Erreur"
            alertMessage = "Une erreur est survenue lors de la mise à jour : \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Non disponible" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthService(context: PersistenceController.preview.container.viewContext))
    }
} 