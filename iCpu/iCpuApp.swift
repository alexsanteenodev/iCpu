//
//  iCpuApp.swift
//  iCpu
//
//  Created by Oleksandr Hanhaliuk on 18.02.2023.
//
import Cocoa
import SwiftUI

import Cocoa



class AppState: ObservableObject {
    static let shared = AppState()    // << here !!

    // Singe source of truth...
    @Published var title = "" // <- No default value here
    @Published var menuItem1 = "menu1"
}



@main
struct iCpuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var appState = AppState.shared
    @State var currentNumber: String = "1"

    
    var body: some Scene {
        Group {
            MenuBarExtra(appState.title) {
//                Button(appState.menuItem1) {
//                                currentNumber = "3"
//                    appState.menuItem1 = "new menu item"
//                            }
                Button("Quit") {

                                NSApplication.shared.terminate(nil)

                            }.keyboardShortcut("q")

            }
            .menuBarExtraStyle(WindowMenuBarExtraStyle())
 
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {


    var timer: Timer!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let tempsensor = TempSensor()


        let appState = AppState.shared
        appState.title = tempsensor.getTemperature()
        // Start timer to update button title every 3 seconds
        self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in

            appState.title = tempsensor.getTemperature()

        }

        
        NSApp.activate(ignoringOtherApps: true)
    }
    
}
