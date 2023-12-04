//
//  WeekView.swift
//  caly
//
//  Created by Cristian Cretu on 04.12.2023.
//

import SwiftUI

struct WeekView: View {
    @State private var days = currentWeek()
    private var todayID: UUID {
        return days.first(where: { $0.number == String(format: "%02d", Calendar.current.component(.day, from: Date())) })?.id ?? UUID()
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 10) {
                    ForEach(days) { day in
                        DayView(day: day)
                            .id(day.id)
                    }
                }
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            self.days = currentWeek()
        }
    }
}

struct InfiniteScrollingWeekView: View {
    private let rowSize: CGSize = CGSize(width: 100, height: 120)
    private let startDate = Date()
    @State private var offsetValue: ScrollOffsetValue = ScrollOffsetValue()
    @State private var days = currentWeek()
    @State private var centeredDate: Date = Date() // This will hold the date at the center
    
    @State private var scrollOffset = CGFloat.zero
    @State private var activeIndex = 0 // This would start from the current day index
    
    private var currentMonthAndYear: String {
            // Assuming that the startDate is the first day of the current week
            // Adjust this logic if that's not the case
            let calendar = Calendar.current
            let currentDate = calendar.date(byAdding: .day, value: activeIndex, to: startDate)!
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy MMMM"
            return formatter.string(from: currentDate)
        }


    private var todayID: UUID {
       return days.first(where: { $0.number == String(format: "%02d", Calendar.current.component(.day, from: Date())) })?.id ?? UUID()
   }

    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment: .leading) {
                Text(currentMonthAndYear)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 48)
            .padding(.vertical, 36)

            
            
            ZStack (alignment: .center) {
                GeometryReader { proxyP in
                    ScrollView(.horizontal, showsIndicators: false) {
                        ZStack {
                            LazyHStack {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: proxyP.size.width * 0.3)

                                ForEach(days.indices, id: \.self) { index in
                                    GeometryReader { proxyC in
                                        let rect = proxyC.frame(in: .named("scroll"))
                                        let x = rect.minX
                                        let curveY = getCurveValue(x, proxyP.size.width) * rowSize.width / 10
                                        let opacity = getAlphaValue(x, proxyP.size.width)

                                        DayView(day: days[index])
                                                .frame(width: self.rowSize.width, height: self.rowSize.height)
                                                .id(days[index].id)
                                            .opacity(opacity)
                                            .offset(y: curveY)
                                            .rotationEffect(.degrees(getRotateValue(x, proxyP.size.width) * 1.2), anchor: .trailing)
                                            .frame(width: rowSize.width, height: rowSize.height)
                                    }
                                    .frame(width: rowSize.width, height: rowSize.height)
                                }

                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: max(proxyP.size.width * 0.3, 50))
                            }
                            .offset(y: -proxyP.size.height / 8)

                        }
                    }
                    .modifier(OffsetOutScrollModifier(offsetValue: $offsetValue, named: "scroll"))
                    .padding()
                }
                
            }
        }
    }
    
    private func updateCenteredDate(from offsetValue: ScrollOffsetValue) {
        // Implement logic to determine which date is at the center based on the offset
        // This is a complex calculation and might need custom logic based on your view's layout
        // For demonstration, let's just set it to the current date
        self.centeredDate = Date()
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM"
        return formatter
    }
    
    private func getYearAndMonth(from day: Day) -> String {
        // Assuming that your Day struct can provide a Date object
//        let date = day. // Replace with actual code to get the Date from Day

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MMMM" // Format: "2023 March"
//        return dateFormatter.string(from: date)
        return "ass"
    }
    
    private func getAlphaValue(_ current: Double, _ total: Double) -> CGFloat {
        let x = Double(current) / Double(total)
        let y = (sin(-1.1 * (.pi * x) - .pi / 1))
        return CGFloat(y)
    }

    private func getCurveValue(_ current: Double, _ total: Double) -> CGFloat {
        let x = Double(current) / Double(total)
        let y = (sin(-1 * .pi * x - .pi) + 0.5) / 2.0
        return 2 * CGFloat(y)
    }

    private func getRotateValue(_ current: Double, _ total: Double) -> CGFloat {
        let x = Double(current) / Double(total)
        let y = (sin(.pi * x - (.pi / 2.0))) / 2.0
        return CGFloat(y)
    }
}


fileprivate
struct ScrollOffsetValue: Equatable {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var contentSize: CGSize = .zero
}

fileprivate
struct ScrollOffsetKey: PreferenceKey {
    typealias Value = ScrollOffsetValue
    static var defaultValue = ScrollOffsetValue()
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let newValue = nextValue()
        value.x += newValue.x
        value.y += newValue.y
        value.contentSize = newValue.contentSize
    }
}

fileprivate
struct OffsetInScrollView: View {
    let named: String
    var body: some View {
        GeometryReader { proxy in
            let offsetValue = ScrollOffsetValue(x: proxy.frame(in: .named(named)).minX,
                                                y: proxy.frame(in: .named(named)).minY,
                                                contentSize: proxy.size)
            Color.clear.preference(key: ScrollOffsetKey.self, value: offsetValue)
        }
    }
}

fileprivate
struct OffsetOutScrollModifier: ViewModifier {
    
    @Binding var offsetValue: ScrollOffsetValue
    let named: String
    
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            content
                .coordinateSpace(name: named)
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    offsetValue = value
                    offsetValue.contentSize = CGSize(width: offsetValue.contentSize.width - proxy.size.width, height: offsetValue.contentSize.height - proxy.size.height)
                }
        }
    }
}


struct InfiniteScrollingWeekView_Previews: PreviewProvider {
    static var previews: some View {
        // Render the InfiniteScrollingWeekView
        InfiniteScrollingWeekView()
            .previewLayout(.sizeThatFits)
    }
}
