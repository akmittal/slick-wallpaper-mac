import Foundation
import AppKit
import SQLite

// MARK: - Data Models

struct Quote: Codable, Identifiable, Hashable {
    var id: String { "\(text)-\(author)" }
    let text: String
    let author: String
}

// MARK: - Update Interval

enum UpdateInterval: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case oneHour = "1 Hour"
    case sixHours = "6 Hours"
    case daily = "Daily"
    case weekly = "Weekly"

    var seconds: TimeInterval {
        switch self {
        case .oneHour: return 3600
        case .sixHours: return 21600
        case .daily: return 86400
        case .weekly: return 604800
        }
    }
}

// MARK: - App Features Enums

enum QuotePlacement: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case center = "Center"
    case bottomLeft = "Bottom Left"
    case topRight = "Top Right"
}

enum MultiMonitorMode: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case mirrored = "Mirrored (Same Quote)"
    case unique = "Unique (Different Quotes)"
}

// MARK: - UserSettings

final class UserSettings: ObservableObject {
    static let shared = UserSettings()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let interval = "updateInterval"
        static let categories = "enabledCategories"
        static let fontFamily = "fontFamily"
        static let fontSize = "fontSize"
        static let customPalettes = "customPalettes"
        static let backdropOpacity = "backdropOpacity"
        static let quotePlacement = "quotePlacement"
        static let customQuotes = "customQuotes"
        static let multiMonitorMode = "multiMonitorMode"
        static let syncDarkMode = "syncDarkMode"
    }

    @Published var interval: UpdateInterval {
        didSet { defaults.set(interval.rawValue, forKey: Keys.interval) }
    }

    @Published var enabledCategories: [String] {
        didSet { defaults.set(enabledCategories, forKey: Keys.categories) }
    }

    @Published var fontFamily: String {
        didSet { defaults.set(fontFamily, forKey: Keys.fontFamily) }
    }

    @Published var fontSize: CGFloat {
        didSet { defaults.set(Double(fontSize), forKey: Keys.fontSize) }
    }

    // --- V2 Customizations ---

    @Published var customPalettes: [[String]] {
        didSet { defaults.set(customPalettes, forKey: Keys.customPalettes) }
    }

    @Published var backdropOpacity: Double {
        didSet { defaults.set(backdropOpacity, forKey: Keys.backdropOpacity) }
    }

    @Published var quotePlacement: QuotePlacement {
        didSet { defaults.set(quotePlacement.rawValue, forKey: Keys.quotePlacement) }
    }

    @Published var customQuotes: [Quote] {
        didSet {
            if let data = try? JSONEncoder().encode(customQuotes) {
                defaults.set(data, forKey: Keys.customQuotes)
            }
        }
    }

    @Published var multiMonitorMode: MultiMonitorMode {
        didSet { defaults.set(multiMonitorMode.rawValue, forKey: Keys.multiMonitorMode) }
    }

    @Published var syncDarkMode: Bool {
        didSet { defaults.set(syncDarkMode, forKey: Keys.syncDarkMode) }
    }

    static let allCategories: [String] = [
        "inspiration", "motivation", "success", "wisdom", "life",
        "happiness", "love", "friendship", "humor", "philosophy",
        "hope", "truth", "knowledge", "poetry", "soul", "mind",
        "purpose", "science", "faith", "education"
    ]

    init() {
        let rawInterval = defaults.string(forKey: Keys.interval) ?? ""
        self.interval = UpdateInterval(rawValue: rawInterval) ?? .daily

        let savedCategories = defaults.stringArray(forKey: Keys.categories)
        self.enabledCategories = savedCategories ?? ["inspiration", "motivation", "wisdom", "life", "success"]

        self.fontFamily = defaults.string(forKey: Keys.fontFamily) ?? "Georgia"
        let savedFontSize = defaults.double(forKey: Keys.fontSize)
        self.fontSize = savedFontSize > 0 ? CGFloat(savedFontSize) : 52

        // V2 Decoding
        self.customPalettes = defaults.object(forKey: Keys.customPalettes) as? [[String]] ?? []
        let rawOpacity = defaults.object(forKey: Keys.backdropOpacity)
        self.backdropOpacity = rawOpacity != nil ? defaults.double(forKey: Keys.backdropOpacity) : 0.38

        let rawPlacement = defaults.string(forKey: Keys.quotePlacement) ?? ""
        self.quotePlacement = QuotePlacement(rawValue: rawPlacement) ?? .center

        if let data = defaults.data(forKey: Keys.customQuotes),
           let decoded = try? JSONDecoder().decode([Quote].self, from: data) {
            self.customQuotes = decoded
        } else {
            self.customQuotes = []
        }

        let rawMonitor = defaults.string(forKey: Keys.multiMonitorMode) ?? ""
        self.multiMonitorMode = MultiMonitorMode(rawValue: rawMonitor) ?? .mirrored

        let rawSync = defaults.object(forKey: Keys.syncDarkMode)
        self.syncDarkMode = rawSync != nil ? defaults.bool(forKey: Keys.syncDarkMode) : true
    }
}
