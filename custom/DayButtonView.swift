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
        HStack{
            if items.isEmpty == false {
                let today = Date()
                let lastDate = items[items.endIndex - 1].timestamp
                if dateIsSame(date1: today, date2: lastDate!) {
                    Text("Done")
                        .font(.title)
                        .frame(width: 100, height:60)
                } else {
                    Button(action: addItem){
                        Text("Check")
                            .frame(width: 100, height:60)
                            .background(Color.green)
                            .foregroundColor(Color.white)
                            .font(.title)
                            .cornerRadius(10)
                    }
                }
            } else {
                Button(action: addItem){
                    Text("First Check")
                        .frame(width: 210, height:60)
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .font(.title)
                        .cornerRadius(10)
                }
            }
            if items.count != 0 {
                let lastDate = items[items.endIndex - 1].timestamp!
                let calendar = Calendar(identifier: .gregorian)
                let diff = calendar.dateComponents([.hour], from: lastDate, to: Date()).hour!
                if diff < 1{
                    Button(action:deleteLastItem){
                        Text("  Delete\nLastData")
                            .frame(width: 100, height: 60)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        
    }

    private func addItem() {
        //素早く押すと同じ日付が登録されてしまうため、ここにも記載
        if items.isEmpty == false {
            let today = Date()
            let lastDate = items[items.endIndex - 1].timestamp
            if dateIsSame(date1: today, date2: lastDate!) {
                return
            }
        }
        
        withAnimation {
            let newItem = Item(context: viewContext)
            var elapsedDay:Int64 = 0
            if items.count != 0 {
                elapsedDay = getElapsedDay()
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
    
    private func deleteLastItem() {
        //素早く押すと余分にデータが削除されてしまうため、ここにも記載
        if items.count != 0{
            let lastDate = items[items.endIndex - 1].timestamp!
            let calendar = Calendar(identifier: .gregorian)
            let diff = calendar.dateComponents([.hour], from: lastDate, to: Date()).hour!
            if diff >= 1{
                return
            }
        }
        
        withAnimation {
            let context = viewContext
            context.delete(items[items.endIndex - 1])
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    //後々消す(代わりに全データ削除機能を実装する)
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
    
    func getElapsedDay() -> Int64{
        var startDate = items[items.startIndex].timestamp!
        startDate = resetTime(date: startDate)
        let elapsedDay = Int64(resetTime(date: Date()).timeIntervalSince(startDate) / 86400)
        return elapsedDay
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
        DayButtonView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
