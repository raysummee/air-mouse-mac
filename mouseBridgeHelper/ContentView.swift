//
//  ContentView.swift
//  mouseBridgeHelper
//
//  Created by Angshuman Barpujari on 11/9/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Hello from the menu bar")
                .font(.headline)
            HStack {
                Button("Start") {
                    // action
                    if AccessibilityHelper.ensurePermission(){
                        StartUDP(55555, 1, true)
                        StartMulticast(55555)
                    }
                }
                Button("Stop") {
                    StopMulticast()
                    StopUDP()
                }
                
                Button("Quit") {
                    StopMulticast()
                    StopUDP()
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
