//
//  SearchViewModel.swift
//  stockTrading
//
//  Created by 최승원 on 9/21/25.
//

import Foundation

class SearchViewModel: ObservableObject {
    
    @Published var stockNameInput: String = ""
    @Published var stockList: [StockEntry] = []
    @Published var stockNum: String = ""
    @Published var stockName: String = ""
    @Published var errorMessage: String = ""
}
