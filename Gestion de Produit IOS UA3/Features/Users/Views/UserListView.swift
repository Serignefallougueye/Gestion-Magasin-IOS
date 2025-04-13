import SwiftUI
import CoreData

struct UserListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Utilisateur.dateCreation, ascending: false)],
        animation: .default)
    private var utilisateurs: FetchedResults<Utilisateur>
    
    @State private var searchText = ""
    @State private var showAddUser = false
    @State private var showEditUser = false
    @State private var showDeleteConfirmation = false
    @State private var userToDelete: Utilisateur?
    @State private var userToEdit: Utilisateur?
    @State private var selectedRole = "Tous les rôles"
    @State private var selectedStatus = "Tous les statuts"
    
    let roles = ["Tous les rôles", "Magasinier", "Gestionnaire de Stock", "Responsable Achats"]
    let statuts = ["Tous les statuts", "Actif", "Inactif"]
    
    var filteredUtilisateurs: [Utilisateur] {
        let array = Array(utilisateurs)
        return array.filter { utilisateur in
            let matchesSearch = searchText.isEmpty || 
                utilisateur.wrappedEmail.localizedCaseInsensitiveContains(searchText) ||
                utilisateur.wrappedNom.localizedCaseInsensitiveContains(searchText)
            
            let matchesRole = selectedRole == "Tous les rôles" || 
                utilisateur.wrappedRole == selectedRole
            
            let matchesStatus = selectedStatus == "Tous les statuts" || 
                utilisateur.wrappedStatut == selectedStatus
            
            return matchesSearch && matchesRole && matchesStatus
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Barre de recherche
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Filtres
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Menu {
                            ForEach(roles, id: \.self) { role in
                                Button(role) {
                                    selectedRole = role
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedRole)
                                Image(systemName: "chevron.down")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        }
                        
                        Menu {
                            ForEach(statuts, id: \.self) { statut in
                                Button(statut) {
                                    selectedStatus = statut
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedStatus)
                                Image(systemName: "chevron.down")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Liste des utilisateurs
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredUtilisateurs, id: \.wrappedId) { utilisateur in
                            UserCard(
                                utilisateur: utilisateur,
                                onEdit: {
                                    userToEdit = utilisateur
                                    showEditUser = true
                                },
                                onDelete: {
                                    userToDelete = utilisateur
                                    showDeleteConfirmation = true
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Utilisateurs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddUser = true }) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddUser) {
            UserFormView()
        }
        .sheet(item: $userToEdit) { utilisateur in
            UserFormView(utilisateur: utilisateur)
        }
        .alert("Confirmer la suppression", isPresented: $showDeleteConfirmation) {
            Button("Supprimer", role: .destructive) {
                if let utilisateur = userToDelete {
                    viewContext.delete(utilisateur)
                    try? viewContext.save()
                }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Voulez-vous vraiment supprimer cet utilisateur ?")
        }
    }
}

struct UserCard: View {
    let utilisateur: Utilisateur
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(utilisateur.wrappedNom)
                        .font(.headline)
                    Text(utilisateur.wrappedEmail)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Menu {
                    Button(action: onEdit) {
                        Label("Modifier", systemImage: "pencil")
                    }
                    Button(action: onDelete) {
                        Label("Supprimer", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            
            HStack(spacing: 8) {
                // Badge Rôle
                Text(utilisateur.wrappedRole)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(roleColor.opacity(0.2))
                    .foregroundColor(roleColor)
                    .cornerRadius(8)
                
                // Badge Statut
                Text(utilisateur.wrappedStatut)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(utilisateur.wrappedStatut == "Actif" ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(utilisateur.wrappedStatut == "Actif" ? .green : .red)
                    .cornerRadius(8)
            }
            
            Text("Créé le \(formatDate(utilisateur.wrappedDateCreation))")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var roleColor: Color {
        switch utilisateur.wrappedRole {
        case "Magasinier":
            return .green
        case "Gestionnaire de Stock":
            return .blue
        case "Responsable Achats":
            return .purple
        default:
            return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 