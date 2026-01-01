import SwiftUI

@MainActor
final class WindowController {
    static let shared = WindowController()
    var openWindow: OpenWindowAction?
}
