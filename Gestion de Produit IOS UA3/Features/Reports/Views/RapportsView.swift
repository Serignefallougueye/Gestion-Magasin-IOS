import SwiftUI
import CoreData
import PDFKit
import UIKit

struct RapportsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Produit.nom, ascending: true)],
        animation: .default)
    private var produits: FetchedResults<Produit>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CommandeAchat.dateCommande, ascending: true)],
        animation: .default)
    private var commandes: FetchedResults<CommandeAchat>
    
    @State private var periode: Periode = .cetteSemaine
    @State private var showingPreview = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    enum Periode: String, CaseIterable {
        case aujourdhui = "Aujourd'hui"
        case cetteSemaine = "Cette semaine"
        case ceMois = "Ce mois"
        case cetteAnnee = "Cette année"
        case tout = "Tout"
        
        var dateDebut: Date {
            let calendar = Calendar.current
            let now = Date()
            switch self {
            case .aujourdhui:
                return calendar.startOfDay(for: now)
            case .cetteSemaine:
                return calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            case .ceMois:
                return calendar.dateInterval(of: .month, for: now)?.start ?? now
            case .cetteAnnee:
                return calendar.dateInterval(of: .year, for: now)?.start ?? now
            case .tout:
                return Date.distantPast
            }
        }
    }
    
    private var produitsFiltres: [Produit] {
        let dateDebut = periode.dateDebut
        let commandesFiltrees = commandes.filter { commande in
            guard let date = commande.dateCommande else { return false }
            return date >= dateDebut
        }
        
        var produitsUtilises = Set<Produit>()
        for commande in commandesFiltrees {
            if let lignes = commande.lignesCommande as? Set<LigneCommande> {
                for ligne in lignes {
                    if let produit = ligne.produit {
                        produitsUtilises.insert(produit)
                    }
                }
            }
        }
        
        return Array(produitsUtilises)
    }
    
    private var totalStock: Int32 {
        produitsFiltres.reduce(0) { $0 + $1.quantiteEnStock }
    }
    
    private var stockFaible: Int {
        produitsFiltres.filter { $0.quantiteEnStock <= $0.seuilAlerte }.count
    }
    
    private var stockOptimal: Int {
        produitsFiltres.filter { $0.quantiteEnStock > $0.seuilAlerte }.count
    }
    
    private var valeurTotaleStock: Double {
        produitsFiltres.reduce(0.0) { $0 + ($1.prix * Double($1.quantiteEnStock)) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // En-tête avec filtres
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Filtres et Options")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading) {
                            Text("Période")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Menu {
                                ForEach(Periode.allCases, id: \.self) { periode in
                                    Button(periode.rawValue) {
                                        self.periode = periode
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(periode.rawValue)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        
                        // Boutons d'action
                        HStack {
                            Button(action: {
                                exportToPDF()
                            }) {
                                Label("PDF", systemImage: "arrow.down.doc.fill")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                imprimerRapport()
                            }) {
                                Label("Imprimer", systemImage: "printer.fill")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                    
                    // Cartes de rapport en vertical
                    VStack(spacing: 16) {
                        // Rapport d'Inventaire
                        RapportCard(
                            titre: "Rapport d'Inventaire",
                            sousTitre: "État actuel des stocks et mouvements",
                            icon: "cube.box.fill",
                            couleur: .blue
                        ) {
                            VStack(spacing: 15) {
                                StatRow(titre: "Total Produits", valeur: "\(produitsFiltres.count)")
                                StatRow(titre: "Stock Total", valeur: "\(totalStock)")
                                StatRow(titre: "Catégories", valeur: "\(Set(produitsFiltres.compactMap { $0.categorie }).count)")
                            }
                        }
                        
                        // Rapport de Stock
                        RapportCard(
                            titre: "Rapport de Stock",
                            sousTitre: "Analyse détaillée des niveaux de stock",
                            icon: "chart.bar.fill",
                            couleur: .purple
                        ) {
                            VStack(spacing: 15) {
                                StatRow(titre: "Stock Faible", valeur: "\(stockFaible)")
                                StatRow(titre: "Stock Optimal", valeur: "\(stockOptimal)")
                            }
                        }
                        
                        // Rapport Financier
                        RapportCard(
                            titre: "Rapport Financier",
                            sousTitre: "Analyse financière et valorisation du stock",
                            icon: "dollarsign.circle.fill",
                            couleur: .green
                        ) {
                            VStack(spacing: 15) {
                                StatRow(titre: "Valeur Totale", valeur: String(format: "%.2f $", valeurTotaleStock))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Rapports")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingPreview = true
                    }) {
                        Label("Aperçu", systemImage: "eye.fill")
                    }
                }
            }
            .sheet(isPresented: $showingPreview) {
                RapportPreviewView(
                    periode: periode.rawValue,
                    nombreProduits: produitsFiltres.count,
                    stockTotal: totalStock,
                    nombreCategories: Set(produitsFiltres.compactMap { $0.categorie }).count,
                    stockFaible: stockFaible,
                    stockOptimal: stockOptimal,
                    valeurTotaleStock: valeurTotaleStock
                )
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .background(Color(.systemGray6))
    }
    
    private func exportToPDF() {
        let previewView = RapportPreviewView(
            periode: periode.rawValue,
            nombreProduits: produitsFiltres.count,
            stockTotal: totalStock,
            nombreCategories: Set(produitsFiltres.compactMap { $0.categorie }).count,
            stockFaible: stockFaible,
            stockOptimal: stockOptimal,
            valeurTotaleStock: valeurTotaleStock
        )
        
        let renderer = ImageRenderer(content: previewView)
        
        guard let data = renderer.uiImage?.pngData() else {
            alertTitle = "Erreur"
            alertMessage = "Impossible de générer le PDF"
            showingAlert = true
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfPath = documentsPath.appendingPathComponent("rapport_\(Date().timeIntervalSince1970).pdf")
        
        let pdfDocument = PDFDocument()
        
        if let image = UIImage(data: data),
           let page = PDFPage(image: image) {
            pdfDocument.insert(page, at: 0)
            
            do {
                try pdfDocument.dataRepresentation()?.write(to: pdfPath)
                alertTitle = "Succès"
                alertMessage = "Le rapport a été exporté en PDF"
            } catch {
                alertTitle = "Erreur"
                alertMessage = "Impossible de sauvegarder le PDF : \(error.localizedDescription)"
            }
            showingAlert = true
        }
    }
    
    private func imprimerRapport() {
        let previewView = RapportPreviewView(
            periode: periode.rawValue,
            nombreProduits: produitsFiltres.count,
            stockTotal: totalStock,
            nombreCategories: Set(produitsFiltres.compactMap { $0.categorie }).count,
            stockFaible: stockFaible,
            stockOptimal: stockOptimal,
            valeurTotaleStock: valeurTotaleStock
        )
        
        let renderer = ImageRenderer(content: previewView)
        
        guard let image = renderer.uiImage else {
            alertTitle = "Erreur"
            alertMessage = "Impossible de préparer l'impression"
            showingAlert = true
            return
        }
        
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "Rapport de Stock"
        printInfo.outputType = .general
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        
        let printFormatter = UISimpleTextPrintFormatter(text: "")
        printController.printFormatter = printFormatter
        
        printController.printingItem = image
        
        printController.present(animated: true) { _, completed, error in
            if completed {
                alertTitle = "Succès"
                alertMessage = "Le rapport a été envoyé à l'imprimante"
            } else if let error = error {
                alertTitle = "Erreur"
                alertMessage = "Erreur d'impression : \(error.localizedDescription)"
            }
            showingAlert = true
        }
    }
}

struct RapportCard<Content: View>: View {
    let titre: String
    let sousTitre: String
    let icon: String
    let couleur: Color
    let content: Content
    
    init(
        titre: String,
        sousTitre: String,
        icon: String,
        couleur: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.titre = titre
        self.sousTitre = sousTitre
        self.icon = icon
        self.couleur = couleur
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(couleur)
                
                VStack(alignment: .leading) {
                    Text(titre)
                        .font(.headline)
                    Text(sousTitre)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatRow: View {
    let titre: String
    let valeur: String
    
    var body: some View {
        HStack {
            Text(titre)
                .foregroundColor(.secondary)
            Spacer()
            Text(valeur)
                .bold()
        }
    }
}

struct RapportsView_Previews: PreviewProvider {
    static var previews: some View {
        RapportsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 
