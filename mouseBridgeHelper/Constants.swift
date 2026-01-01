//
//  Constants.swift
//  mouseBridgeHelper
//
//  Created by Angshuman Barpujari on 12/27/25.
//

import Foundation

enum Constants {
    // App Information
    static let appName = "Air Mouse"
    static let appIconDescription = "Mouse Menu"

    // Network Configuration
    static let multicastPort: Int32 = 55555
    static let udpPort: Int32 = 55555
    static let udpTimeout: Double = 1

    // Connection Status
    static let connectedStatus = "Connected to Mobile"
    static let notConnectedStatus = "Not Connected"

    // Service Status
    static let serviceRunning = "Running"
    static let serviceStopped = "Stopped"

    // Menu Items
    static let startMenuTitle = "Start"
    static let stopMenuTitle = "Stop"
    static let showWindowMenuTitle = "Show Window"
    static let quitMenuTitle = "Quit"

    // UI Text
    static let statusLabel = "Status:"
    static let serviceLabel = "Service:"
    static let startServiceButton = "Start Service"
    static let stopServiceButton = "Stop Service"
    static let windowDescription = "Use the status bar menu to control the service.\nThe app will continue running even when this window is closed."

    // Dialogs
    static let connectionRequestTitle = "New Connection Request"
    static let accessibilityNeededTitle = "Accessibility Access Needed"
    static let accessibilityNeededMessage = """
    This app requires Accessibility access to control your mouse or keyboard.
    Please enable it in System Settings → Privacy & Security → Accessibility.
    """

    // Buttons
    static let approveButton = "Approve"
    static let rejectButton = "Reject"
    static let openSettingsButton = "Open Settings"
    static let cancelButton = "Cancel"

    // Event Types
    enum EventType {
        static let newPendingConnection = "new_pending_connection"
        static let connectionApproved = "connection_approved"
        static let connectionRejected = "connection_rejected"
        static let connectionDisconnected = "connection_disconnected"
    }

    // Thread Names
    static let connectionEventListenerThreadName = "ConnectionEventListener"

    // UI Dimensions
    static let windowWidth: CGFloat = 350
    static let windowHeight: CGFloat = 250
    static let buttonMinWidth: CGFloat = 120
    static let menuBarFontSize: CGFloat = 10

    // Timeouts
    static let accessibilityAlertDelay: TimeInterval = 1.0
}
