//
//  mouseBridgeHelper.swift
//  mouseBridgeHelper
//
//  Created by Angshuman Barpujari on 11/9/25.
//
import SwiftUI

@main
struct MouseBridgeHelper: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // No main window, only menu bar
        Settings {} // keep empty settings scene
    }
}
