//
//  ContentView.swift
//  Gestion de Produit IOS UA3
//
//  Created by COD Ibn Hallil on 11/04/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authService: AuthService

    var body: some View {
        DashboardView()
            .environment(\.managedObjectContext, viewContext)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AuthService(context: PersistenceController.preview.container.viewContext))
    }
}
