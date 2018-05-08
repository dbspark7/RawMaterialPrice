//
//  Utils.swift
//  GetKoreaeximData
//
//  Created by 박수성 on 2018. 1. 31..
//  Copyright © 2018년 박수성. All rights reserved.
//

import UIKit

public enum MaterialType: Int {
    case wtiCrudeOil = 0, brentCrudeOil, opecCrudeOil, naturalGas, coal, aluminum, cobalt, copper, iron, lead, molybdenum, nickel, steel, tin, zinc, gold, silver, platinum, palladium, bitcoin
    
    func table() -> String {
        switch self {
        case .wtiCrudeOil:
            return "wtiCrudeOil"
        case .brentCrudeOil:
            return "brentCrudeOil"
        case .opecCrudeOil:
            return "opecCrudeOil"
        case .naturalGas:
            return "naturalGas"
        case .coal:
            return "coal"
        case .aluminum:
            return "aluminum"
        case .cobalt:
            return "cobalt"
        case .copper:
            return "copper"
        case .iron:
            return "iron"
        case .lead:
            return "lead"
        case .molybdenum:
            return "molybdenum"
        case .nickel:
            return "nickel"
        case .steel:
            return "steel"
        case .tin:
            return "tin"
        case .zinc:
            return "zinc"
        case .gold:
            return "gold"
        case .silver:
            return "silver"
        case .platinum:
            return "platinum"
        case .palladium:
            return "palladium"
        case .bitcoin:
            return "bitcoin"
        }
    }
}

extension UIViewController {
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
}

extension String {
    var customFloatConverter: Float {
        let converter = NumberFormatter()
        
        converter.usesGroupingSeparator = true
        converter.groupingSize = 3
        if let result = converter.number(from: self) {
            return result.floatValue
        }
        return 0
    }
    
    var customDoubleConverter: Double {
        let converter = NumberFormatter()
        
        converter.usesGroupingSeparator = true
        converter.groupingSize = 3
        if let result = converter.number(from: self) {
            return result.doubleValue
        }
        return 0
    }
}

extension Float {
    var customStringConverter: String {
        let converter = NumberFormatter()
        
        converter.usesGroupingSeparator = true
        converter.groupingSize = 3
        converter.usesSignificantDigits = true
        if let result = converter.string(for: self) {
            return result
        }
        return ""
    }
}

// 날짜 변환기
extension UIViewController {
    func convertDateFormat(fromFormat: String, toFormat:String, date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = fromFormat
        let temp = formatter.date(from: date)
        formatter.dateFormat = toFormat
        return formatter.string(from: temp!)
    }
}

// 알림창 Extension
extension UIViewController {
    func warningAlert(_ message: String, completion: (()->Void)? = nil) {
        let alert = UIAlertController(title: "Warning!", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { (_) in
            completion?() // completion 매개변수의 값이 nil이 아닐 때에만 실행되도록
        }
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
}
