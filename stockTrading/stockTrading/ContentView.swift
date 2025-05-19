//
//  ContentView.swift
//  stockTrading
//
//  Created by 최승원 on 5/18/25.
//

import SwiftUI
import Charts

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
    
    @State private var displayData: [chartData] = []
    @State private var updatePeriod: Double = 1.0
    @State private var timer: Timer? = nil
    @State private var index: Int = 0
    @State private var indexPlus: Int = 1
    @State private var xDomain = 0...100
    

    var body: some View {
        VStack (spacing : 20){
            HStack{ // MARK: chart
                ScrollView(.horizontal){
                    Chart(displayData) { item in
                        LineMark (
                            x: .value("time", item.time),
                            y: .value("price",item.price)
                        )
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
        HStack(){// MARK: updatePeriod Button
            Button {
                updatePeriod = 1
                indexPlus = 1
                xDomain = 0...100
                restartTimer()
            } label: {
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
                updatePeriod = 3
                indexPlus = 3
                xDomain = 0...150
                restartTimer()
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
                updatePeriod = 60
                indexPlus = 60
                xDomain = 0...500
                restartTimer()
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
        .onAppear {
            restartTimer()
        }
    } // body
    
    func restartTimer() {
        timer?.invalidate() // 기존 타이머 중지
        timer = Timer.scheduledTimer(withTimeInterval: updatePeriod, repeats: true) { _ in
            if index >= fullData.count {
                timer?.invalidate()
            } else {
                displayData.append(fullData[index])
                index += indexPlus
            }
        }
    }
    
} // ContentView

struct threesec: View {

    @Binding private var displayData: [chartData]
    @Binding private var updatePeriod: Double
    @Binding private var timer: Timer?
    @Binding private var index: Int
    @Binding private var indexPlus: Int
    @Binding private var xDomain: ClosedRange<Double>
    
    var body: some View {
        VStack (spacing : 20){
            HStack{ // MARK: chart
                ScrollView(.horizontal){
                    Chart(displayData) { item in
                        LineMark (
                            x: .value("time", item.time),
                            y: .value("price",item.price)
                        )
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
        HStack(){// MARK: updatePeriod Button
            Button {
                updatePeriod = 1
                indexPlus = 1
                xDomain = 0...100
                restartTimer()
            } label: {
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
                updatePeriod = 3
                indexPlus = 3
                xDomain = 0...150
                restartTimer()
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
                updatePeriod = 60
                indexPlus = 60
                xDomain = 0...500
                restartTimer()
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
        .onAppear {
            restartTimer()
        }
    } // body
    
    func restartTimer() {
        timer?.invalidate() // 기존 타이머 중지
        timer = Timer.scheduledTimer(withTimeInterval: updatePeriod, repeats: true) { _ in
            if index >= fullData.count {
                timer?.invalidate()
            } else {
                displayData.append(fullData[index])
                index += indexPlus
            }
        }
    }
}

struct oneMin: View {

    @Binding private var displayData: [chartData]
    @Binding private var updatePeriod: Double
    @Binding private var timer: Timer?
    @Binding private var index: Int
    @Binding private var indexPlus: Int
    @Binding private var xDomain: ClosedRange<Double>
    
    var body: some View {
        VStack (spacing : 20){
            HStack{ // MARK: chart
                ScrollView(.horizontal){
                    Chart(displayData) { item in
                        LineMark (
                            x: .value("time", item.time),
                            y: .value("price",item.price)
                        )
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
        HStack(){// MARK: updatePeriod Button
            Button {
                updatePeriod = 1
                indexPlus = 1
                xDomain = 0...100
                restartTimer()
            } label: {
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
                updatePeriod = 3
                indexPlus = 3
                xDomain = 0...150
                restartTimer()
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
                updatePeriod = 60
                indexPlus = 60
                xDomain = 0...500
                restartTimer()
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
        .onAppear {
            restartTimer()
        }
    } // body
    
    func restartTimer() {
        timer?.invalidate() // 기존 타이머 중지
        timer = Timer.scheduledTimer(withTimeInterval: updatePeriod, repeats: true) { _ in
            if index >= fullData.count {
                timer?.invalidate()
            } else {
                displayData.append(fullData[index])
                index += indexPlus
            }
        }
    }
}



#Preview {
    ContentView()
}
