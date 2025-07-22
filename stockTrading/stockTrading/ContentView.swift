//
//  ContentView.swift
//  stockTrading
//
//  Created by 최승원 on 5/18/25.
//

import SwiftUI
import Charts

struct ContentView: View {
    
    @State private var isFetchFailed: Bool = false
    
    @State private var stockNameInput: String = ""
    @State private var stockList: [StockEntry] = []
    @State private var stockNum: String = ""
    @State private var stockName: String = ""
    @State private var errorMessage: String = ""
    
    @State private var aggregatedPrices: [AggregatedPrice] = []
    @State private var currentMinutePoints: [TimestampedQuote] = []
    @State private var prices: [TimestampedQuote] = []
    
    @State private var currentMinuteStart: Date = Date()
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack (spacing : 20){
            StockSearchView(
                stockNameInput: $stockNameInput,
                stockList: stockList,
                stockNum: $stockNum,
                stockName: $stockName,
                errorMessage: $errorMessage
            )
            
            Divider()
            
            if(prices.isEmpty){
                Text("loading...")
                    .font(.title)
            }else {
                Text("\(prices.last!.quote.stck_prpr)")
                    .font(.title)
            }
            HStack{ // MARK: Chart
                StockChartView(
                    aggregatedPrices: aggregatedPrices,
                    currentMinutePoints: currentMinutePoints,
                    prices: prices
                )
            }// HStack
            Divider()
            
            HStack(){  // MARK: trade button
                Button {
                    
                } label: {
                    Text("매수")
                        .foregroundColor(.black)
                        .font(.headline)
                        .frame(width: 150, height: 50, alignment: .center)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                Button{
                    
                } label: {
                    Text("매도")
                        .foregroundColor(.black)
                        .font(.headline)
                        .frame(width: 150, height: 50, alignment: .center)
                        .background(Color.red)
                        .cornerRadius(15)
                }
            }
            Spacer()
            
        }// body
        .onAppear {
            stockList = loadStockList()
            currentMinuteStart = floorToMinute(Date())
            requestAccessToken { token in
                if let token = token {
                    DispatchQueue.main.async{
                        AccessToken = token
                        startTimer()
                    }
                } else {
                    print("🔴 토큰 발급 실패")
                }
            }
        }
        .onChange(of: stockNum) {
            print("📌 stockNum 변경 감지됨 → \(stockNum)")

            stopTimers()
            startTimer()

            resetChartData()
            StockAPI.fetchPrice(for: stockNum) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let stock):
                        isFetchFailed = false

                        let timestamped = TimestampedQuote(time: Date(), quote: stock)
                        prices.append(timestamped)
                        let minute = floorToMinute(timestamped.time)

                        if minute == currentMinuteStart {
                            currentMinutePoints.append(timestamped)
                        } else {
                            if currentMinutePoints.count >= 2 {
                                let open = Double(currentMinutePoints.first?.quote.stck_prpr ?? "0") ?? 0
                                let close = Double(currentMinutePoints.last?.quote.stck_prpr ?? "0") ?? 0
                                let newBar = AggregatedPrice(
                                    minuteStart: currentMinuteStart,
                                    index: aggregatedPrices.count,
                                    start: open,
                                    end: close
                                )
                                aggregatedPrices.append(newBar)
                            }

                            currentMinuteStart = minute
                            currentMinutePoints = [timestamped]
                        }

                    case .failure(let error):
                        isFetchFailed = true
                        print("❌ 가격 불러오기 실패: \(error.localizedDescription)")
                    }
                }
            }
        }
        .onDisappear
        {
            stopTimers()
        }
    }

    
    func loadStockList() -> [StockEntry] {
            guard let path = Bundle.main.path(forResource: "stocksData", ofType: "csv"),
                  let content = try? String(contentsOfFile: path, encoding: .utf8) else {
                print("❌ 종목 리스트 로딩 실패")
                return []
            }

            let lines = content.split(separator: "\n").dropFirst()
            return lines.compactMap { line in
                let parts = line.split(separator: ",")
                guard parts.count >= 2 else { return nil }
                let name = String(parts[3]).trimmingCharacters(in: .whitespacesAndNewlines)
                let code = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                return StockEntry(name: name, code: code)            }
        }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
            if !isFetchFailed {
                StockAPI.fetchPrice(for: stockNum) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let stock):
                            isFetchFailed = false

                            let timestamped = TimestampedQuote(time: Date(), quote: stock)
                            prices.append(timestamped)
                            let minute = floorToMinute(timestamped.time)

                            if minute == currentMinuteStart {
                                currentMinutePoints.append(timestamped)
                            } else {
                                if currentMinutePoints.count >= 2 {
                                    let open = Double(currentMinutePoints.first?.quote.stck_prpr ?? "0") ?? 0
                                    let close = Double(currentMinutePoints.last?.quote.stck_prpr ?? "0") ?? 0
                                    let newBar = AggregatedPrice(
                                        minuteStart: currentMinuteStart,
                                        index: aggregatedPrices.count,
                                        start: open,
                                        end: close
                                    )
                                    aggregatedPrices.append(newBar)
                                }

                                currentMinuteStart = minute
                                currentMinutePoints = [timestamped]
                            }

                        case .failure(let error):
                            isFetchFailed = true
                            print("❌ 가격 불러오기 실패: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    func stopTimers() {
        timer?.invalidate()
    }
    
    
    func resetChartData() {
        prices.removeAll()
        currentMinutePoints.removeAll()
        aggregatedPrices.removeAll()
        currentMinuteStart = floorToMinute(Date())
    }
    
}

#Preview {
    ContentView()
}
