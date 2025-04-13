import SwiftUI

struct AddLocationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var nom = ""
    @State private var zone = "Nord"
    @State private var type = "Étagère"
    @State private var capacite = 100
    @State private var occupation = 0
    
    private let zoneOptions = ["Nord", "Sud", "Est", "Ouest", "Centre"]
    private let typeOptions = ["Étagère", "Palette", "Casier", "Armoire"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations générales")) {
                    TextField("Nom", text: $nom)
                    
                    Picker("Zone", selection: $zone) {
                        ForEach(zoneOptions, id: \.self) { zone in
                            Text(zone).tag(zone)
                        }
                    }
                    
                    Picker("Type", selection: $type) {
                        ForEach(typeOptions, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }
                
                Section(header: Text("Capacité et Occupation")) {
                    Stepper("Capacité: \(capacite)", value: $capacite, in: 1...1000)
                    Stepper("Occupation initiale: \(occupation)", value: $occupation, in: 0...capacite)
                }
            }
            .navigationTitle("Nouvel Emplacement")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        addEmplacement()
                    }
                    .disabled(nom.isEmpty)
                }
            }
        }
    }
    
    private func addEmplacement() {
        withAnimation {
            let newEmplacement = Emplacement(context: viewContext)
            newEmplacement.id = UUID()
            newEmplacement.nom = nom
            newEmplacement.zone = zone
            newEmplacement.type = type
            newEmplacement.capacite = Int16(capacite)
            newEmplacement.occupation = Int16(occupation)
            newEmplacement.dateCreation = Date()
            
            do {
                try viewContext.save()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Erreur lors de la création : \(error)")
            }
        }
    }
} 