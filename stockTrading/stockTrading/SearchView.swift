//
//  SearchView.swift
//  stockTrading
//
//  Created by 최승원 on 9/21/25.
//

import SwiftUI

struct SearchView: View {
    
    @ObservedObject  var SearchVM: SearchViewModel
    let onSelect: (StockEntry) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack(){
            TextField("", text: $SearchVM.stockNameInput)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
                .padding()
            Button {
                let input = SearchVM.stockNameInput
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let match = SearchVM.stockList.first(where: {
                    $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        .localizedStandardContains(input)
                }) {
                    onSelect(match)
                    dismiss()
                } else {
                    SearchVM.errorMessage = "검색 결과 없음"
                }
                dismiss()
            } label: {
                Image(systemName: "magnifyingglass")
            }
        }
        .padding()
    }
}
#Preview {
    SearchView(SearchVM: SearchViewModel(), onSelect: { _ in })
}
