import Foundation
import CoreData

extension Utilisateur {
    static func create(in context: NSManagedObjectContext,
                      email: String,
                      motDePasse: String,
                      nom: String,
                      role: String = "Magasinier",
                      statut: String = "Actif") -> Utilisateur {
        let utilisateur = Utilisateur(context: context)
        utilisateur.id = UUID()
        utilisateur.email = email
        utilisateur.motDePasse = motDePasse
        utilisateur.nom = nom
        utilisateur.role = role
        utilisateur.statut = statut
        utilisateur.dateCreation = Date()
        utilisateur.derniereConnexion = Date()
        return utilisateur
    }
    
    var wrappedId: UUID {
        id ?? UUID()
    }
    
    var wrappedEmail: String {
        email ?? ""
    }
    
    var wrappedNom: String {
        nom ?? ""
    }
    
    var wrappedMotDePasse: String {
        motDePasse ?? ""
    }
    
    var wrappedRole: String {
        role ?? "Magasinier"
    }
    
    var wrappedStatut: String {
        statut ?? "Actif"
    }
    
    var wrappedDateCreation: Date {
        dateCreation ?? Date()
    }
    
    var wrappedDerniereConnexion: Date {
        derniereConnexion ?? Date()
    }
} 