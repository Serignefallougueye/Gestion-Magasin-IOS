import Foundation
import CoreData

extension Emplacement {
    // Propriétés wrapped pour éviter les optionnels
    var wrappedId: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    var wrappedNom: String {
        get { nom ?? "" }
        set { nom = newValue }
    }
    
    var wrappedZone: String {
        get { zone ?? "Nord" }
        set { zone = newValue }
    }
    
    var wrappedType: String {
        get { type ?? "Étagère" }
        set { type = newValue }
    }
    
    var wrappedDateCreation: Date {
        get { dateCreation ?? Date() }
        set { dateCreation = newValue }
    }
    
    // Méthode de création avec valeurs par défaut
    static func create(in context: NSManagedObjectContext,
                      nom: String,
                      zone: String = "Nord",
                      type: String = "Étagère",
                      capacite: Int16 = 100,
                      occupation: Int16 = 0) -> Emplacement {
        let emplacement = Emplacement(context: context)
        emplacement.id = UUID()
        emplacement.nom = nom
        emplacement.zone = zone
        emplacement.type = type
        emplacement.capacite = capacite
        emplacement.occupation = occupation
        emplacement.dateCreation = Date()
        return emplacement
    }
} 