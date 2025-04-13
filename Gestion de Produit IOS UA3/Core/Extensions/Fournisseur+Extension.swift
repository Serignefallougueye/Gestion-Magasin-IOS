import Foundation
import CoreData

extension Fournisseur {
    static func create(in context: NSManagedObjectContext,
                      nom: String,
                      contact: String,
                      email: String,
                      telephone: String,
                      siteWeb: String,
                      categorie: String,
                      statut: String = "Actif") -> Fournisseur {
        let fournisseur = Fournisseur(context: context)
        fournisseur.id = UUID()
        fournisseur.nom = nom
        fournisseur.contact = contact
        fournisseur.email = email
        fournisseur.telephone = telephone
        fournisseur.siteWeb = siteWeb
        fournisseur.categorie = categorie
        fournisseur.statut = statut
        fournisseur.dateCreation = Date()
        return fournisseur
    }
    
    var wrappedId: UUID {
        id ?? UUID()
    }
    
    var wrappedNom: String {
        get { nom ?? "" }
        set { nom = newValue }
    }
    
    var wrappedContact: String {
        get { contact ?? "" }
        set { contact = newValue }
    }
    
    var wrappedEmail: String {
        get { email ?? "" }
        set { email = newValue }
    }
    
    var wrappedTelephone: String {
        get { telephone ?? "" }
        set { telephone = newValue }
    }
    
    var wrappedSiteWeb: String {
        get { siteWeb ?? "" }
        set { siteWeb = newValue }
    }
    
    var wrappedCategorie: String {
        get { categorie ?? "" }
        set { categorie = newValue }
    }
    
    var wrappedStatut: String {
        get { statut ?? "Actif" }
        set { statut = newValue }
    }
    
    var wrappedDateCreation: Date {
        get { dateCreation ?? Date() }
        set { dateCreation = newValue }
    }
    
    static var allFournisseursFetchRequest: NSFetchRequest<Fournisseur> {
        let request = NSFetchRequest<Fournisseur>(entityName: "Fournisseur")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Fournisseur.nom, ascending: true)]
        return request
    }
} 