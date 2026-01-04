import Foundation
import IOKit
import IOKit.hid

class HIDManager {
    private var manager: IOHIDManager?
    private let vendorID: Int = 0x046D   // Logitech
    private let productID: Int = 0xC24F  // G29
    private let verbose: Bool

    var onPedalReport: (([UInt8]) -> Void)?

    init(verbose: Bool = false) {
        self.verbose = verbose
    }

    func start() -> Bool {
        // Create HID Manager
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        guard let manager = manager else {
            fputs("Error: Failed to create HID manager\n", stderr)
            return false
        }

        // Set device matching criteria
        let matchingDict: [String: Any] = [
            kIOHIDVendorIDKey as String: vendorID,
            kIOHIDProductIDKey as String: productID
        ]
        IOHIDManagerSetDeviceMatching(manager, matchingDict as CFDictionary)

        // Register callbacks
        let context = Unmanaged.passUnretained(self).toOpaque()

        IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, result, sender, device in
            guard let context = context else { return }
            let this = Unmanaged<HIDManager>.fromOpaque(context).takeUnretainedValue()
            this.deviceConnected(device)
        }, context)

        IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, result, sender, device in
            guard let context = context else { return }
            let this = Unmanaged<HIDManager>.fromOpaque(context).takeUnretainedValue()
            this.deviceDisconnected(device)
        }, context)

        IOHIDManagerRegisterInputReportCallback(manager, { context, result, sender, type, reportID, report, reportLength in
            guard let context = context else { return }
            let this = Unmanaged<HIDManager>.fromOpaque(context).takeUnretainedValue()
            this.inputReport(report: report, length: reportLength)
        }, context)

        // Schedule with run loop
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)

        // Open manager
        let result = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        if result != kIOReturnSuccess {
            fputs("Error: Failed to open HID manager (code: \(result))\n", stderr)
            fputs("Make sure Input Monitoring permission is granted.\n", stderr)
            return false
        }

        if verbose {
            fputs("HID Manager started, waiting for G29...\n", stderr)
        }

        return true
    }

    func stop() {
        if let manager = manager {
            IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
            if verbose {
                fputs("HID Manager stopped\n", stderr)
            }
        }
    }

    private func deviceConnected(_ device: IOHIDDevice) {
        let product = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String ?? "Unknown"
        fputs("Device connected: \(product)\n", stderr)
    }

    private func deviceDisconnected(_ device: IOHIDDevice) {
        fputs("Device disconnected\n", stderr)
    }

    private func inputReport(report: UnsafePointer<UInt8>, length: CFIndex) {
        // Convert to array
        var bytes = [UInt8](repeating: 0, count: length)
        for i in 0..<length {
            bytes[i] = report[i]
        }

        // Pass to callback
        onPedalReport?(bytes)
    }
}
