//
//  ContentView.swift
//  stockTrading
//
//  Created by 최승원 on 5/18/25.
//

import SwiftUI
import Charts

struct StockQuote: Decodable {
    let stck_prpr: String
    let stck_shrn_iscd: String
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



struct StockSearchResult: Identifiable, Decodable {
    var id: String { stck_shrn_iscd }
    let stck_shrn_iscd: String
    let hts_kor_isnm: String
}

struct StockSearchFullResponse: Decodable {
    let rt_cd: String
    let output: [StockSearchResult]?
}




struct ContentView: View {
    
    @State private var errorMessage: String = ""
    @State private var isFetchFailed: Bool = false
    
    @State private var stockNum: String = ""
    @State private var stockName: String = ""
    @State private var stockNumInput: String = ""
    @State private var prices: [TimestampedQuote] = []
    @State private var currentMinutePoints: [TimestampedQuote] = []
    @State private var aggregatedPrices: [AggregatedPrice] = []
    
    
    @State private var stockNameInput: String = ""
    @State private var searchResults: [StockSearchResult] = []

    
    
    @State private var currentMinuteStart: Date = Date()
    @State private var timer: Timer? = nil
    
    var currentOpenClose: (open: Double, close: Double)? {
        guard currentMinutePoints.count >= 2 else { return nil }
        let open = Double(currentMinutePoints.first?.quote.stck_prpr ?? "0") ?? 0
        let close = Double(currentMinutePoints.last?.quote.stck_prpr ?? "0") ?? 0
        return (open, close)
    }

    var liveBar: BarMark? {
        guard let oc = currentOpenClose else { return nil }
        return BarMark(
            x: .value("Index", aggregatedPrices.count),
            yStart: .value("Start", oc.open),
            yEnd: .value("End", oc.close)
        )
    }
    
    var body: some View {
        VStack (spacing : 20){
            HStack{ // MARK: Search Stock
                Text("Stock Number")
                    .font(.title2)
                    .padding()
                TextField("", text: $stockNumInput)
                    .frame(width: 150)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                    .padding()
                
                Button {
                    stockNum = stockNumInput
                } label: {
                    Image(systemName: "magnifyingglass")
                }

            }
            .padding()
    
            Divider()
            
            if(prices.isEmpty){
                Text("loading...")
                    .font(.title)
            }else {
                Text("\(prices.last!.quote.stck_prpr)")
                    .font(.title)
            }
            HStack{ // MARK: Chart
                ScrollViewReader { proxy in
                    ScrollView(.horizontal){
                        Chart {
                            ForEach(0..<10, id: \.self) { i in
                                if let bar = aggregatedPrices.first(where: { $0.index == i }) {
                                    BarMark(
                                        x: .value("Index", bar.index),
                                        yStart: .value("Start", bar.start),
                                        yEnd: .value("End", bar.end)
                                    )
                                    .foregroundStyle(bar.end > bar.start ? Color.green : Color.red)
                                }
                                else {
                                    RectangleMark(
                                        x: .value("Index", i),
                                        yStart: .value("Start", 0),
                                        yEnd: .value("End", 0.1)
                                    )
                                    .foregroundStyle(Color.white.opacity(0.2))
                                }
                            }

                            if let live = liveBar {
                                live
                            }
                        }
                        .frame(width: max(CGFloat(aggregatedPrices.count) * 20, 340), height: 200)
                        .padding()
                        .chartXAxis {
                            AxisMarks(values: [aggregatedPrices.count]) { value in
                                if let index = value.as(Int.self),
                                   index == aggregatedPrices.count,
                                   currentMinutePoints.count > 0 {
                                    let currentTime = floorToMinute(currentMinutePoints.last!.time)
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel {
                                        Text(currentTime, format: .dateTime.hour().minute().second())
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks {
                                AxisGridLine()
                                    .foregroundStyle(Color.gray)
                                AxisTick()
                                    .foregroundStyle(Color.gray)
                                AxisValueLabel()
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .chartYScale(domain: {
                            if let first = prices.first,
                               let base = Double(first.quote.stck_prpr) {
                                let lower = base * 0.95
                                let upper = base * 1.05
                                return lower...upper
                            } else {
                                return 0...1
                            }
                        }())
                    } // ScrollView(.horizontal)
                    .onChange(of: aggregatedPrices.count) {
                        withAnimation {
                            proxy.scrollTo(aggregatedPrices.count, anchor: .trailing)
                        }
                    }
                } // ScrollViewReader
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
            prices.removeAll()
            currentMinutePoints.removeAll()
            aggregatedPrices.removeAll()
            
            currentMinuteStart = floorToMinute(Date())
            
            isFetchFailed = false
        }
        .onDisappear { stopTimers() }
    }
    
    // MARK: Get Price
    func fetchPrice() {
        
        let urlStr = "https://openapi.koreainvestment.com:9443/uapi/domestic-stock/v1/quotations/inquire-price?fid_cond_mrkt_div_code=J&fid_input_iscd=\(stockNum)"

        guard let url = URL(string: urlStr) else {
            self.errorMessage = "URL 생성 실패"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AccessToken)", forHTTPHeaderField: "authorization")
        request.setValue(AppKey, forHTTPHeaderField: "appKey")
        request.setValue(AppSecret, forHTTPHeaderField: "appSecret")
        request.setValue("FHKST01010100", forHTTPHeaderField: "tr_id")

        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }

            do {
                let result = try JSONDecoder().decode(ApiResponse.self, from: data)
                let stock = result.output
                
                DispatchQueue.main.async {
                    isFetchFailed = false

                    let timestamped = TimestampedQuote(time: Date(), quote: stock)
                    prices.append(timestamped)
                    let minute = floorToMinute(timestamped.time)

                    if minute == currentMinuteStart {
                        // 같은 분 → 실시간 업데이트
                        currentMinutePoints.append(timestamped)
                    } else {
                        // 1분 경과 → 기존 막대 고정
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

                        // 새로운 분 시작
                        currentMinuteStart = minute
                        currentMinutePoints = [timestamped]
                    }
                }

            } catch {
                DispatchQueue.main.async {
                    isFetchFailed = true
                }
            }
        }.resume()
    }
    
    func floorToMinute(_ date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return Calendar.current.date(from: components) ?? date
    }
    
   
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
            if !isFetchFailed {
                fetchPrice()
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

