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
    @StateObject private var authService = AuthService(context: PersistenceController.shared.container.viewContext)
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    DashboardView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(authService)
                        .environmentObject(themeManager)
                        .preferredColorScheme(themeManager.colorScheme)
                        .tint(themeManager.accentColor)
                } else {
                    LoginView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .environmentObject(authService)
                        .environmentObject(themeManager)
                        .preferredColorScheme(themeManager.colorScheme)
                        .tint(themeManager.accentColor)
                }
            }
            .animation(.default, value: authService.isAuthenticated)
        }
    }
}
