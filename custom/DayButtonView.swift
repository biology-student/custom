//
//  DayButtonView.swift
//  custom
//
//  Created by Yoshikazu Tsuka on 2021/06/02.
//



import SwiftUI
import CoreData

struct DayButtonView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        VStack{
            List {
                ForEach(items) { item in
                    Text("Item at \(dateFormat(date: item.timestamp!))\n ElapsedDay = \(item.elapsedDay)")
                }
                .onDelete(perform: deleteItems)
            }
            .frame(height: 400)
            
//            if items.isEmpty == false {
//                let today = Date()
//                let lastDate = items[items.endIndex - 1].timestamp
//                if dateIsSame(date1: today, date2: lastDate!) {
//                    Text("Done")
//                } else {
//                    Button(action: addItem){
//                        Text("Check")
//                            .font(.title)
//                            .foregroundColor(Color.green)
//                    }
//                }
//            } else {
                Button(action: addItem){
                    Text("First Check")
                        .font(.title)
                        .foregroundColor(Color.green)
                }
//            }
            
            Spacer()
        }
        
    }

    private func addItem() {
        
        //素早く押すと同じ日付が登録されてしまうため、ここにも記載
//        if items.isEmpty == false {
//            let today = Date()
//            let lastDate = items[items.endIndex - 1].timestamp
//            if dateIsSame(date1: today, date2: lastDate!) {
//                return
//            }
//        }
        
        withAnimation {
            let newItem = Item(context: viewContext)
            var elapsedDay:Int64 = 0
            if items.count != 0 {
                var startDate = items[items.startIndex].timestamp!
                startDate = resetTime(date: startDate)
                elapsedDay = Int64(resetTime(date: Date()).timeIntervalSince(startDate) / 86400)
            }
            newItem.timestamp = Date()
            newItem.elapsedDay = elapsedDay
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
    
    func resetTime(date:Date) -> Date {
        let calendar:Calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        components.hour = 0
        components.minute = 0
        components.second = 0

        return calendar.date(from: components)!
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct DayButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DayButtonView().preferredColorScheme(.dark).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
