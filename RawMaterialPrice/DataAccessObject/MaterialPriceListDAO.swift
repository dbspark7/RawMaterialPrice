//
//  MaterialPriceListDAO.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2017. 11. 30..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit

class MaterialPriceListDAO: FMDB {
    
    init() {
        super.init(resource: "materialPriceList", type: "sqlite")
    }
    
    // 메인 화면 리스트 호출
    func findListData(selection: Bool? = nil, isTodayExtension: Bool? = nil) -> [MaterialPriceListVO] {
        var materialPriceList = [MaterialPriceListVO]()
        
        do {
            // 가격 정보 목록을 가져올 SQL 작성 및 쿼리 실행
            var turn = ""
            if selection == true {
                turn = "WHERE turn < 20"
            } else if selection == false {
                turn = "WHERE turn == 20"
            } else if selection == nil && isTodayExtension == true {
                turn = "WHERE turn < 2"
            }
            
            let sql = """
            SELECT type_cd, type, tableName, unit, dataFrom, date, dayBeforePrice, todayPrice, turn
            FROM materialPriceList
            \(turn)
            ORDER BY turn ASC
            """
            
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            // 결과 집합 추출
            while rs.next() {
                let data = MaterialPriceListVO()
                data.type_cd = Int(rs.int(forColumn: "type_cd"))
                data.type = rs.string(forColumn: "type")
                data.tableName = rs.string(forColumn: "tableName")
                data.unit = rs.string(forColumn: "unit")
                data.dataFrom = rs.string(forColumn: "dataFrom")
                data.date = rs.string(forColumn: "date")
                data.dayBeforePrice = rs.string(forColumn: "dayBeforePrice")
                data.todayPrice = rs.string(forColumn: "todayPrice")
                data.turn = Int(rs.int(forColumn: "turn"))
                
                materialPriceList.append(data)
            }
        } catch let error as NSError {
            self.fmdb.rollback()
            print("failed: \(error.localizedDescription)")
        }
        return materialPriceList
    }
    
    // 리스트 수정시 호출
    func editListData(tableName: String) -> Bool {
        let jsonDataDAO = MaterialPriceJsonDataDAO()
        
        do {
            let data = jsonDataDAO.find(tableName: tableName, lastTwoLimit: true)
            var params = [Any]()
            
            var sql = "UPDATE materialPriceList SET date = ? WHERE tableName = ? "
            if let date = data.first?[0] {
                params.append(date)
            }
            params.append(tableName)
            try self.fmdb.executeUpdate(sql, values: params)
            params.removeAll()
            
            var dayBeforePrice: String?
            var todayPrice: String?
            sql = "UPDATE materialPriceList SET dayBeforePrice = ? WHERE tableName = ? "
            switch tableName {
            case MaterialType.wtiCrudeOil.table(),
                 MaterialType.naturalGas.table(),
                 MaterialType.steel.table():
                dayBeforePrice = data.last?[6] as? String
                todayPrice = data.first?[6] as? String
            case MaterialType.brentCrudeOil.table(),
                 MaterialType.bitcoin.table():
                dayBeforePrice = data.last?[4] as? String
                todayPrice = data.first?[4] as? String
            case MaterialType.opecCrudeOil.table(),
                 MaterialType.iron.table(),
                 MaterialType.gold.table(),
                 MaterialType.silver.table(),
                 MaterialType.platinum.table(),
                 MaterialType.palladium.table():
                dayBeforePrice = data.last?[1] as? String
                todayPrice = data.first?[1] as? String
            case MaterialType.coal.table():
                dayBeforePrice = data.last?[2] as? String
                todayPrice = data.first?[2] as? String
            case MaterialType.aluminum.table(),
                 MaterialType.cobalt.table(),
                 MaterialType.copper.table(),
                 MaterialType.lead.table(),
                 MaterialType.molybdenum.table(),
                 MaterialType.nickel.table(),
                 MaterialType.tin.table(),
                 MaterialType.zinc.table():
                dayBeforePrice = data.last?[3] as? String
                todayPrice = data.first?[3] as? String
            default:
                ()
            }
            params.append(dayBeforePrice!)
            params.append(tableName)
            try self.fmdb.executeUpdate(sql, values: params)
            params.removeAll()
            
            sql = "UPDATE materialPriceList SET todayPrice = ? WHERE tableName = ? "
            params.append(todayPrice!)
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
            
            let sql = "UPDATE materialPriceList SET turn = ? WHERE tableName = ? "
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
