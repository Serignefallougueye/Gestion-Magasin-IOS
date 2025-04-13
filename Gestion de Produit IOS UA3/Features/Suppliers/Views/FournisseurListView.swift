import SwiftUI
import CoreData

struct FournisseurListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Fournisseur.nom, ascending: true)],
        animation: .default)
    private var fournisseurs: FetchedResults<Fournisseur>
    
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var filterStatus = "Tous"
    
    private let statusOptions = ["Tous", "Actif", "Inactif"]
    
    var filteredFournisseurs: [Fournisseur] {
        fournisseurs.filter { fournisseur in
            let matchesSearch = searchText.isEmpty || 
                fournisseur.wrappedNom.localizedCaseInsensitiveContains(searchText) ||
                fournisseur.wrappedContact.localizedCaseInsensitiveContains(searchText)
            
            let matchesStatus = filterStatus == "Tous" || fournisseur.wrappedStatut == filterStatus
            
            return matchesSearch && matchesStatus
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                HStack {
                    SearchBar(text: $searchText)
                    
                    Picker("Statut", selection: $filterStatus) {
                        ForEach(statusOptions, id: \.self) { status in
                            Text(status).tag(status)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                ForEach(filteredFournisseurs, id: \.self) { fournisseur in
                    NavigationLink(destination: FournisseurDetailView(fournisseur: fournisseur).environment(\.managedObjectContext, viewContext)) {
                        VStack(alignment: .leading) {
                            Text(fournisseur.wrappedNom)
                                .font(.headline)
                            HStack {
                                Text(fournisseur.wrappedContact)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(fournisseur.wrappedStatut)
                                    .font(.caption)
                                    .padding(5)
                                    .background(fournisseur.wrappedStatut == "Actif" ? Color.green : Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteFournisseurs)
            }
            .navigationTitle("Fournisseurs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Label("Ajouter", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddFournisseurView().environment(\.managedObjectContext, viewContext)
            }
        }
    }
    
    private func deleteFournisseurs(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredFournisseurs[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Erreur lors de la suppression : \(error)")
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Rechercher", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
} 