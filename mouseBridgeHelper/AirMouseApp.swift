//
//  AirMouseApp.swift
//  mouseBridgeHelper
//
//  Created by Angshuman Barpujari on 12/27/25.
//

import SwiftUI

@main
struct AirMouseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Window(Constants.appName, id: "main") {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: Constants.windowWidth, height: Constants.windowHeight)
        .defaultPosition(.center)
        .windowResizability(.contentSize)
    }
}
