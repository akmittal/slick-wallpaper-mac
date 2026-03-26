import Foundation
import SQLite

// MARK: - QuoteService

final class QuoteService {
    static let shared = QuoteService()

    private var db: Connection?

    private let quotesTable = Table("quotes")
    private let catTable = Table("quotecat")

    private let colId = Expression<Int>("_id")
    private let colQuote = Expression<String>("quote")
    private let colAuthor = Expression<String>("author")
    private let colCatQuoteId = Expression<Int>("quoteid")
    private let colCategory = Expression<String>("category")

    init() {
        setupDatabase()
    }

    private func setupDatabase() {
        let dbURL = findDatabaseURL()
        guard let dbURL = dbURL else {
            print("[QuoteService] Could not find quoteitup.db in any known location")
            return
        }
        do {
            db = try Connection(dbURL.path, readonly: true)
            print("[QuoteService] Opened DB at: \(dbURL.path)")
        } catch {
            print("[QuoteService] Failed to open DB: \(error)")
        }
    }

    private func findDatabaseURL() -> URL? {
        let dbName = "quoteitup"
        let ext = "db"

        // 1. App bundle Resources/ (when packaged as .app)
        if let url = Bundle.main.url(forResource: dbName, withExtension: ext) {
            return url
        }

        // 3. Next to the executable (for dev testing)
        let execURL = Bundle.main.executableURL?
            .deletingLastPathComponent()
            .appendingPathComponent("\(dbName).\(ext)")
        if let execURL = execURL, FileManager.default.fileExists(atPath: execURL.path) {
            return execURL
        }

        return nil
    }

    func randomQuote(fromCategories categories: [String]) -> Quote? {
        let customQuotes = UserSettings.shared.customQuotes
        // Mix in custom quotes (20% chance if available)
        if !customQuotes.isEmpty && Int.random(in: 1...5) == 1 {
            return customQuotes.randomElement()
        }

        guard let db = db else { return customQuotes.randomElement() }

        do {
            // Join quotes with quotecat filtered by selected categories
            let catSubset = catTable.filter(categories.contains(colCategory))
            let joined = catSubset
                .join(quotesTable, on: colCatQuoteId == quotesTable[colId])
                .order(Expression<Int>.random())
                .limit(1)

            if let row = try db.pluck(joined) {
                let text = (try? row.get(quotesTable[colQuote])) ?? ""
                let author = (try? row.get(quotesTable[colAuthor])) ?? ""
                guard !text.isEmpty else { return nil }
                return Quote(text: text, author: author)
            }
        } catch {
            print("[QuoteService] Query error: \(error)")
        }
        return customQuotes.randomElement()
    }

    func allCategories() -> [String] {
        guard let db = db else { return UserSettings.allCategories }
        do {
            let query = catTable.select(distinct: colCategory).order(colCategory)
            return try db.prepare(query).compactMap { try? $0.get(colCategory) }
        } catch {
            return UserSettings.allCategories
        }
    }
}
