import SwiftUI
import Charts

struct StockLevelsChart: View {
    let produits: [Produit]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Niveaux de Stock par Produit")
                .font(.headline)
            
            if produits.isEmpty {
                Text("Aucun produit")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Chart {
                    ForEach(produits) { produit in
                        BarMark(
                            x: .value("Stock", produit.quantiteEnStock),
                            y: .value("Produit", produit.nom ?? "")
                        )
                        .foregroundStyle(.blue)
                        
                        RuleMark(
                            x: .value("Seuil", produit.seuilAlerte)
                        )
                        .foregroundStyle(.red)
                    }
                }
                
                // Légende
                HStack(spacing: 16) {
                    HStack {
                        Rectangle()
                            .fill(.blue)
                            .frame(width: 12, height: 12)
                        Text("Stock actuel")
                            .font(.caption)
                    }
                    
                    HStack {
                        Rectangle()
                            .fill(.red)
                            .frame(width: 12, height: 12)
                        Text("Seuil d'alerte")
                            .font(.caption)
                    }
                }
                .foregroundColor(.gray)
            }
        }
    }
}

struct StockDistributionChart: View {
    let produits: [Produit]
    
    var stockParCategorie: [(String, Int)] {
        Dictionary(grouping: produits) { $0.categorie?.nom ?? "Sans catégorie" }
            .mapValues { produits in
                produits.reduce(0) { $0 + Int($1.quantiteEnStock) }
            }
            .map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Répartition par Catégorie")
                .font(.headline)
            
            if stockParCategorie.isEmpty {
                Text("Aucune donnée")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Chart {
                    ForEach(stockParCategorie, id: \.0) { categorie, quantite in
                        BarMark(
                            x: .value("Catégorie", categorie),
                            y: .value("Quantité", quantite)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            StockLevelsChart(produits: [])
            StockDistributionChart(produits: [])
        }
        .padding()
    }
} 