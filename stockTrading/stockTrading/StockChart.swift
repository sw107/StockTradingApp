import SwiftUI
import Charts

struct StockChart: View {
    let aggregatedPrices: [AggregatedPrice]
    let currentMinutePoints: [TimestampedQuote]
    let prices: [TimestampedQuote]

    var currentOpenClose: (open: Double, close: Double)? {
        guard currentMinutePoints.count >= 2 else { return nil }
        let open = Double(currentMinutePoints.first?.quote.stck_prpr ?? "0") ?? 0
        let close = Double(currentMinutePoints.last?.quote.stck_prpr ?? "0") ?? 0
        return (open, close)
    }

    private var basePrice: Double {
        if let first = prices.first, let v = Double(first.quote.stck_prpr) { return v }
        if let last = prices.last, let v = Double(last.quote.stck_prpr) { return v }
        if let lastAgg = aggregatedPrices.last { return (lastAgg.start + lastAgg.end) / 2 }
        return 0
    }
    private func epsilon(for base: Double) -> Double {
        // 최소 1원 또는 기준가의 0.1%
        return max(base * 0.001, 1.0)
    }
    private func adjusted(_ s: Double, _ e: Double, base: Double) -> (Double, Double) {
        let d = abs(e - s)
        let eps = epsilon(for: base)
        if d < eps {
            let half = eps / 2
            return (s - half, e + half)
        }
        return (s, e)
    }

    // 막대 두께 비율(기준): 1.0이면 슬롯을 꽉 채움, 값이 작을수록 얇아짐
    private let slotWidthRatio: Double = 0.8
    // 기준 한 화면 슬롯 수(기준): 고정 폭에서 이 수와 slotWidthRatio 조합이 현재 막대의 픽셀 두께를 결정
    private let baseVisibleSlots: Int = 30
    // 간격 축소 비율(0~1): 1.0이면 기존 간격, 0.0이면 간격 0에 가깝게
    private let gapScale: Double = 0.2

    // 계산된 유효 막대폭 비율: 막대 픽셀 두께를 유지하면서 간격만 gapScale배로 줄이기 위해 조정
    private var effectiveSlotWidthRatio: Double {
        let w0 = max(0.0001, min(slotWidthRatio, 1.0))
        let g  = max(0.0,     min(gapScale,       1.0))
        // w = w0 / (w0 + g*(1 - w0))  (g=1 => w=w0, g=0 => w=1)
        return w0 / (w0 + g * (1.0 - w0))
    }

    // 계산된 유효 슬롯 수: 막대 픽셀 두께를 유지하기 위해 visibleSlots도 함께 비례 조정 (N' = N0 * w'/w0)
    private var effectiveVisibleSlots: Int {
        let w0 = max(0.0001, min(slotWidthRatio, 1.0))
        let w  = effectiveSlotWidthRatio
        let n0 = max(1, baseVisibleSlots)
        return max(1, Int(round(Double(n0) * w / w0)))
    }

    @ChartContentBuilder
    var liveBar: some ChartContent {
        if let oc = currentOpenClose {
            let (lys, lye) = adjusted(oc.open, oc.close, base: basePrice)
            let w = effectiveSlotWidthRatio
            let cx = Double(aggregatedPrices.count)
            let x0 = cx + (1.0 - w) / 2.0
            let x1 = cx + (1.0 + w) / 2.0
            RectangleMark(
                xStart: .value("XStart", x0),
                xEnd: .value("XEnd", x1),
                yStart: .value("Start", lys),
                yEnd: .value("End", lye)
            )
        }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                Chart {
                    ForEach(0..<effectiveVisibleSlots, id: \.self) { i in
                        if let bar = aggregatedPrices.first(where: { $0.index == i }) {
                            let (ys, ye) = adjusted(bar.start, bar.end, base: basePrice)
                            let w = effectiveSlotWidthRatio
                            let x0 = Double(i) + (1.0 - w) / 2.0
                            let x1 = Double(i) + (1.0 + w) / 2.0
                            RectangleMark(
                                xStart: .value("XStart", x0),
                                xEnd: .value("XEnd", x1),
                                yStart: .value("Start", ys),
                                yEnd: .value("End", ye)
                            )
                            .foregroundStyle(bar.end > bar.start ? Color.green : Color.red)
                        } else {
                            let w = effectiveSlotWidthRatio
                            let x0 = Double(i) + (1.0 - w) / 2.0
                            let x1 = Double(i) + (1.0 + w) / 2.0
                            RectangleMark(
                                xStart: .value("XStart", x0),
                                xEnd: .value("XEnd", x1),
                                yStart: .value("Start", 0),
                                yEnd: .value("End", 0.1)
                            )
                            .foregroundStyle(Color.white.opacity(0.2))
                        }
                    }

                    liveBar
                }
                // 고정 폭으로 압축해 보이는 슬롯 수를 늘리면서 간격 픽셀 폭을 줄임
                .frame(width: 340, height: 200)
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
                        let lower = base * 0.99
                        let upper = base * 1.045
                        return lower...upper
                    } else {
                        return 0...1
                    }
                }())
                .chartXScale(domain: 0.0...Double(effectiveVisibleSlots))
            }
            .onChange(of: aggregatedPrices.count) {
                withAnimation {
                    proxy.scrollTo(aggregatedPrices.count, anchor: .trailing)
                }
            }
        }
    }
}
