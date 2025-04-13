import SwiftUI

struct LocationDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var emplacement: Emplacement
    @State private var isEditing = false
    @Environment(\.presentationMode) var presentationMode
    
    private let zoneOptions = ["Nord", "Sud", "Est", "Ouest", "Centre"]
    private let typeOptions = ["Étagère", "Palette", "Casier", "Armoire"]
    
    var body: some View {
        Form {
            Section(header: Text("Informations générales")) {
                if isEditing {
                    TextField("Nom", text: $emplacement.wrappedNom)
                        .onChange(of: emplacement.wrappedNom) { _ in
                            saveChanges()
                        }
                    
                    Picker("Zone", selection: $emplacement.wrappedZone) {
                        ForEach(zoneOptions, id: \.self) { zone in
                            Text(zone).tag(zone)
                        }
                    }
                    .onChange(of: emplacement.wrappedZone) { _ in
                        saveChanges()
                    }
                    
                    Picker("Type", selection: $emplacement.wrappedType) {
                        ForEach(typeOptions, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .onChange(of: emplacement.wrappedType) { _ in
                        saveChanges()
                    }
                } else {
                    LabeledContent("Nom", value: emplacement.wrappedNom)
                    LabeledContent("Zone", value: emplacement.wrappedZone)
                    LabeledContent("Type", value: emplacement.wrappedType)
                }
            }
            
            Section(header: Text("Capacité et Occupation")) {
                if isEditing {
                    Stepper("Capacité: \(emplacement.capacite)", value: $emplacement.capacite, in: 1...1000)
                        .onChange(of: emplacement.capacite) { _ in
                            saveChanges()
                        }
                    
                    Stepper("Occupation: \(emplacement.occupation)", value: $emplacement.occupation, in: 0...emplacement.capacite)
                        .onChange(of: emplacement.occupation) { _ in
                            saveChanges()
                        }
                } else {
                    LabeledContent("Capacité", value: "\(emplacement.capacite)")
                    LabeledContent("Occupation", value: "\(emplacement.occupation)/\(emplacement.capacite)")
                    
                    if Double(emplacement.occupation) / Double(emplacement.capacite) > 0.8 {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Occupation élevée")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            if !isEditing {
                Section(header: Text("Informations système")) {
                    LabeledContent("Date de création", value: emplacement.wrappedDateCreation.formatted(.dateTime))
                }
            }
        }
        .navigationTitle(emplacement.wrappedNom)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        isEditing.toggle()
                    }
                } label: {
                    Text(isEditing ? "Terminer" : "Modifier")
                }
            }
        }
    }
    
    private func saveChanges() {
        withAnimation {
            do {
                try viewContext.save()
            } catch {
                print("Erreur lors de la sauvegarde : \(error)")
            }
        }
    }
} 