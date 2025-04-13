//
//  Persistence.swift
//  Gestion de Produit IOS UA3
//
//  Created by COD Ibn Hallil on 11/04/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "GestionProduit")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { [weak container] description, error in
            if let error = error {
                fatalError("Erreur lors du chargement du Core Data store: \(error)")
            }
            
            // Activer la fusion automatique des changements
            container?.viewContext.automaticallyMergesChangesFromParent = true
            
            // Configuration du contexte
            container?.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
    }
    
    // Méthode utilitaire pour sauvegarder le contexte
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Erreur lors de la sauvegarde du contexte: \(nsError)")
            }
        }
    }
    
    // Contexte de prévisualisation pour SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Créer des données de test
        let electronique = Categorie.create(in: context, nom: "Électronique")
        let reseau = Categorie.create(in: context, nom: "Réseau")
        
        // Créer quelques produits
        _ = Produit.create(in: context,
                          nom: "Cable HDMI",
                          prix: 19.99,
                          quantiteEnStock: 20,
                          seuilAlerte: 10,
                          categorie: electronique)
        
        _ = Produit.create(in: context,
                          nom: "Switch Gigabit",
                          prix: 49.99,
                          quantiteEnStock: 15,
                          seuilAlerte: 5,
                          categorie: reseau)
        
        _ = Produit.create(in: context,
                          nom: "Smart TV",
                          prix: 599.99,
                          quantiteEnStock: 8,
                          seuilAlerte: 3,
                          categorie: electronique)
        
        // Créer un utilisateur de test
        _ = Utilisateur.create(in: context,
                             email: "test@example.com",
                             motDePasse: "test123",
                             nom: "Dupont",
                             role: "Gestionnaire de Stock",
                             statut: "Actif")
        
        try? context.save()
        return controller
    }()
}
