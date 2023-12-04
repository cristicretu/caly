//
//  DayView.swift
//  caly
//
//  Created by Cristian Cretu on 04.12.2023.
//

import SwiftUI

struct DayView: View {
    let day: Day

    var body: some View {
        RoundedRectangle(cornerRadius: 13, style: .continuous)
            .fill(Color.gray.opacity(0.1))
            .frame(width: 100, height: 120)
            .overlay(
                VStack(alignment: .leading) {
                    Text(day.number)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 12)
                    Spacer()
                    Text(day.name)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 12)
                }
            )
    }
}

struct DayView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock Day object
        let mockDay = Day(number: "08", name: "Wednesday")

        // Render the DayView with the mock Day object
        DayView(day: mockDay)
            .previewLayout(.sizeThatFits)
    }
}
