//
//  ContentView.swift
//  stockTrading
//
//  Created by 최승원 on 5/18/25.
//

import SwiftUI
import Charts

let appKey: String = ""
let appSecret: String = ""
let token: String = ""

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

struct chartData: Identifiable {
    var id = UUID()
    var time: Int
    var price: Int
}


let fullData: [chartData] = (0..<1000).map { i in
    chartData(
        time: i,
        price: Int.random(in: 100...200)
    )
}

struct ContentView: View {
    
    struct chartData: Identifiable {
        var id = UUID()
        var time: Int
        var price: Int
    }
    
    
    let fullData: [chartData] = (0..<1000).map { i in
        chartData(
            time: i,
            price: Int.random(in: 100...200)
        )
    }
    
    @State private var errorMessage: String = ""
    @State private var prices: [TimestampedQuote] = []
    
    
    @State private var timer: Timer? = nil
    @State private var index1: Int = 0
    @State private var index2: Int = 0
    @State private var index3: Int = 0
    @State private var xDomain = 0...100
    
    @State private var chartOneSec: [chartData] = []
    @State private var chartThreeSec: [chartData] = []
    @State private var chartOneMin: [chartData] = []
    
    @State private var timerOneSec: Timer?
    @State private var timerThreeSec: Timer?
    @State private var timerOneMin: Timer?
    
    @State private var t1 = 0
    @State private var t2 = 0
    @State private var t3 = 0
    
    @State private var selectedChartIndex = 0
    
    var body: some View {
        VStack (spacing : 20){
            HStack{ // MARK: chart
                ScrollView(.horizontal){
                    Chart(selectChart()) { item in
                        LineMark (
                            x: .value("time", item.time),
                            y: .value("price",item.price)
                        )
                        PointMark(
                            x: .value("time", item.time),
                            y: .value("price",item.price)
                        )
                        .symbolSize(20)
                    }
                    .chartXScale(domain: xDomain)
                    .chartYScale(domain: 50...250)
                    .chartYAxis {
                        AxisMarks {
                            AxisGridLine()
                                .foregroundStyle(Color.gray)
                            AxisTick()
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .chartXAxis {
                        AxisMarks {
                            AxisGridLine()
                                .foregroundStyle(Color.gray)
                            AxisTick()
                                .foregroundStyle(Color.gray)
                            AxisValueLabel()
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .frame(width: 500,height: 200)
                    .padding()
                }
                VStack(spacing:33){
                    Text("250")
                    Text("200")
                    Text("150")
                    Text("150")
                    Text(" ")
                }
                .font(.caption)
                .frame(width:35)
                .foregroundColor(Color.gray)
            }
            .background{
                //                Color.black
            }
        }
        HStack(){// MARK: change period Button
            Button {
                selectedChartIndex = 0
            }
            label: {
                Text("1초")
                    .font(.caption)
                    .bold()
                    .foregroundColor(Color.black)
                    .frame(width:35, height:25)
                    .padding(.horizontal, 1)
                    .background{
                        Color.blue
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
            } // 1초 button
            
            Button {
                selectedChartIndex = 1
            } label: {
                Text("3초")
                    .font(.caption)
                    .bold()
                    .foregroundColor(Color.black)
                    .frame(width:35, height:25)
                    .padding(.horizontal, 1)
                    .background{
                        Color.blue
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
            } // 3초 button
            
            Button {
                selectedChartIndex = 2
            } label: {
                Text("1분")
                    .font(.caption)
                    .bold()
                    .foregroundColor(Color.black)
                    .frame(width:35, height:25)
                    .padding(.horizontal, 1)
                    .background{
                        Color.blue
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
            } // 1분 button
            Spacer()
        }
        .padding()
        .background{
            //            Color.black
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimers()
        }
        
        Divider()
        
        switch selectedChartIndex {
        case 0 : Text("current data : \(fullData[index1].price)")
        case 1 : Text("current data : \(fullData[index2].price)")
        case 2 : Text("current data : \(fullData[index3].price)")
        default: Text("")
        }
    }
    
    
    func fetchPrice() {
        
        let urlStr = "https://openapi.koreainvestment.com:9443/uapi/domestic-stock/v1/quotations/inquire-price?fid_cond_mrkt_div_code=J&fid_input_iscd=005930"

        guard let url = URL(string: urlStr) else {
            self.errorMessage = "URL 생성 실패"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "authorization")
        request.setValue(appKey, forHTTPHeaderField: "appKey")
        request.setValue(appSecret, forHTTPHeaderField: "appSecret")
        request.setValue("FHKST01010100", forHTTPHeaderField: "tr_id")

        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }

            do {
                let result = try JSONDecoder().decode(ApiResponse.self, from: data)
                let stock = result.output

                DispatchQueue.main.async {
                    let timestamped = TimestampedQuote(time: Date(), quote: stock)
                    prices.append(timestamped)
                }

            } catch {
                print("❌ 파싱 실패")
            }
        }.resume()
    }

    
    // MARK: Chart print func
    func selectChart() -> [chartData]{
        switch selectedChartIndex {
        case 0 : return chartOneSec
        case 1 : return chartThreeSec
        case 2 : return chartOneMin
        default : return []
        }
    }
    
    func startTimer() {
        
        chartOneSec.append(fullData[index1])      // index1 = 0
        chartThreeSec.append(fullData[index2])    // index2 = 0
        chartOneMin.append(fullData[index3])      // index3 = 0
        
        index1 += 1
        index2 += 3
        index3 += 60
        t1 = 1
        t2 = 3
        t3 = 60
        
        timerOneSec = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ _ in
            if index1 >= fullData.count {
                timer?.invalidate()
            } else {
                chartOneSec.append(fullData[index1])
                index1 += 1
                t1 += 1
            }
        }
        timerThreeSec = Timer.scheduledTimer(withTimeInterval: 3, repeats: true){ _ in
            if index2 >= fullData.count {
                timer?.invalidate()
            } else {
                chartThreeSec.append(fullData[index2])
                index2 += 3
                t2 += 3
            }
        }
        timerOneMin = Timer.scheduledTimer(withTimeInterval: 60, repeats: true){ _ in
            if index3 >= fullData.count {
                timer?.invalidate()
            } else {
                chartOneMin.append(fullData[index3])
                index3 += 60
                t3 += 60
            }
        }
    }
    func stopTimers() {
        timerOneSec?.invalidate()
        timerThreeSec?.invalidate()
        timerOneMin?.invalidate()
    }
}


#Preview {
    ContentView()
}

