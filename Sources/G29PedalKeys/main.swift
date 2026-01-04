import Foundation
import ApplicationServices

// Parse command line arguments
var configPath: String? = nil
var verbose = false
var showHelp = false

var args = CommandLine.arguments.dropFirst()
while let arg = args.first {
    args = args.dropFirst()
    switch arg {
    case "-v", "--verbose":
        verbose = true
    case "-c", "--config":
        configPath = args.first
        args = args.dropFirst()
    case "-h", "--help":
        showHelp = true
    default:
        break
    }
}

if showHelp {
    print("""
    g29-pedal-keys - Map G29 pedals to keyboard keys

    Usage: g29-pedal-keys [options]

    Options:
      -v, --verbose       Enable verbose logging
      -c, --config PATH   Load configuration from PATH
      -h, --help          Show this help message

    Configuration:
      Default config location: ~/.config/g29-pedal-keys/config.json

      Example config.json:
      {
        "pedal": "clutch",
        "key": "d",
        "modifiers": ["control"],
        "pressThreshold": 50,
        "releaseThreshold": 30
      }

    Permissions required:
      - Input Monitoring (for HID device access)
      - Accessibility (for keyboard simulation)

    Grant permissions in: System Settings > Privacy & Security
    """)
    exit(0)
}

// Load configuration
var config = Config.load(from: configPath)
if verbose {
    config.verbose = true
}

// Check Accessibility permission
if !AXIsProcessTrusted() {
    fputs("Error: Accessibility permission not granted.\n", stderr)
    fputs("Grant permission in: System Settings > Privacy & Security > Accessibility\n", stderr)

    // Optionally prompt to open settings
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
    AXIsProcessTrustedWithOptions(options)

    exit(1)
}

// Print startup info
fputs("g29-pedal-keys starting...\n", stderr)
fputs("Pedal: \(config.pedal) (index \(config.pedalIndex))\n", stderr)
fputs("Key: \(config.key) (code \(config.keyCode)) + modifiers \(config.modifiers)\n", stderr)
fputs("Thresholds: press > \(config.pressThreshold), release < \(config.releaseThreshold)\n", stderr)

// Initialize components
let keySimulator = KeySimulator(
    keyCode: config.keyCode,
    modifiers: config.modifierFlags,
    verbose: config.verbose
)

let pedalMapping = PedalMapping(config: config, keySimulator: keySimulator)

let hidManager = HIDManager(verbose: config.verbose)
hidManager.onPedalReport = { report in
    pedalMapping.processReport(report)
}

// Set up signal handling for graceful shutdown
signal(SIGINT) { _ in
    fputs("\nShutting down...\n", stderr)
    exit(0)
}
signal(SIGTERM) { _ in
    fputs("\nShutting down...\n", stderr)
    exit(0)
}

// Start HID manager
guard hidManager.start() else {
    exit(1)
}

fputs("Running... Press Ctrl+C to stop.\n", stderr)

// Run the main loop (blocks forever)
RunLoop.main.run()
