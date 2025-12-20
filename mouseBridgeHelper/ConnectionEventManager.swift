//
//  ConnectionEventManager.swift
//  mouseBridgeHelper
//
//  Created by Angshuman Barpujari on 12/21/25.
//

import Foundation
import SwiftUI
import Combine

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

class ConnectionEventManager: NSObject, ObservableObject {
    @Published var isMonitoring = false
    private var eventListenerThread: Thread?
    private var eventCallbacks: [ConnectionEventCallback] = []
    private let callbackQueue = DispatchQueue(label: "com.mousebridgehelper.events", attributes: .concurrent)
    public let objectWillChange = PassthroughSubject<Void, Never>()
    
    static let shared = ConnectionEventManager()
    
    override private init() {
        super.init()
    }
    
    /// Register a callback to be called when events arrive
    func onEvent(_ callback: @escaping ConnectionEventCallback) {
        callbackQueue.async(flags: .barrier) { [weak self] in
            self?.eventCallbacks.append(callback)
        }
    }
    
    /// Start receiving connection events (blocking listener)
    func startMonitoring() {
        guard !isMonitoring else { 
            print("[ConnectionEventManager] Already monitoring, skipping start")
            return 
        }
        
        print("[ConnectionEventManager] Starting event monitoring...")
        
        // Set isMonitoring to true BEFORE starting the thread
        isMonitoring = true
        
        // Start event listening on a background thread (blocking)
        eventListenerThread = Thread { [weak self] in
            self?.listenForEvents()
        }
        eventListenerThread?.name = "ConnectionEventListener"
        eventListenerThread?.start()
    }
    
    /// Stop receiving connection events
    func stopMonitoring() {
        guard isMonitoring else { 
            print("[ConnectionEventManager] Not monitoring, skipping stop")
            return 
        }
        
        print("[ConnectionEventManager] Stopping event monitoring...")
        
        // Set isMonitoring to false immediately
        isMonitoring = false
        
        // Stop the listening thread
        eventListenerThread?.cancel()
        eventListenerThread = nil
    }
    
    /// Listen for events in a background thread (blocking call)
    private func listenForEvents() {
        print("[ConnectionEventManager] listenForEvents() started")
        while !Thread.current.isCancelled && isMonitoring {
            autoreleasepool {
                print("[ConnectionEventManager] Calling GetConnectionEvent() (blocking)...")
                // This call blocks until an event is available
                let eventCString = GetConnectionEvent()
                
                if let eventCString = eventCString {
                    let eventString = String(cString: eventCString)
                    print("[ConnectionEventManager] Received event string: \(eventString)")
                    
                    // Free the C string returned by the C function
                    free(eventCString)
                    
                    if !eventString.isEmpty {
                        print("[ConnectionEventManager] Event string is not empty, parsing...")
                        if let parsedEvent = self.parseEvent(eventString) {
                            print("[ConnectionEventManager] Event parsed successfully: \(parsedEvent.type)")
                            self.callEventCallbacks(parsedEvent)
                        } else {
                            print("[ConnectionEventManager] Failed to parse event: \(eventString)")
                        }
                    } else {
                        print("[ConnectionEventManager] Event string is empty")
                    }
                } else {
                    print("[ConnectionEventManager] GetConnectionEvent() returned nil")
                }
            }
        }
        print("[ConnectionEventManager] listenForEvents() loop ended")
    }
    
    /// Parse event string and call appropriate callbacks
    private func callEventCallbacks(_ event: ConnectionEvent) {
        print("[ConnectionEventManager] Calling event callbacks for: \(event.type)")
        callbackQueue.async { [weak self] in
            guard let self = self else { 
                print("[ConnectionEventManager] Self is nil in callback")
                return 
            }
            print("[ConnectionEventManager] Total callbacks registered: \(self.eventCallbacks.count)")
            self.eventCallbacks.forEach { callback in
                print("[ConnectionEventManager] Executing callback...")
                callback(event)
            }
        }
    }
    
    /// Parse event string into ConnectionEvent struct
    private func parseEvent(_ eventString: String) -> ConnectionEvent? {
        print("[ConnectionEventManager] Parsing event string: \(eventString)")
        let components = eventString.split(separator: "|", maxSplits: 2, omittingEmptySubsequences: false)
        print("[ConnectionEventManager] Split into \(components.count) components")
        
        guard components.count >= 2 else { 
            print("[ConnectionEventManager] Not enough components (got \(components.count), need at least 2)")
            return nil 
        }
        
        let eventTypeStr = String(components[0])
        let deviceID = String(components[1])
        let details = components.count > 2 ? String(components[2]) : ""
        
        print("[ConnectionEventManager] Event type: \(eventTypeStr), Device ID: \(deviceID), Details: \(details)")
        
        let eventType: ConnectionEvent.EventType = {
            switch eventTypeStr {
            case "new_pending_connection":
                print("[ConnectionEventManager] Identified as newPendingConnection")
                return .newPendingConnection
            case "connection_approved":
                print("[ConnectionEventManager] Identified as connectionApproved")
                return .connectionApproved
            case "connection_rejected":
                print("[ConnectionEventManager] Identified as connectionRejected")
                return .connectionRejected
            case "connection_disconnected":
                print("[ConnectionEventManager] Identified as connectionDisconnected")
                return .connectionDisconnected
            default:
                print("[ConnectionEventManager] Identified as unknown: \(eventTypeStr)")
                return .unknown(eventTypeStr)
            }
        }()
        
        return ConnectionEvent(type: eventType, deviceID: deviceID, details: details)
    }
    
    /// Handle a connection event
    func handleEvent(_ event: ConnectionEvent) {
        print("[ConnectionEventManager] handleEvent called with type: \(event.type)")
        switch event.type {
        case .newPendingConnection:
            print("[ConnectionEventManager] Showing approval dialog for: \(event.deviceID)")
            showApprovalDialog(deviceID: event.deviceID, details: event.details)
        case .connectionApproved:
            print("[ConnectionEventManager] Connection approved: \(event.deviceID)")
        case .connectionRejected:
            print("[ConnectionEventManager] Connection rejected: \(event.deviceID)")
        case .connectionDisconnected:
            print("[ConnectionEventManager] Connection disconnected: \(event.deviceID)")
        case .unknown(let type):
            print("[ConnectionEventManager] Unknown event type: \(type)")
        }
    }
    
    /// Show approval dialog for new pending connection
    private func showApprovalDialog(deviceID: String, details: String) {
        print("[ConnectionEventManager] Creating approval dialog - Device: \(deviceID), Details: \(details)")
        
        // Dispatch to main thread since NSAlert must be created on main thread
        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = "New Connection Request"
            alert.informativeText = details
            alert.addButton(withTitle: "Approve")
            alert.addButton(withTitle: "Reject")
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
        deviceID.withCString { ptr in
            ApproveConnection(UnsafeMutablePointer(mutating: ptr))
        }
    }
    
    /// Reject a connection
    func rejectConnection(deviceID: String) {
        deviceID.withCString { ptr in
             RejectConnection(UnsafeMutablePointer(mutating: ptr))
        }
    }
}

