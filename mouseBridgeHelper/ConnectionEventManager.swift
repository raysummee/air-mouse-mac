//
//  ConnectionEventManager.swift
//  mouseBridgeHelper
//
//  Created by Angshuman Barpujari on 12/21/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Types

/// Callback type for connection events
typealias ConnectionEventCallback = (ConnectionEvent) -> Void

/// Represents a parsed connection event
struct ConnectionEvent {
    enum EventType {
        case newPendingConnection
        case connectionApproved
        case connectionRejected
        case connectionDisconnected
        case unknown(String)
    }

    let type: EventType
    let deviceID: String
    let details: String
}

// MARK: - ConnectionEventManager

class ConnectionEventManager: NSObject, ObservableObject {
    @Published var isMonitoring = false
    @Published var isConnected = false
    private var eventListenerThread: Thread?
    private var eventCallbacks: [ConnectionEventCallback] = []
    private let callbackQueue = DispatchQueue(label: "com.mousebridgehelper.events", attributes: .concurrent)
    
    static let shared = ConnectionEventManager()
    
    override private init() {
        super.init()
    }

    // MARK: - Event Registration

    /// Register a callback to be called when events arrive
    func onEvent(_ callback: @escaping ConnectionEventCallback) {
        callbackQueue.async(flags: .barrier) { [weak self] in
            self?.eventCallbacks.append(callback)
        }
    }

    // MARK: - Monitoring Control

    /// Start receiving connection events (blocking listener)
    func startMonitoring() {
        guard !isMonitoring else { return }

        // Set isMonitoring to true BEFORE starting the thread
        isMonitoring = true
        
        // Start event listening on a background thread (blocking)
        eventListenerThread = Thread { [weak self] in
            self?.listenForEvents()
        }
        eventListenerThread?.name = Constants.connectionEventListenerThreadName
        eventListenerThread?.start()
    }
    
    /// Stop receiving connection events
    func stopMonitoring() {
        guard isMonitoring else { return }

        // Set isMonitoring to false immediately
        isMonitoring = false
        // Reset connection status when stopping
        isConnected = false

        // Stop the listening thread
        eventListenerThread?.cancel()
        eventListenerThread = nil

        // Clear event callbacks to prevent accumulation
        eventCallbacks.removeAll()
    }
    
    /// Listen for events in a background thread (blocking call)
    private func listenForEvents() {
        while !Thread.current.isCancelled && isMonitoring {
            autoreleasepool {
                // This call blocks until an event is available
                let eventCString = GetConnectionEvent()

                if let eventCString = eventCString {
                    let eventString = String(cString: eventCString)

                    // Free the C string returned by the C function
                    free(eventCString)

                    if !eventString.isEmpty {
                        if let parsedEvent = self.parseEvent(eventString) {
                            self.callEventCallbacks(parsedEvent)
                        }
                    }
                }
            }
        }
    }
    
    /// Parse event string and call appropriate callbacks
    private func callEventCallbacks(_ event: ConnectionEvent) {
        callbackQueue.async { [weak self] in
            guard let self = self else { return }
            self.eventCallbacks.forEach { callback in
                callback(event)
            }
        }
    }

    // MARK: - Event Parsing

    /// Parse event string into ConnectionEvent struct
    private func parseEvent(_ eventString: String) -> ConnectionEvent? {
        guard !eventString.isEmpty else { return nil }

        let components = eventString.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)

        guard components.count >= 2 else { return nil }

        let eventTypeStr = String(components[0])
        let deviceID = String(components[1])

        guard !deviceID.isEmpty else { return nil }

        let details = components.count > 2 ? String(components[2]) : ""

        let eventType: ConnectionEvent.EventType = {
            switch eventTypeStr {
            case Constants.EventType.newPendingConnection:
                return .newPendingConnection
            case Constants.EventType.connectionApproved:
                return .connectionApproved
            case Constants.EventType.connectionRejected:
                return .connectionRejected
            case Constants.EventType.connectionDisconnected:
                return .connectionDisconnected
            default:
                return .unknown(eventTypeStr)
            }
        }()

        return ConnectionEvent(type: eventType, deviceID: deviceID, details: details)
    }

    // MARK: - Event Handling

    /// Handle a connection event
    func handleEvent(_ event: ConnectionEvent) {
        switch event.type {
        case .newPendingConnection:
            showApprovalDialog(deviceID: event.deviceID, details: event.details)
        case .connectionApproved:
            print("[ConnectionEventManager] Connection approved: \(event.deviceID)")
            isConnected = true
        case .connectionRejected:
            break
        case .connectionDisconnected:
            print("[ConnectionEventManager] Connection disconnected: \(event.deviceID)")
            isConnected = false
        case .unknown(let type):
            print("[ConnectionEventManager] Unknown event type: \(type)")
        }
    }

    // MARK: - UI Dialogs

    /// Show approval dialog for new pending connection
    private func showApprovalDialog(deviceID: String, details: String) {
        guard !deviceID.isEmpty else { return }

        // Dispatch to main thread since NSAlert must be created on main thread
        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = Constants.connectionRequestTitle
            alert.informativeText = details
            alert.addButton(withTitle: Constants.approveButton)
            alert.addButton(withTitle: Constants.rejectButton)
            alert.alertStyle = .informational

            let response = alert.runModal()

            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                self?.approveConnection(deviceID: deviceID)
            } else {
                self?.rejectConnection(deviceID: deviceID)
            }
        }
    }
    
    /// Approve a connection
    func approveConnection(deviceID: String) {
        guard !deviceID.isEmpty else { return }
        deviceID.withCString { ptr in
            ApproveConnection(UnsafeMutablePointer(mutating: ptr))
        }
    }

    /// Reject a connection
    func rejectConnection(deviceID: String) {
        guard !deviceID.isEmpty else { return }
        deviceID.withCString { ptr in
            RejectConnection(UnsafeMutablePointer(mutating: ptr))
        }
    }

    // MARK: - Connection Management

    func startService() {
        StartMulticast(Constants.multicastPort)
        StartUDP(Constants.udpPort, Constants.udpTimeout, true)
        startMonitoring()
    }
    
    func stopService() {
        StopMulticast()
        StopUDP()
        stopMonitoring()
    }

    func toggleService() {
        if isMonitoring {
            // Stop the service
            stopService()
        } else {
            // Start the service
            if AccessibilityHelper.ensurePermission() {
                // Register event callback before starting service
                onEvent { [weak self] event in
                    self?.handleEvent(event)
                }

                startService()
            }
        }
    }
    
}

