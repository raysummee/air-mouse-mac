//
//  AccessibilityHelper.swift
//  mouseBridgeHelper
//
//  Created by Angshuman Barpujari on 11/9/25.
//

import Cocoa
import ApplicationServices

@MainActor
class AccessibilityHelper {

    /// Ensures the app has Accessibility permission.
    /// Shows the system prompt first. If permission is denied, shows a helpful custom alert.
    @discardableResult
    static func ensurePermission(showAlert: Bool = true) -> Bool {
        // Bring app to front so system dialog is visible
        NSApp.activate(ignoringOtherApps: true)

        // Trigger the system Accessibility dialog
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)

        if trusted {
            print("✅ Accessibility access granted.")
            return true
        } else {
            print("⚠️ Accessibility access not granted.")

            // Show custom alert **after a short delay**, so the system dialog appears first
            if showAlert {
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.accessibilityAlertDelay) {
                    showAccessibilityAlert()
                }
            }
            return false
        }
    }

    /// Opens System Settings → Privacy & Security → Accessibility
    private static func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Shows a custom alert guiding the user to enable Accessibility permission
    private static func showAccessibilityAlert() {
        let alert = NSAlert()
        alert.messageText = Constants.accessibilityNeededTitle
        alert.informativeText = Constants.accessibilityNeededMessage
        alert.alertStyle = .warning
        alert.addButton(withTitle: Constants.openSettingsButton)
        alert.addButton(withTitle: Constants.cancelButton)

        // Ensure alert is frontmost
        NSApp.activate(ignoringOtherApps: true)

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            openAccessibilitySettings()
        }
    }
}

