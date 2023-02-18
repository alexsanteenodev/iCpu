//
//  iCpuApp.swift
//  iCpu
//
//  Created by Oleksandr Hanhaliuk on 18.02.2023.
//

import Cocoa
import SwiftUI

@main
struct iCpuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {

    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var timer: Timer!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "Icon")
            button.action = #selector(togglePopover(_:))
            
            button.title = "\(self.getCPUTemperature())°C"
            
//             Start timer to update button title every 3 seconds
            self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                button.title = "\(self.getCPUTemperature())"
            }
        }
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    // Helper function to get current CPU temperature
           func getCPUTemperatureWithCommandLine() -> Int {
               let task = Process()
               task.launchPath = "/usr/bin/env"
               task.arguments = ["iStats", "cpu", "--no-graph", "--value-only"]
               
               let pipe = Pipe()
               task.standardOutput = pipe
               task.launch()
               
               let data = pipe.fileHandleForReading.readDataToEndOfFile()
               let output = String(data: data, encoding: String.Encoding.utf8)!
               
               return Int(output.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
           }
        func getCPUTemperature() -> String {
            var temperature: Double = 0
            let task = Process()
            task.launchPath = "/usr/bin/env"
            task.arguments = ["sysctl", "machdep.xcpm.cpu_thermal_level"]
            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let tempString = output.replacingOccurrences(of: "machdep.xcpm.cpu_thermal_level: ", with: "")
                if let tempDouble = Double(tempString) {
                    temperature = tempDouble
                }
            }
            return String(format: "%.0f", temperature) + "°C"
        }
    
}

