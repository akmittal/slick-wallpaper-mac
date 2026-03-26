import Foundation
import AppKit
import SQLite

// MARK: - Data Models

struct Quote {
    let id: Int
    let text: String
    let author: String
}

// MARK: - Update Interval

enum UpdateInterval: String, CaseIterable {
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

// MARK: - UserSettings

final class UserSettings: ObservableObject {
    static let shared = UserSettings()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let interval = "updateInterval"
        static let categories = "enabledCategories"
        static let fontFamily = "fontFamily"
        static let fontSize = "fontSize"
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
    }
}
