import SwiftUI
import CoreData

struct LocationListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Emplacement.nom, ascending: true)],
        animation: .default)
    private var emplacements: FetchedResults<Emplacement>
    
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var selectedZone = "Toutes"
    
    private let zoneOptions = ["Toutes", "Nord", "Sud", "Est", "Ouest", "Centre"]
    
    var filteredEmplacements: [Emplacement] {
        emplacements.filter { emplacement in
            let matchesSearch = searchText.isEmpty || 
                emplacement.wrappedNom.localizedCaseInsensitiveContains(searchText)
            
            let matchesZone = selectedZone == "Toutes" || emplacement.wrappedZone == selectedZone
            
            return matchesSearch && matchesZone
        }
    }
    
    var body: some View {
        List {
            HStack {
                // Barre de recherche personnalisée
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Picker("Zone", selection: $selectedZone) {
                    ForEach(zoneOptions, id: \.self) { zone in
                        Text(zone).tag(zone)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            ForEach(filteredEmplacements, id: \.self) { emplacement in
                NavigationLink(destination: LocationDetailView(emplacement: emplacement).environment(\.managedObjectContext, viewContext)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.blue)
                            Text(emplacement.wrappedNom)
                                .font(.headline)
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Zone: \(emplacement.wrappedZone)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Type: \(emplacement.wrappedType)")
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Capacité: \(emplacement.capacite)")
                                    .font(.subheadline)
                                Text("Occupation: \(emplacement.occupation)/\(emplacement.capacite)")
                                    .font(.caption)
                                    .foregroundColor(
                                        Double(emplacement.occupation) / Double(emplacement.capacite) > 0.8 
                                        ? .red 
                                        : .gray
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: deleteEmplacements)
        }
        .navigationTitle("Emplacements")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddSheet = true }) {
                    Label("Ajouter", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddLocationView().environment(\.managedObjectContext, viewContext)
        }
    }
    
    private func deleteEmplacements(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredEmplacements[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Erreur lors de la suppression : \(error)")
            }
        }
    }
} 