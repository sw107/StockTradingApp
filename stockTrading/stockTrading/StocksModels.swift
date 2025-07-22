import Foundation

struct StockQuote: Decodable {
    let stck_prpr: String
}

struct ApiResponse: Decodable {
    let output: StockQuote
}

struct TimestampedQuote: Identifiable {
    let id = UUID()
    let time: Date
    let quote: StockQuote
}

struct AggregatedPrice: Identifiable {
    var id: Date { minuteStart }
    var minuteStart: Date
    var index: Int
    var start: Double
    var end: Double
}

struct StockEntry {
    let name: String
    let code: String
}
