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
            return "wtiCrudeOil" // 원유(WTI)
        case .brentCrudeOil:
            return "brentCrudeOil" // 원유(Brent)
        case .opecCrudeOil:
            return "opecCrudeOil" // 원유(OPEC)
        case .naturalGas:
            return "naturalGas" // 천연가스
        case .coal:
            return "coal" // 석탄
        case .aluminum:
            return "aluminum" // 알루미늄(Al)
        case .cobalt:
            return "cobalt" // 코발트(Co)
        case .copper:
            return "copper" // 구리(Cu)
        case .iron:
            return "iron" // 철광석(Fe)
        case .lead:
            return "lead" // 납(Pb)
        case .molybdenum:
            return "molybdenum" // 몰리브덴(Mo)
        case .nickel:
            return "nickel" // 니켈(Ni)
        case .steel:
            return "steel" // 철강(Steel)
        case .tin:
            return "tin" // 주석(Sn)
        case .zinc:
            return "zinc" // 아연(Zn)
        case .gold:
            return "gold" // 금(Au)
        case .silver:
            return "silver" // 은(Ag)
        case .platinum:
            return "platinum" // 백금(Pt)
        case .palladium:
            return "palladium" // 팔라듐(Pd)
        case .bitcoin:
            return "bitcoin" // 비트코인
        }
    }
}

// MARK: - 튜토리얼 관련 extension
extension UIViewController {
    var tutorialSB: UIStoryboard {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    func instanceTutorialVC(name: String) -> UIViewController? {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
}

// MARK: - String <-> Float 또는 Double 값 변환 extension
// String 값에서 Float 또는 Double로 변환
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

// Float 값에서 String 값으로 변환
extension Float {
    var customStringConverter: String {
        let converter = NumberFormatter()
        
        converter.usesGroupingSeparator = true
        converter.groupingSize = 3
        converter.maximumFractionDigits = 2
        converter.minimumFractionDigits = 0
        converter.usesSignificantDigits = true
        if let result = converter.string(for: self) {
            return result
        }
        return ""
    }
}

// Double 값에서 String 값으로 변환
extension Double {
    var customStringConverter: String {
        let converter = NumberFormatter()
        
        converter.usesGroupingSeparator = true
        converter.groupingSize = 3
        converter.maximumFractionDigits = 2
        converter.minimumFractionDigits = 0
        converter.usesSignificantDigits = true
        if let result = converter.string(for: self) {
            return result
        }
        return ""
    }
}

// MARK: - 알림창 extension
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
