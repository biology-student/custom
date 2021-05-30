//
//  ContentView.swift
//  custom
//
//  Created by Yoshikazu Tsuka on 2021/05/30.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        VStack{
            List {
                ForEach(items) { item in
                    Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                }
                .onDelete(perform: deleteItems)
            }
            .frame(height: 400)
            Button(action: addItem){
                Text("Add")
                    .font(.title)
                    .foregroundColor(Color.green)
            }
            Spacer()
        }
        
    }

    private func addItem() {

        if items.isEmpty == false {
            let today = Date()
            let lastDate = items[items.endIndex - 1].timestamp
            if dateIsSame(date1: today, date2: lastDate!) {
                return
            }
        }
        
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func dateIsSame(date1: Date, date2: Date) -> Bool {
        return dateFormat(date: date1) == dateFormat(date: date2)
    }
    
    private func dateFormat(date: Date) -> String {
        let format = DateFormatter()
        format.dateStyle = .long
        format.timeStyle = .none
        return format.string(from: date)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
