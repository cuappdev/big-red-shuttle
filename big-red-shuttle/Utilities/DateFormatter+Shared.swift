//
//  DateFormatter+Shared.swift
//  big-red-shuttle
//
//  Created by Annie Cheng on 11/24/16.
//  Copyright © 2016 cuappdev. All rights reserved.
//

import Foundation

extension DateFormatter {
    
    @nonobjc static let yearMonthDayFormatter: DateFormatter = {
        $0.dateFormat = "yyyy-MM-dd"
        $0.locale = Locale(identifier: "en_US_POSIX")
        return $0
    }(DateFormatter())
    
    @nonobjc static let dateTimeFormatter: DateFormatter = {
        $0.dateFormat = "yyyy-MM-dd HH:mm a"
        $0.locale = Locale(identifier: "en_US_POSIX")
        return $0
    }(DateFormatter())
    
    @nonobjc static let longDateTimeFormatter: DateFormatter = {
        $0.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        $0.locale = Locale(identifier: "en_US_POSIX")
        return $0
    }(DateFormatter())
    
}
