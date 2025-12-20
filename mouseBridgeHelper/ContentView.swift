//
//  ContentView.swift
//  mouseBridgeHelper
//
//  Created by Angshuman Barpujari on 11/9/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var connectionManager = ConnectionEventManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Hello from the menu bar")
                .font(.headline)
            HStack {
                Button("Start") {
                    if AccessibilityHelper.ensurePermission(){
                        print("[ContentView] Accessibility permission granted")
                        StartUDP(55555, 1, true)
                        StartMulticast(55555)
                        
                        // Register event callback
                        print("[ContentView] Registering event callback")
                        connectionManager.onEvent { event in
                            print("[ContentView] Event callback received: \(event.type)")
                            connectionManager.handleEvent(event)
                        }
                        
                        print("[ContentView] Starting monitoring")
                        connectionManager.startMonitoring()
                    } else {
                        print("[ContentView] Accessibility permission denied")
                    }
                }
                Button("Stop") {
                    StopMulticast()
                    StopUDP()
                    connectionManager.stopMonitoring()
                }
                
                Button("Quit") {
                    StopMulticast()
                    StopUDP()
                    connectionManager.stopMonitoring()
                    NSApplication.shared.terminate(self)
                }
            }
        }
        .padding(16)
        .frame(width: 300)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
