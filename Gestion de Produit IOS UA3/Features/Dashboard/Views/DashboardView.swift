import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Produit.nom, ascending: true)],
        animation: .default)
    private var produits: FetchedResults<Produit>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Categorie.nom, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Categorie>
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "statut == %@", "EN_ATTENTE"),
        animation: .default)
    private var commandesEnAttente: FetchedResults<CommandeAchat>
    
    @State private var selectedCategorie = "Toutes les catégories"
    @State private var showMenu = false
    @State private var showingStockAlerts = false
    
    private var produitsStockFaible: [Produit] {
        produits.filter { $0.quantiteEnStock <= $0.seuilAlerte }
    }
    
    private var produitsFiltres: [Produit] {
        let produits = Array(self.produits)
        if selectedCategorie == "Toutes les catégories" {
            return produits
        }
        return produits.filter { $0.categorie?.wrappedNom == selectedCategorie }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // En-tête avec statistiques
                    VStack(spacing: 16) {
                        // Cartes statistiques en grille 2x2
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            StatCard(
                                title: "Total Produits",
                                value: "\(produitsFiltres.count)",
                                icon: "cube.fill",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Stock Faible",
                                value: "\(produitsFiltres.filter { $0.quantiteEnStock < $0.seuilAlerte }.count)",
                                icon: "exclamationmark.triangle.fill",
                                color: .red
                            )
                            
                            StatCard(
                                title: "En Stock",
                                value: "\(produitsFiltres.filter { $0.quantiteEnStock > 0 }.count)",
                                icon: "archivebox.fill",
                                color: .green
                            )
                            
                            StatCard(
                                title: "Commandes",
                                value: "\(commandesEnAttente.count)",
                                icon: "clock.fill",
                                color: .orange
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Analyse des Stocks
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Analyse des Stocks")
                                .font(.title2)
                                .bold()
                            Spacer()
                            Text(Date(), style: .time)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // Filtres
                        VStack(spacing: 12) {
                            Menu {
                                Button("Toutes les catégories") {
                                    selectedCategorie = "Toutes les catégories"
                                }
                                ForEach(categories, id: \.self) { categorie in
                                    Button(categorie.wrappedNom) {
                                        selectedCategorie = categorie.wrappedNom
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCategorie)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Stock Total
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Stock Total")
                                    .foregroundColor(.white)
                                Text("\(totalStock) unités")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "cube.box.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        
                        // Finance Total
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Finance Total")
                                    .foregroundColor(.white)
                                Text(String(format: "%.2f $", totalFinance))
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    .padding()
                    
                    // Graphiques adaptés au mobile
                    VStack(spacing: 16) {
                        StockLevelsChart(produits: produitsFiltres)
                            .frame(height: 200)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        
                        StockDistributionChart(produits: produitsFiltres)
                            .frame(height: 200)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Tableau de Bord")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showMenu.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingStockAlerts.toggle()
                    }) {
                        ZStack {
                            Image(systemName: "bell.fill")
                            if !produitsStockFaible.isEmpty {
                                Text("\(produitsStockFaible.count)")
                                    .font(.caption2)
                                    .padding(4)
                                    .foregroundColor(.white)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                    }
                }
            }
            .sheet(isPresented: $showMenu) {
                MobileMenuView(isPresented: $showMenu)
            }
            .sheet(isPresented: $showingStockAlerts) {
                StockAlertsView(produits: produitsStockFaible)
            }
        }
    }
    
    private var totalStock: Int {
        produitsFiltres.reduce(into: 0) { result, produit in
            result += Int(produit.quantiteEnStock)
        }
    }
    
    private var totalFinance: Double {
        produitsFiltres.reduce(into: 0.0) { result, produit in
            result += Double(produit.quantiteEnStock) * produit.prix
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.system(size: 25, weight: .bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct MobileMenuView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink(destination: DashboardView()) {
                        Label("Tableau de Bord", systemImage: "chart.pie.fill")
                    }
                    NavigationLink(destination: ProductListView().environment(\.managedObjectContext, viewContext)) {
                        Label("Produits", systemImage: "cube.box.fill")
                    }
                    NavigationLink(destination: InventoryListView().environment(\.managedObjectContext, viewContext)) {
                        Label("Inventaire", systemImage: "list.clipboard.fill")
                    }
                    NavigationLink(destination: PurchasesView().environment(\.managedObjectContext, viewContext)) {
                        Label("Achats", systemImage: "cart.fill")
                    }
                    NavigationLink(destination: FournisseurListView().environment(\.managedObjectContext, viewContext)) {
                        Label("Fournisseurs", systemImage: "building.2.fill")
                    }
                    NavigationLink(destination: LocationListView().environment(\.managedObjectContext, viewContext)) {
                        Label("Emplacements", systemImage: "mappin.circle.fill")
                    }
                    NavigationLink(destination: RapportsView().environment(\.managedObjectContext, viewContext)) {
                        Label("Rapports", systemImage: "chart.bar.fill")
                    }
                    NavigationLink(destination: UserListView().environment(\.managedObjectContext, viewContext)) {
                        Label("Utilisateurs", systemImage: "person.2.fill")
                    }
                }
                
                Section {
                   
                    NavigationLink(destination: SettingsView().environment(\.managedObjectContext, viewContext)) {
                        Label("Paramètres", systemImage: "gearshape.fill")
                    }
                    Button(action: {
                        dismiss()
                        authService.logout()
                    }) {
                        Label("Déconnexion", systemImage: "rectangle.portrait.and.arrow.right.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct StockAlertsView: View {
    let produits: [Produit]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(produits, id: \.self) { produit in
                VStack(alignment: .leading, spacing: 8) {
                    Text(produit.wrappedNom)
                        .font(.headline)
                    
                    HStack {
                        Text("Stock actuel:")
                            .foregroundColor(.secondary)
                        Text("\(produit.quantiteEnStock)")
                            .foregroundColor(.red)
                        Text("/ Seuil:")
                            .foregroundColor(.secondary)
                        Text("\(produit.seuilAlerte)")
                            .foregroundColor(.orange)
                    }
                    
                    if let categorie = produit.categorie {
                        Text(categorie.wrappedNom)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Alertes de Stock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(AuthService(context: PersistenceController.preview.container.viewContext))
    }
} 
