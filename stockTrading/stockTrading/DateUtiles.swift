//
//  DateUtiles.swift
//  stockTrading
//
//  Created by 최승원 on 7/22/25.
//

import Foundation

func floorToMinute(_ date: Date) -> Date {
    let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    return Calendar.current.date(from: components) ?? date
}
