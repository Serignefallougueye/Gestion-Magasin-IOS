//
//  Gestion_de_Produit_IOS_UA3App.swift
//  Gestion de Produit IOS UA3
//
//  Created by COD Ibn Hallil on 11/04/2025.
//

import SwiftUI

@main
struct Gestion_de_Produit_IOS_UA3App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
