//
//  ExchangeRateData.swift
//  GetKoreaeximData
//
//  Created by 박수성 on 2018. 1. 31..
//  Copyright © 2018년 박수성. All rights reserved.
//

import Foundation

class ExchangeRateDataVO {
    
    var date: String? // 날짜
    var ttb: String? // 전신환(송금) 받으실때
    var tts: String? // 전신환(송금) 보내실때
    var deal_bas_r: String? // 매매 기준율
    var bkpr: String? // 장부 가격
    var yy_efee_r: String? // 연환가료율
    var ten_dd_efee_r: String? // 10일환가료율
    var kftc_bkpr: String? // 서울외국환중계 매매 기준율
    var kftc_deal_bas_r: String? // 서울외국환중계 장부가격
    
}
