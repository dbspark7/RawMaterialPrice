//
//  TodayExtensionListDAO.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2018. 9. 7..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit

class TodayExtensionListDAO: FMDBExecution {
    
    init() {
        super.init(resource: "todayExtensionList", type: "sqlite")
    }
    
    // 메인 화면 리스트 호출
    func findList(selection: Bool? = nil) -> [TodayExtensionListVO] {
        var list = [TodayExtensionListVO]()
        
        do {
            var turn = ""
            if selection == true {
                turn = "WHERE turn < 41"
            } else {
                turn = "WHERE turn == 41"
            }
            
            let sql = """
            SELECT cd, type, tableName, turn
            FROM todayExtensionList
            \(turn)
            ORDER BY turn ASC
            """
            
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            // 결과 집합 추출
            while rs.next() {
                let data = TodayExtensionListVO()
                data.cd = Int(rs.int(forColumn: "cd"))
                data.type = rs.string(forColumn: "type")
                data.tableName = rs.string(forColumn: "tableName")
                data.turn = Int(rs.int(forColumn: "turn"))
                
                list.append(data)
            }
        } catch let error as NSError {
            self.fmdb.rollback()
            print("failed: \(error.localizedDescription)")
        }
        return list
    }
    
    // 테이블 뷰에서 순서 변경할 경우 호출
    func editTurn(tableName: String, turn: Int32) -> Bool {
        do {
            var params = [Any]()
            
            let sql = "UPDATE todayExtensionList SET turn = ? WHERE tableName = ? "
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
