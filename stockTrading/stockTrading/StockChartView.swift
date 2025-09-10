import SwiftUI
import Charts

struct StockChartView: View {
    let aggregatedPrices: [AggregatedPrice]
    let currentMinutePoints: [TimestampedQuote]
    let prices: [TimestampedQuote]

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
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                Chart {
                    ForEach(0..<10, id: \.self) { i in
                        if let bar = aggregatedPrices.first(where: { $0.index == i }) {
                            BarMark(
                                x: .value("Index", bar.index),
                                yStart: .value("Start", bar.start),
                                yEnd: .value("End", bar.end)
                            )
                            .foregroundStyle(bar.end > bar.start ? Color.green : Color.red)
                        } else {
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
                        let lower = base * 0.995
                        let upper = base * 1.005
                        return lower...upper
                    } else {
                        return 0...1
                    }
                }())
            }
            .onChange(of: aggregatedPrices.count) {
                withAnimation {
                    proxy.scrollTo(aggregatedPrices.count, anchor: .trailing)
                }
            }
        }
    }
}
