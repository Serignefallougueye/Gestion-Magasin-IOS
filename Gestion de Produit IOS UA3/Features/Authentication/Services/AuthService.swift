import Foundation
import CoreData
import SwiftUI

class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: Utilisateur?
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func register(email: String, password: String, nom: String, role: String = "Magasinier") -> Bool {
        // Vérifier si l'email existe déjà
        let fetchRequest: NSFetchRequest<Utilisateur> = Utilisateur.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let existingUsers = try viewContext.fetch(fetchRequest)
            if !existingUsers.isEmpty {
                return false // Email déjà utilisé
            }
            
            // Créer un nouvel utilisateur
            let hashedPassword = hashPassword(password)
            _ = Utilisateur.create(in: viewContext,
                                 email: email,
                                 motDePasse: hashedPassword,
                                 nom: nom,
                                 role: role)
            
            try viewContext.save()
            return true
        } catch {
            print("Erreur lors de l'inscription: \(error)")
            return false
        }
    }
    
    func login(email: String, password: String) -> Bool {
        let fetchRequest: NSFetchRequest<Utilisateur> = Utilisateur.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try viewContext.fetch(fetchRequest)
            if let user = users.first {
                let hashedPassword = hashPassword(password)
                if user.wrappedMotDePasse == hashedPassword {
                    user.derniereConnexion = Date()
                    try viewContext.save()
                    
                    currentUser = user
                    isAuthenticated = true
                    // Sauvegarder le nom d'utilisateur pour l'affichage
                    UserDefaults.standard.set(user.wrappedNom, forKey: "userName")
                    return true
                }
            }
            return false
        } catch {
            print("Erreur lors de la connexion: \(error)")
            return false
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "userName")
    }
    
    private func hashPassword(_ password: String) -> String {
        // TODO: Implémenter un vrai hachage de mot de passe sécurisé (bcrypt, Argon2, etc.)
        return password // Pour l'exemple, on retourne le mot de passe en clair
    }
} 