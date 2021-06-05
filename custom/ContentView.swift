//
//  ContentView.swift
//  custom
//
//  Created by Yoshikazu Tsuka on 2021/05/30.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    var body: some View {
        VStack{
            CalendarView()
            DayButtonView()
        }
    }
}

struct Content_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
