//
//  CustomDateFormatterProtocol+Extension.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2018. 9. 7..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import Foundation

protocol CustomDateFormatter {
    func convertDateFormat(fromFormat: String, toFormat:String, date: String) -> String
}

extension CustomDateFormatter {
    func convertDateFormat(fromFormat: String, toFormat:String, date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = fromFormat
        if let temp = formatter.date(from: date) {
            formatter.dateFormat = toFormat
            return formatter.string(from: temp)
        } else {
            return "19700101"
        }
    }
}
