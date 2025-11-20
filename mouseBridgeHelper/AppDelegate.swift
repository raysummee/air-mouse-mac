//
//  AppDelegate.swift
//  mouseBridgeHelper
//
//  Created by Angshuman Barpujari on 11/9/25.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover = NSPopover()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            if let image = NSImage(systemSymbolName: "sharedwithyou.circle.fill", accessibilityDescription: "Mouse Menu"){
                button.image = image
                button.image?.isTemplate = true  // Match dark/light mode
            }
            let title = NSAttributedString(
                string: "Mouse Bridge",
                attributes: [
                    .font: NSFont.systemFont(ofSize: 10), // 👈 smaller text
                    .foregroundColor: NSColor.labelColor
                ]
            )
            button.attributedTitle = title
            button.action = #selector(togglePopover(_:))
        }
        
        // Setup popover
        popover.contentViewController = NSHostingController(rootView: ContentView())
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.becomeKey()
        }
    }
}
