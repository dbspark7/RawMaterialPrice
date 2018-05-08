//
//  ExchangeRateJsonDataDAO.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2018. 1. 31..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit

class ExchangeRateJsonDataDAO: FMDB {
    
    init() {
        super.init(resource: "exchangeRateData", type: "sqlite")
    }
    
    private func getLastDate(tableName: String) -> String? {
        var result: String?
        do {
            let sql = """
            SELECT date
            FROM \(tableName)
            WHERE date = (SELECT MAX(date) FROM \(tableName))
            """
            
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            while rs.next() {
                if let date = rs.string(forColumn: "date") {
                    result = date
                }
            }
        } catch let error as NSError {
            self.fmdb.rollback()
            print("failed: \(error.localizedDescription)")
        }
        return result
    }
    
    private func create(tableName: String, data: ExchangeRateDataVO) -> Bool {
        do {
            let sql = """
            INSERT INTO \(tableName) (date, ttb, tts, deal_bas_r, bkpr, yy_efee_r, ten_dd_efee_r, kftc_bkpr, kftc_deal_bas_r)
            VALUES ( ? , ? , ? , ? , ? , ? , ? , ? , ? )
            """
            
            try self.fmdb.executeUpdate(sql, values: [data.date!, data.ttb!, data.tts!, data.deal_bas_r!, data.bkpr!, data.yy_efee_r!, data.ten_dd_efee_r!, data.kftc_bkpr!, data.kftc_deal_bas_r!])
            return true
        } catch let error as NSError {
            self.fmdb.rollback()
            print("Insert Error : \(error.localizedDescription)")
            return false
        }
    }
    
    private func remove(date: String) -> Bool {
        let dao = ExchangeRateListDAO()
        let list = dao.findListData()
        
        do {
            for row in list {
                if let tableName = row.tableName {
                    let sql = "DELETE FROM \(tableName) WHERE date= ? "
                    
                    try self.fmdb.executeUpdate(sql, values: [date])
                }
            }
            return true
        } catch let error as NSError {
            self.fmdb.rollback()
            print("DELETE Error : \(error.localizedDescription)")
            return false
        }
    }
    
    func find(tableName: String, dateFrom: String? = nil, lastTwoLimit: Bool? = nil) -> [ExchangeRateDataVO] {
        
        // 반환할 데이터를 담을 [ExchangeRateData] 타입의 객체 정의
        var dataList = [ExchangeRateDataVO]()
        var whereQuery = ""
        if let _dateFrom = dateFrom {
            whereQuery = "WHERE date >= \(_dateFrom)"
        }
        var order = "ORDER BY date ASC"
        if lastTwoLimit == true {
            order = "ORDER BY date DESC LIMIT 2"
        }
        
        do {
            // SQL 작성 및 쿼리 실행
            let sql = """
            SELECT date, ttb, tts, deal_bas_r, bkpr, yy_efee_r, ten_dd_efee_r, kftc_bkpr, kftc_deal_bas_r
            FROM \(tableName)
            \(whereQuery)
            \(order)
            """
            
            let rs = try self.fmdb.executeQuery(sql, values: nil)
            
            // 결과 집합 추출
            while rs.next() {
                let data = ExchangeRateDataVO()
                data.date = rs.string(forColumn: "date")
                data.ttb = rs.string(forColumn: "ttb")
                data.tts = rs.string(forColumn: "tts")
                data.deal_bas_r = rs.string(forColumn: "deal_bas_r")
                data.bkpr = rs.string(forColumn: "bkpr")
                data.yy_efee_r = rs.string(forColumn: "yy_efee_r")
                data.ten_dd_efee_r = rs.string(forColumn: "ten_dd_efee_r")
                data.kftc_bkpr = rs.string(forColumn: "kftc_bkpr")
                data.kftc_deal_bas_r = rs.string(forColumn: "kftc_deal_bas_r")
                
                dataList.append(data)
            }
        } catch let error as NSError {
            self.fmdb.rollback()
            print("failed: \(error.localizedDescription)")
        }
        return dataList
    }
    
    func callAPI() -> Bool {
        guard var startDate = self.getLastDate(tableName: "USD") else {
            return false
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        do {
            repeat {
                // 호핀 API 호출을 위한 URI를 생성
                let url = "https://www.koreaexim.go.kr/site/program/financial/exchangeJSON?authkey=8XpiOet6Rtk8d171DGTHVPWupAL8mKAM&data=AP01&searchdate=\(startDate)"
                
                // REST API를 호출
                let apiURI: URL! = URL(string: url)
                let apidata = try Data(contentsOf: apiURI)
                
                guard self.remove(date: startDate) == true else {
                    return false
                }
                
                let apiArray = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSArray
                
                // 데이터 구조에 따라 차례대로 캐스팅하며 읽어온다.
                for row in apiArray {
                    let r = row as! NSDictionary
                    let tableName = r["cur_unit"] as! String
                    let data = ExchangeRateDataVO()
                    
                    data.date = startDate
                    data.ttb = r["ttb"] as? String ?? "0"
                    data.tts = r["tts"] as? String ?? "0"
                    data.deal_bas_r = r["deal_bas_r"] as? String ?? "0"
                    data.bkpr = r["bkpr"] as? String ?? "0"
                    data.yy_efee_r = r["yy_efee_r"] as? String ?? "0"
                    data.ten_dd_efee_r = r["ten_dd_efee_r"] as? String ?? "0"
                    data.kftc_bkpr = r["kftc_bkpr"] as? String ?? "0"
                    data.kftc_deal_bas_r = r["kftc_deal_bas_r"] as? String ?? "0"
                    
                    switch tableName {
                    case "CNY":
                        guard self.create(tableName: "CNH", data: data) == true else {
                            return false
                        }
                    case "IDR(100)":
                        guard self.create(tableName: "IDR", data: data) == true else {
                            return false
                        }
                    case "JPY(100)":
                        guard self.create(tableName: "JPY", data: data) == true else {
                            return false
                        }
                    case "KRW":
                        continue
                    default:
                        guard self.create(tableName: tableName, data: data) == true else {
                            return false
                        }
                    }
                }
                startDate = formatter.string(from: (formatter.date(from: startDate)?.addingTimeInterval(60 * 60 * 24))!)
            } while startDate != formatter.string(from: Date().addingTimeInterval(60 * 60 * 24))
            return true
        } catch {
            NSLog("Parse Erroe!!")
            return false
        }
    }
}
