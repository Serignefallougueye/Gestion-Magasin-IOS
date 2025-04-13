import Foundation
import CoreData

extension Categorie {
    static func create(in context: NSManagedObjectContext,
                      nom: String) -> Categorie {
        let categorie = Categorie(context: context)
        categorie.id = UUID()
        categorie.nom = nom
        return categorie
    }
    
    var wrappedId: UUID {
        id ?? UUID()
    }
    
    var wrappedNom: String {
        nom ?? ""
    }
    
    var produitsArray: [Produit] {
        let set = produits as? Set<Produit> ?? []
        return Array(set).sorted { $0.wrappedNom < $1.wrappedNom }
    }
} 