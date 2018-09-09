//
//  MaterialPriceListVO.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2017. 11. 11..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import Foundation

class MaterialPriceListVO {
    
    var type_cd: Int? // 원자재 코드
    var type: String? // 원자재 이름
    var tableName: String? // 테이블명
    var unit: String? // 단위
    var dataFrom: String? // 데이터 출처
    var date: String? // 날짜
    var dayBeforePrice: String? // 전날 가격
    var todayPrice: String? // 당일 가격
    var turn: Int? // 순서
    
}
