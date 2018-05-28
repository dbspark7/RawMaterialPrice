//
//  FMDB.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2018. 2. 7..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit

class FMDBExecution {
    private var resource: String
    private var type: String
    
    init(resource: String, type: String) {
        self.resource = resource
        self.type = type
        self.fmdb.open()
    }
    
    deinit {
        self.fmdb.close()
    }
    
    // SQLite 연결 및 초기화
    lazy var fmdb: FMDatabase! = {
        // 파일 매니저 객체를 생성
        let fileMgr = FileManager.default
        
        // 앱그룹에서 데이터베이스 파일 경로를 확인
        let docPath = fileMgr.containerURL(forSecurityApplicationGroupIdentifier: "group.priceGroup.kr.co.ipdisk.dbspark711")
        //let docPath = fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first
        let dbPath = docPath!.appendingPathComponent("\(self.resource).\(self.type)").path
        
        // 앱그룹에 파일이 없다면 메인 번들에 만들어 둔 materialPriceData.sqlite를 가져와 복사
        if fileMgr.fileExists(atPath: dbPath) == false {
            let dbSource = Bundle.main.path(forResource: self.resource, ofType: self.type)
            try! fileMgr.copyItem(atPath: dbSource!, toPath: dbPath)
        }
        
        // 준비된 데이터베이스 파일을 바탕으로 FMDatabase 객체를 생성
        let db = FMDatabase(path: dbPath)
        return db
    }()
}

// 날짜 변환 extnsion
extension FMDBExecution {
    func convertDateFormat(fromFormat: String, toFormat:String, date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = fromFormat
        let temp = formatter.date(from: date)
        formatter.dateFormat = toFormat
        return formatter.string(from: temp!)
    }
}
