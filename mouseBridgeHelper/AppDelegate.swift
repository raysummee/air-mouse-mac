//
//  AppDelegate.swift
//  mouseBridgeHelper
//
//  Created by Angshuman Barpujari on 11/9/25.
//

import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    private var connectionManager = ConnectionEventManager.shared
    private var statusMenuItem: NSMenuItem!
    private var toggleServiceItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            if let image = NSImage(systemSymbolName: "sharedwithyou.circle.fill", accessibilityDescription: Constants.appIconDescription){
                button.image = image
                button.image?.isTemplate = true  // Match dark/light mode
            }
            let title = NSAttributedString(
                string: Constants.appName,
                attributes: [
                    .font: NSFont.systemFont(ofSize: Constants.menuBarFontSize),
                    .foregroundColor: NSColor.labelColor
                ]
            )
            button.attributedTitle = title
        }

        // Create menu
        let menu = NSMenu()

        // Status item (will be updated dynamically)
        statusMenuItem = NSMenuItem(title: Constants.notConnectedStatus, action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        menu.addItem(NSMenuItem.separator())

        // Toggle service item (will be updated dynamically)
        toggleServiceItem = NSMenuItem(title: Constants.startMenuTitle, action: #selector(toggleService(_:)), keyEquivalent: "")
        toggleServiceItem.target = self
        menu.addItem(toggleServiceItem)

        menu.addItem(NSMenuItem.separator())

        // Show window item
        let showWindowItem = NSMenuItem(title: Constants.showWindowMenuTitle, action: #selector(showWindow(_:)), keyEquivalent: "")
        showWindowItem.target = self
        menu.addItem(showWindowItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: Constants.quitMenuTitle, action: #selector(quitApp(_:)), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu

        // Observe connection status changes
        connectionManager.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateStatus()
            }
        }.store(in: &cancellables)

        updateStatus()
    }

    private var cancellables = Set<AnyCancellable>()

    // Prevent the app from terminating when the last window is closed
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    @objc func updateStatus() {
        let statusText = connectionManager.isConnected ? Constants.connectedStatus : Constants.notConnectedStatus
        statusMenuItem.title = statusText

        // Update toggle button based on monitoring state
        toggleServiceItem.title = connectionManager.isMonitoring ? Constants.stopMenuTitle : Constants.startMenuTitle
    }

    
    @objc func showWindow(_ sender: NSMenuItem) {
        // Bring app to front and show the window
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
    }

    @objc func quitApp(_ sender: NSMenuItem) {
        connectionManager.stopService()
        NSApplication.shared.terminate(self)
    }
    
    @objc func toggleService(_ sender: NSMenuItem) {
        connectionManager.toggleService();
    }
}
