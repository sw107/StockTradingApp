//
//  StocksModels.swift
//  stockTrading
//
//  Created by 최승원 on 7/22/25.
//

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
    let id = UUID()
    let minuteStart: Date
    let index: Int
    let start: Double
    let end: Double
}

struct StockEntry {
    let name: String
    let code: String
}
