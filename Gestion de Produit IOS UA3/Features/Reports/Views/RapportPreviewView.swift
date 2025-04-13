import SwiftUI
import CoreData

struct RapportPreviewView: View {
    let periode: String
    let nombreProduits: Int
    let stockTotal: Int32
    let nombreCategories: Int
    let stockFaible: Int
    let stockOptimal: Int
    let valeurTotaleStock: Double
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // En-tête
                VStack(spacing: 8) {
                    Text("Rapport de Gestion des Stocks")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Période : \(periode)")
                        .foregroundColor(.secondary)
                    
                    Text(Date(), style: .date)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                
                // Sections du rapport
                Group {
                    // Section Inventaire
                    VStack(alignment: .leading, spacing: 16) {
                        Text("1. État de l'Inventaire")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Nombre total de produits :")
                                Spacer()
                                Text("\(nombreProduits)")
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Quantité totale en stock :")
                                Spacer()
                                Text("\(stockTotal)")
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Nombre de catégories :")
                                Spacer()
                                Text("\(nombreCategories)")
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    
                    // Section Analyse des Stocks
                    VStack(alignment: .leading, spacing: 16) {
                        Text("2. Analyse des Niveaux de Stock")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Produits en stock faible :")
                                Spacer()
                                Text("\(stockFaible)")
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                            }
                            
                            HStack {
                                Text("Produits en stock optimal :")
                                Spacer()
                                Text("\(stockOptimal)")
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    
                    // Section Financière
                    VStack(alignment: .leading, spacing: 16) {
                        Text("3. Analyse Financière")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Valeur totale du stock :")
                                Spacer()
                                Text(String(format: "%.2f €", valeurTotaleStock))
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                }
                
                // Pied de page
                Text("Rapport généré automatiquement")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
            }
            .padding()
        }
        .background(Color(.systemGray6))
    }
} 