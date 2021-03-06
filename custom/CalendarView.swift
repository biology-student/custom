//
//  CalendarView.swift
//  custom
//
//  Created by Yoshikazu Tsuka on 2021/06/02.
//

import SwiftUI
import CoreData


struct CalendarView:View {
    var body: some View{
        VStack{
            CalendarView_Fix(data: getData(), startDate: getStartDate(), maxElapsedDay: getMaxElapsedDay())
        }
    }


    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    func getData() -> [Int64?] {
        var data:[Int64?] = []
        items.forEach{item in
            data.append(item.elapsedDay)
        }
        return data
    }

    func getStartDate() -> Date{
        if items.count != 0 {
            return resetTime(date: items[items.startIndex].timestamp!)
        }
        return Date()
    }
    
    func getMaxElapsedDay() -> Int{
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


struct CalendarView_Fix:View{
    @State var value: ScrollViewProxy?


    init(data:[Int64?], startDate:Date, maxElapsedDay:Int){
        let calendar = Calendar(identifier: .gregorian)

        self.data = data
        self.startDate = startDate
        self.maxWeekOfYear = calendar.component(.weekOfYear, from: Date())
        self.startWeekOfYear = calendar.component(.weekOfYear, from: startDate)
        self.maxElapsedDay = maxElapsedDay
        self.calendar = calendar
    }
    let calendar:Calendar
    let data:[Int64?]
    let startDate:Date
    let maxWeekOfYear:Int
    let startWeekOfYear:Int
    let maxElapsedDay:Int

    var body: some View{
        ScrollView(.horizontal, showsIndicators: true){
            ScrollViewReader{ value in
                HStack(spacing:2){
                    Spacer(minLength: UIScreen.main.bounds.width / 2 - 20)
                    ForEach(startWeekOfYear..<maxWeekOfYear + 1){ w in
                        let datas = GetWeekData(w:w)
                        let Idx = CheckIndex(w:w)
                        WeekView(startIdx: Idx.startIdx, endIdx: Idx.endIdx, datas: datas).id(w)
                    }
                    Spacer(minLength: UIScreen.main.bounds.width / 2 - 20).id(0)
                }.onAppear{
                    self.value = value
                    
                        //????????????????????????????????????
                    self.value?.scrollTo(maxWeekOfYear, anchor: .center)
                }
            }
        }
    }

    func GetWeekData(w:Int) -> [Int?]{
        var weekData:[Int?] = []
        var setComp = DateComponents()
        setComp.yearForWeekOfYear = calendar.component(.year, from: startDate)
        setComp.weekOfYear = w
        for weekday in 1...7{
            setComp.weekday = weekday
            if let date = calendar.date(from: setComp){
                let elapsed = calendar.dateComponents([.day], from: startDate, to: date).day!
                if elapsed <= maxElapsedDay{
                    if (data.first(where: {$0 ?? 0 == elapsed}) != nil){
                        weekData.append(1)
                    }else{
                        weekData.append(0)
                    }
                }else{
                    weekData.append(nil)
                }
            }
        }
        return weekData
    }

    func CheckIndex(w:Int) -> (startIdx:Int, endIdx:Int){
        var start = 0
        var end = 6
        if(w == startWeekOfYear){
            start = calendar.component(.weekday, from: startDate) - 1
        }
        if(w == (maxWeekOfYear)){
            end = calendar.component(.weekday, from: Date()) - 1
        }
        return(start,end)
    }


}


//?????????(?????????)????????????
struct WeekView: View {
    init(startIdx:Int, endIdx:Int, datas:[Int?]) {
        start = startIdx    //???????????????(??????)????????????
        end = endIdx        //???????????????(??????)????????????
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


//????????????????????????????????????????????????
//????????????????????????baseColor, ????????????Color.gray, ????????????????????????Color.clear
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


struct Previews: PreviewProvider {
    static var previews: some View {
        CalendarView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)    }
}
