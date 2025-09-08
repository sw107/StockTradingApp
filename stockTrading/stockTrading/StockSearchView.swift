import Foundation
import SwiftUI

struct StockSearchView: View {
    @Binding var stockNameInput: String
    let stockList: [StockEntry]
    @Binding var stockNum: String
    @Binding var stockName: String
    @Binding var errorMessage: String

    var body: some View {
        HStack {
            TextField("", text: $stockNameInput)
                .frame(maxWidth: 500)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
                .padding()
            Button {
                let input = stockNameInput
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if let match = stockList.first(where: {
                    $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        .localizedStandardContains(input)
                }) {
                    stockNum = match.code
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "\"", with: "")
                    stockName = match.name
                } else {
                    errorMessage = "검색 결과 없음"
                }
            } label: {
                Image(systemName: "magnifyingglass")
            }
        }
        .padding()
    }
}
