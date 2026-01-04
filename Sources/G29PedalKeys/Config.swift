import Foundation
import CoreGraphics

struct Config: Codable {
    var pedal: String = "clutch"
    var key: String = "d"
    var modifiers: [String] = ["control"]
    var pressThreshold: UInt8 = 50
    var releaseThreshold: UInt8 = 30
    var verbose: Bool = false

    // Computed property: pedal name to byte index
    var pedalIndex: Int {
        switch pedal.lowercased() {
        case "gas", "throttle", "accelerator": return 0
        case "brake": return 1
        case "clutch": return 2
        default: return 2
        }
    }

    // Computed property: key name to virtual key code
    var keyCode: CGKeyCode {
        Self.keyNameToCode[key.lowercased()] ?? 0x02  // Default to 'D'
    }

    // Computed property: modifier names to CGEventFlags
    var modifierFlags: CGEventFlags {
        var flags: CGEventFlags = []
        for mod in modifiers {
            if let flag = Self.modifierNameToFlag[mod.lowercased()] {
                flags.insert(flag)
            }
        }
        return flags
    }

    // Key name to CGKeyCode mapping (common keys)
    static let keyNameToCode: [String: CGKeyCode] = [
        "a": 0x00, "s": 0x01, "d": 0x02, "f": 0x03, "h": 0x04,
        "g": 0x05, "z": 0x06, "x": 0x07, "c": 0x08, "v": 0x09,
        "b": 0x0B, "q": 0x0C, "w": 0x0D, "e": 0x0E, "r": 0x0F,
        "y": 0x10, "t": 0x11, "1": 0x12, "2": 0x13, "3": 0x14,
        "4": 0x15, "6": 0x16, "5": 0x17, "9": 0x19, "7": 0x1A,
        "8": 0x1C, "0": 0x1D, "o": 0x1F, "u": 0x20, "i": 0x22,
        "p": 0x23, "l": 0x25, "j": 0x26, "k": 0x28, "n": 0x2D,
        "m": 0x2E, "space": 0x31, "return": 0x24, "tab": 0x30,
        "escape": 0x35, "delete": 0x33,
        "f1": 0x7A, "f2": 0x78, "f3": 0x63, "f4": 0x76,
        "f5": 0x60, "f6": 0x61, "f7": 0x62, "f8": 0x64,
        "f9": 0x65, "f10": 0x6D, "f11": 0x67, "f12": 0x6F
    ]

    // Modifier name to CGEventFlags mapping
    static let modifierNameToFlag: [String: CGEventFlags] = [
        "control": .maskControl,
        "ctrl": .maskControl,
        "command": .maskCommand,
        "cmd": .maskCommand,
        "option": .maskAlternate,
        "alt": .maskAlternate,
        "shift": .maskShift
    ]

    // Load configuration from file or use defaults
    static func load(from path: String? = nil) -> Config {
        let paths = [
            path,
            NSString(string: "~/.config/g29-pedal-keys/config.json").expandingTildeInPath,
            "./config.json"
        ].compactMap { $0 }

        for configPath in paths {
            if let data = FileManager.default.contents(atPath: configPath) {
                do {
                    let config = try JSONDecoder().decode(Config.self, from: data)
                    return config
                } catch {
                    fputs("Warning: Failed to parse \(configPath): \(error)\n", stderr)
                }
            }
        }

        return Config()
    }
}
