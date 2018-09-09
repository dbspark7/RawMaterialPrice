//
//  ExchangeRateListVO.swift
//  GetKoreaeximData
//
//  Created by 박수성 on 2018. 2. 5..
//  Copyright © 2018년 박수성. All rights reserved.
//

import Foundation

class ExchangeRateListVO {
    
    var state_cd: Int? // 국가 코드
    var type: String? // 국가 통화 이름
    var tableName: String? // 테이블명
    var unit: String? // 단위
    var date: String? // 날짜
    var dayBeforePrice: String? // 전날 가격
    var todayPrice: String? // 당일 가격
    var turn: Int? // 순서
    
}
