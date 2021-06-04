//
//  CalendarView.swift
//  custom
//
//  Created by Yoshikazu Tsuka on 2021/06/02.
//

import SwiftUI
import CoreData

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        HStack(alignment: .bottom){
            VStack {
                List {
                    ForEach(items) { item in
                        Text("Item at \(item.elapsedDay)")
                    }
                }
                MonthView(yyyy: 2021, startMonth: 3, MM: 3, maxElapsedDay: getMaxElapsedDay(), data: setData())
            }
        }
    }
    
    func setData() -> [Int64?] {
        var data:[Int64?] = []
        items.forEach{item in
            data.append(item.elapsedDay)
        }
        return data
    }
    
    func getMaxElapsedDay() -> Int? {
        var elapsedDay:Int = 0
        if items.count != 0 {
            var startDate = items[items.startIndex].timestamp!
            startDate = resetTime(date: startDate)
            elapsedDay = Int(resetTime(date: Date()).timeIntervalSince(startDate) / 86400)
        }
        return elapsedDay
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

//セルの表示非表示を色で切り替える
//データが１の場合baseColor, それ以外Color.gray, データがない場合Color.clear
struct CellColorModifier:ViewModifier {
    init(isRange:Bool, data: Int?, baseColor:UIColor) {
        self.isRange = isRange
        if let d = data {
            if d == 1{
                self.cellColor = Color(baseColor)
            }else{
                self.cellColor = Color.gray
            }
            
        }else{
            self.cellColor = Color.clear
        }

    }
    let isRange:Bool
    let cellColor:Color
    func body(content: Content) -> some View {
        if(isRange){
            return content.foregroundColor(cellColor)
        }else{
            return content.foregroundColor(Color.clear)
        }
    }
}

//縦一列分の表示
struct WeekView: View {
    init(startIdx:Int, endIdx:Int, datas:[Int?]) {
        start = startIdx    //最初の日付(曜日)を入れる
        end = endIdx        //最後の日付(曜日)を入れる
        self.datas = datas
    }
    let start:Int
    let end:Int
    let datas:[Int?]
    
    var body: some View {
        VStack(spacing:2) {
            ForEach(0..<7) { i in
                RoundedRectangle(cornerRadius: 10).frame(width:50, height:50).modifier(CellColorModifier(isRange: (i >= start && i <= end), data: datas[i], baseColor: .systemGreen))
            }
        }
    }
}


//一月分の表示
struct MonthView:View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    
    init(yyyy:Int, startMonth:Int, MM:Int, maxElapsedDay:Int?, data:[Int64?]){
        //指定した月の最終日を取得
        let calendar = Calendar(identifier: .gregorian)
        var comp = DateComponents()
        comp.year = yyyy
        comp.month = startMonth
        
        comp.day = 1 //要修正
        
        startDate = calendar.date(from: comp)!
        //---ここの機能はいらないかもしれない--------------------------------------
        comp.month = MM + 1
        comp.day = 0
        let date = calendar.date(from: comp)!
        lastDay = calendar.component(.day, from: date)
        maxWeeks = calendar.component(.weekOfMonth, from: date)
        self.calendar = calendar
        self.yyyy = yyyy
        self.MM = MM
        self.maxElapsedDay = maxElapsedDay
        self.data = data
    }
    let calendar:Calendar
    let yyyy:Int
    let MM:Int
    let data:[Int64?]
    let startDate:Date
    let lastDay:Int
    let maxWeeks:Int
    let maxElapsedDay:Int?
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxWeeks) { w in
                let datas = GetWeekOfMonthDataValues(weekOfMonth: w + 1)
                let Idx = CheckIndex(w: w)
                WeekView(startIdx: Idx.startIdx, endIdx: Idx.endIdx, datas: datas)
            }
        }
    }
    
    
    //要修正
    //月毎に分けないように
    func CheckIndex(w:Int) -> (startIdx:Int, endIdx:Int) {
        if(w == 0){
            let start = GetWeekDay(dd: 1)
            return (start,6)
        }else if(w == (maxWeeks - 1)){
            let end = GetWeekDay(dd: lastDay)
            return (0,end)
        }else{
            return(0,6)
        }
    }
    
    func GetWeekDay(dd:Int) -> Int{
        let date = calendar.date(from: GetComponents(dd: dd))!
        return calendar.component(.weekday, from: date) - 1
    }
    
    func GetComponents(dd:Int) -> DateComponents{
        var comp = DateComponents()
        comp.year = yyyy
        comp.month = MM
        comp.day = dd
        return comp
    }
    
    func GetWeekOfMonthDataValues(weekOfMonth:Int)->[Int?]{
        var values:[Int?] = []
        var seComp = DateComponents()
        seComp.year = yyyy
        seComp.month = MM
        seComp.weekOfMonth = weekOfMonth
        for weekday in 1...7 {
            //曜日1-7
            seComp.weekday = weekday
            if let date = calendar.date(from: seComp) {
                let elapsed = calendar.dateComponents([.day], from:startDate,to:date).day!
                if maxElapsedDay == nil || maxElapsedDay! >= elapsed{
                    if (data.first(where: {$0 ?? 0 == elapsed}) != nil){
                        values.append(1)
                    }else{
                        values.append(0)
                    }
                }else{
                    values.append(nil)
                }
            }
        }
      return values
    }
}


struct Previews: PreviewProvider {
    static var previews: some View {
        CalendarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//        WeekView(startIdx: 4, endIdx: 6, datas: [Int?](repeating: 0, count: 7))
//        MonthView(yyyy: 2021, startMonth: 3, MM: 3, data: [
//            kari_no_data(elapsedDay: 0),
//            kari_no_data(elapsedDay: 4)
//        ], maxElapsedDay: 4)
    }
}
