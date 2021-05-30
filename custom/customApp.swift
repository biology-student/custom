//
//  customApp.swift
//  custom
//
//  Created by Yoshikazu Tsuka on 2021/05/30.
//

import SwiftUI

@main
struct customApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
