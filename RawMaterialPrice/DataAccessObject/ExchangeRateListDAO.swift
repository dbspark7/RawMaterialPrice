//
//  ExchangeRateListDAO.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2018. 1. 31..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit

class ExchangeRateListDAO: FMDB {
    
    init() {
        super.init(resource: "exchangeRateList", type: "sqlite")
    }
    
    // 메인 화면 리스트 호출
    func findListData(selection: Bool? = nil, isTodayExtension: Bool? = nil) -> [ExchangeRateListVO] {
        var list = [ExchangeRateListVO]()
        
        do {
            // 가격 정보 목록을 가져올 SQL 작성 및 쿼리 실행
            var turn = ""
            if selection == true {
                turn = "WHERE turn < 21"
            } else if selection == false {
                turn = "WHERE turn == 21"
            } else if selection == nil && isTodayExtension == true {
                turn = "WHERE turn < 2"
            }
            
            let sql = """
                SELECT state_cd, type, tableName, unit, date, dayBeforePrice, todayPrice, turn
                FROM exchangeRateList
                \(turn)
                ORDER BY turn ASC
                """
            
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            // 결과 집합 추출
            while rs.next() {
                let data = ExchangeRateListVO()
                data.state_cd = Int(rs.int(forColumn: "state_cd"))
                data.type = rs.string(forColumn: "type")
                data.tableName = rs.string(forColumn: "tableName")
                data.unit = rs.string(forColumn: "unit")
                data.date = rs.string(forColumn: "date")
                data.dayBeforePrice = rs.string(forColumn: "dayBeforePrice")
                data.todayPrice = rs.string(forColumn: "todayPrice")
                data.turn = Int(rs.int(forColumn: "turn"))
                
                list.append(data)
            }
        } catch let error as NSError {
            self.fmdb.rollback()
            print("failed: \(error.localizedDescription)")
        }
        return list
    }
    
    // 리스트 수정시 호출
    func editListData(tableName: String) -> Bool {
        let dao = ExchangeRateJsonDataDAO()
        
        do {
            let data = dao.find(tableName: tableName, lastTwoLimit: true)
            var params = [Any]()
            
            var sql = "UPDATE exchangeRateList SET date = ? WHERE tableName = ? "
            if let date = data.first?.date {
                params.append(date)
            }
            params.append(tableName)
            try self.fmdb.executeUpdate(sql, values: params)
            params.removeAll()
            
            sql = "UPDATE exchangeRateList SET dayBeforePrice = ? WHERE tableName = ? "
            if let dayBeforePrice = data.last?.deal_bas_r {
                params.append(dayBeforePrice)
            }
            params.append(tableName)
            try self.fmdb.executeUpdate(sql, values: params)
            params.removeAll()
            
            sql = "UPDATE exchangeRateList SET todayPrice = ? WHERE tableName = ? "
            if let todayPrice = data.first?.deal_bas_r {
                params.append(todayPrice)
            }
            params.append(tableName)
            try self.fmdb.executeUpdate(sql, values: params)
            return true
        } catch let error as NSError {
            self.fmdb.rollback()
            print("UPDATE Error : \(error.localizedDescription)")
            return false
        }
    }
    
    // 테이블 뷰에서 순서만 변경할 경우 호출
    func editTurn(tableName: String, turn: Int32) -> Bool {
        do {
            var params = [Any]()
            
            let sql = "UPDATE exchangeRateList SET turn = ? WHERE tableName = ? "
            params.append(turn)
            params.append(tableName)
            try self.fmdb.executeUpdate(sql, values: params)
            return true
        } catch let error as NSError {
            self.fmdb.rollback()
            print("UPDATE Error : \(error.localizedDescription)")
            return false
        }
    }
}
