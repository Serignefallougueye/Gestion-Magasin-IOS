import Foundation
import CoreData

extension Produit {
    static func create(in context: NSManagedObjectContext,
                      nom: String,
                      prix: Double,
                      quantiteEnStock: Int32,
                      seuilAlerte: Int32,
                      categorie: Categorie) -> Produit {
        let produit = Produit(context: context)
        produit.id = UUID()
        produit.nom = nom
        produit.prix = prix
        produit.quantiteEnStock = quantiteEnStock
        produit.seuilAlerte = seuilAlerte
        produit.dateCreation = Date()
        produit.categorie = categorie
        return produit
    }
    
    var wrappedId: UUID {
        id ?? UUID()
    }
    
    var wrappedNom: String {
        nom ?? ""
    }
    
    var wrappedPrix: Double {
        prix
    }
    
    var wrappedQuantiteEnStock: Int32 {
        quantiteEnStock
    }
    
    var wrappedSeuilAlerte: Int32 {
        seuilAlerte
    }
    
    var wrappedDateCreation: Date {
        dateCreation ?? Date()
    }
    
    var wrappedCategorie: Categorie {
        categorie ?? Categorie()
    }
    
    var isStockBas: Bool {
        quantiteEnStock <= seuilAlerte
    }
} 