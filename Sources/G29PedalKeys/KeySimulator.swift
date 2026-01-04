import Foundation
import CoreGraphics

class KeySimulator {
    private let keyCode: CGKeyCode
    private let modifiers: CGEventFlags
    private let verbose: Bool

    init(keyCode: CGKeyCode, modifiers: CGEventFlags, verbose: Bool = false) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.verbose = verbose
    }

    func pressKey() {
        // Create key down event
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else {
            fputs("Error: Failed to create key down event\n", stderr)
            return
        }

        // Apply modifiers
        event.flags = modifiers

        // Post to system
        event.post(tap: .cghidEventTap)

        if verbose {
            fputs("Key down: \(keyCode) with modifiers \(modifiers.rawValue)\n", stderr)
        }
    }

    func releaseKey() {
        // Create key up event
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else {
            fputs("Error: Failed to create key up event\n", stderr)
            return
        }

        // Apply modifiers (important for consistency)
        event.flags = modifiers

        // Post to system
        event.post(tap: .cghidEventTap)

        if verbose {
            fputs("Key up: \(keyCode) with modifiers \(modifiers.rawValue)\n", stderr)
        }
    }

    // Convenience: press and release in one call
    func tapKey() {
        pressKey()
        usleep(10000)  // 10ms delay
        releaseKey()
    }
}
