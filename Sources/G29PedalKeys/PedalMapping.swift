import Foundation

class PedalMapping {
    private let pedalIndex: Int
    private let pressThreshold: UInt8
    private let releaseThreshold: UInt8
    private let keySimulator: KeySimulator
    private let verbose: Bool

    private var isPressed: Bool = false

    init(config: Config, keySimulator: KeySimulator) {
        self.pedalIndex = config.pedalIndex
        self.pressThreshold = config.pressThreshold
        self.releaseThreshold = config.releaseThreshold
        self.keySimulator = keySimulator
        self.verbose = config.verbose
    }

    func processReport(_ report: [UInt8]) {
        // G29 pedals report format varies by mode
        // Common format: bytes represent pedal positions (0-255)
        // The exact byte index depends on the HID report descriptor
        // Typically: gas at lower index, brake middle, clutch higher

        // We need to find the right byte for the pedal
        // Let's try multiple possible layouts
        let pedalValue: UInt8

        // The G29 sends different report formats depending on mode
        // Report length helps identify the format
        if report.count >= 12 {
            // Full wheel+pedals report (common format)
            // Bytes 6, 7, 8 are often gas, brake, clutch (inverted: 255 = released, 0 = pressed)
            let baseIndex = 6 + pedalIndex
            if baseIndex < report.count {
                // Invert: G29 sends 255 when released, 0 when fully pressed
                pedalValue = 255 - report[baseIndex]
            } else {
                return
            }
        } else if report.count >= 3 {
            // Short pedal-only report
            if pedalIndex < report.count {
                pedalValue = 255 - report[pedalIndex]
            } else {
                return
            }
        } else {
            return
        }

        if verbose {
            fputs("Pedal[\(pedalIndex)] = \(pedalValue)\n", stderr)
        }

        // State machine with hysteresis
        if !isPressed && pedalValue > pressThreshold {
            isPressed = true
            keySimulator.pressKey()
            if verbose {
                fputs("Pedal PRESSED (value: \(pedalValue))\n", stderr)
            }
        } else if isPressed && pedalValue < releaseThreshold {
            isPressed = false
            keySimulator.releaseKey()
            if verbose {
                fputs("Pedal RELEASED (value: \(pedalValue))\n", stderr)
            }
        }
    }
}
