//
//  MaterialPriceJsonDataDAO.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2017. 11. 21..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit

class MaterialPriceJsonDataDAO: FMDBExecution {
    
    init() {
        super.init(resource: "materialPriceData", type: "sqlite")
    }
    
    // 데이터베이스에서 마지막 데이터 날짜 가져오기
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
    
    // 데이터베이스에 row 생성
    private func create(tableName: String, data: NSArray) -> Bool {
        do {
            let sql: String?
            switch tableName {
            case MaterialType.wtiCrudeOil.table(),
                 MaterialType.naturalGas.table():
                sql = """
                INSERT INTO \(tableName) (date, open, high, low, last, change, settle, volume, previousDayOpenInterest)
                VALUES ( ? , ? , ? , ? , ? , ? , ? , ? , ? )
                """
            case MaterialType.brentCrudeOil.table():
                sql = """
                INSERT INTO \(tableName) (date, open, high, low, settle, change, wave, volume, previousDayOpenInterest, efpVolume, efsVolume, blockVolume)
                VALUES ( ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? )
                """
            case MaterialType.opecCrudeOil.table(),
                 MaterialType.iron.table():
                sql = """
                INSERT INTO \(tableName) (date, value)
                VALUES ( ? , ? )
                """
            case MaterialType.coal.table():
                sql = """
                INSERT INTO \(tableName) (date, centralAppalachia, northernAppalachia, illinoisBasin, powderRiverBasin, uintaBasin)
                VALUES ( ? , ? , ? , ? , ? , ? )
                """
            case MaterialType.aluminum.table(),
                 MaterialType.copper.table(),
                 MaterialType.lead.table(),
                 MaterialType.nickel.table(),
                 MaterialType.tin.table(),
                 MaterialType.zinc.table():
                sql = """
                INSERT INTO \(tableName) (date, cashBuyer, cashSeller, threeMonthsBuyer, threeMonthsSeller, fiftheenMonthsBuyer, fiftheenMonthsSeller, dec1Buyer, dec1Seller, dec2Buyer, dec2Seller, dec3Buyer, dec3Seller)
                VALUES ( ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? )
                """
            case MaterialType.cobalt.table(),
                 MaterialType.molybdenum.table():
                sql = """
                INSERT INTO \(tableName) (date, cashBuyer, cashSeller, threeMonthsBuyer, threeMonthsSeller, fiftheenMonthsBuyer, fiftheenMonthsSeller)
                VALUES ( ? , ? , ? , ? , ? , ? , ? )
                """
            case MaterialType.steel.table():
                sql = """
                INSERT INTO \(tableName) (date, preSettle, open, high, low, close, settle, ch1, ch2, volume, oi, change)
                VALUES ( ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ? )
                """
            case MaterialType.gold.table():
                sql = """
                INSERT INTO \(tableName) (date, usdAM, usdPM, gbpAM, gbpPM, euroAM, euroPM)
                VALUES ( ? , ? , ? , ? , ? , ? , ? )
                """
            case MaterialType.silver.table():
                sql = """
                INSERT INTO \(tableName) (date, usd, gbp, euro)
                VALUES ( ? , ? , ? , ? )
                """
            case MaterialType.platinum.table(),
                 MaterialType.palladium.table():
                sql = """
                INSERT INTO \(tableName) (date, usdAM, eurAM, gbpAM, usdPM, eurPM, gbpPM)
                VALUES ( ? , ? , ? , ? , ? , ? , ? )
                """
            case MaterialType.bitcoin.table():
                sql = """
                INSERT INTO \(tableName) (date, open, high, low, close, volume)
                VALUES ( ? , ? , ? , ? , ? , ? )
                """
            default:
                sql = ""
            }
            
            let editData = NSMutableArray()
            for count in 0..<data.count {
                if count == 0 {
                    editData.add(self.convertDateFormat(fromFormat: "yyyy-MM-dd", toFormat: "yyyyMMdd", date: data[count] as! String))
                } else {
                    editData.add(data[count])
                }
            }
            try self.fmdb.executeUpdate(sql!, values: editData as? [Any])
            return true
        } catch let error as NSError {
            self.fmdb.rollback()
            print("Insert Error : \(error.localizedDescription)")
            return false
        }
    }
    
    // 데이터베이스에서 row 삭제
    private func remove(tableName: String, date: String) -> Bool {
        do {
            let sql = "DELETE FROM \(tableName) WHERE date= ? "
            
            try self.fmdb.executeUpdate(sql, values: [date])
            return true
        } catch let error as NSError {
            self.fmdb.rollback()
            print("DELETE Error : \(error.localizedDescription)")
            return false
        }
    }
    
    // 데이터베이스에서 row 가져오기
    func find(tableName: String, dateFrom: String? = nil, lastTwoLimit: Bool? = nil) -> [NSArray] {
        var dataList = [NSArray]()
        
        do {
            // 데이터 목록을 가져올 SQL 작성 및 쿼리 실행
            var sql: String?
            switch tableName {
            case MaterialType.wtiCrudeOil.table(),
                 MaterialType.naturalGas.table():
                sql = "SELECT date, open, high, low, last, change, settle, volume, previousDayOpenInterest\n"
            case MaterialType.brentCrudeOil.table():
                sql = "SELECT date, open, high, low, settle, change, wave, volume, previousDayOpenInterest, efpVolume, efsVolume, blockVolume\n"
            case MaterialType.opecCrudeOil.table(),
                 MaterialType.iron.table():
                sql = "SELECT date, value\n"
            case MaterialType.coal.table():
                sql = "SELECT date, centralAppalachia, northernAppalachia, illinoisBasin, powderRiverBasin, uintaBasin\n"
            case MaterialType.aluminum.table(),
                 MaterialType.copper.table(),
                 MaterialType.lead.table(),
                 MaterialType.nickel.table(),
                 MaterialType.tin.table(),
                 MaterialType.zinc.table():
                sql = "SELECT date, cashBuyer, cashSeller, threeMonthsBuyer, threeMonthsSeller, fiftheenMonthsBuyer, fiftheenMonthsSeller, dec1Buyer, dec1Seller, dec2Buyer, dec2Seller, dec3Buyer, dec3Seller\n"
            case MaterialType.cobalt.table(),
                 MaterialType.molybdenum.table():
                sql = "SELECT date, cashBuyer, cashSeller, threeMonthsBuyer, threeMonthsSeller, fiftheenMonthsBuyer, fiftheenMonthsSeller\n"
            case MaterialType.steel.table():
                sql = "SELECT date, preSettle, open, high, low, close, settle, ch1, ch2, volume, oi, change\n"
            case MaterialType.gold.table():
                sql = "SELECT date, usdAM, usdPM, gbpAM, gbpPM, euroAM, euroPM\n"
            case MaterialType.silver.table():
                sql = "SELECT date, usd, gbp, euro\n"
            case MaterialType.platinum.table(),
                 MaterialType.palladium.table():
                sql = "SELECT date, usdAM, eurAM, gbpAM, usdPM, eurPM, gbpPM\n"
            case MaterialType.bitcoin.table():
                sql = "SELECT date, open, high, low, close, volume\n"
            default:
                sql = ""
            }
            sql?.append("FROM \(tableName)\n")
            if let _dateFrom = dateFrom {
                sql?.append("WHERE date >= \(_dateFrom)\n")
            }
            if lastTwoLimit == true {
                sql?.append("ORDER BY date DESC LIMIT 2")
            } else {
                sql?.append("ORDER BY date ASC")
            }
            
            let rs = try self.fmdb.executeQuery(sql!, values: nil)
            
            // 결과 집합 추출
            while rs.next() {
                let data = NSMutableArray()
                data.add(rs.string(forColumn: "date") ?? "0")
                switch tableName {
                case MaterialType.wtiCrudeOil.table(),
                     MaterialType.naturalGas.table():
                    data.add(rs.string(forColumn: "open") ?? "0")
                    data.add(rs.string(forColumn: "high") ?? "0")
                    data.add(rs.string(forColumn: "low") ?? "0")
                    data.add(rs.string(forColumn: "last") ?? "0")
                    data.add(rs.string(forColumn: "change") ?? "0")
                    data.add(rs.string(forColumn: "settle") ?? "0")
                    data.add(rs.string(forColumn: "volume") ?? "0")
                    data.add(rs.string(forColumn: "previousDayOpenInterest") ?? "0")
                case MaterialType.brentCrudeOil.table():
                    data.add(rs.string(forColumn: "open") ?? "0")
                    data.add(rs.string(forColumn: "high") ?? "0")
                    data.add(rs.string(forColumn: "low") ?? "0")
                    data.add(rs.string(forColumn: "settle") ?? "0")
                    data.add(rs.string(forColumn: "change") ?? "0")
                    data.add(rs.string(forColumn: "wave") ?? "0")
                    data.add(rs.string(forColumn: "volume") ?? "0")
                    data.add(rs.string(forColumn: "previousDayOpenInterest") ?? "0")
                    data.add(rs.string(forColumn: "efpVolume") ?? "0")
                    data.add(rs.string(forColumn: "efsVolume") ?? "0")
                    data.add(rs.string(forColumn: "blockVolume") ?? "0")
                case MaterialType.opecCrudeOil.table(),
                     MaterialType.iron.table():
                    data.add(rs.string(forColumn: "value") ?? "0")
                case MaterialType.coal.table():
                    data.add(rs.string(forColumn: "centralAppalachia") ?? "0")
                    data.add(rs.string(forColumn: "northernAppalachia") ?? "0")
                    data.add(rs.string(forColumn: "illinoisBasin") ?? "0")
                    data.add(rs.string(forColumn: "powderRiverBasin") ?? "0")
                    data.add(rs.string(forColumn: "uintaBasin") ?? "0")
                case MaterialType.aluminum.table(),
                     MaterialType.copper.table(),
                     MaterialType.lead.table(),
                     MaterialType.nickel.table(),
                     MaterialType.tin.table(),
                     MaterialType.zinc.table():
                    data.add(rs.string(forColumn: "cashBuyer") ?? "0")
                    data.add(rs.string(forColumn: "cashSeller") ?? "0")
                    data.add(rs.string(forColumn: "threeMonthsBuyer") ?? "0")
                    data.add(rs.string(forColumn: "threeMonthsSeller") ?? "0")
                    data.add(rs.string(forColumn: "fiftheenMonthsBuyer") ?? "0")
                    data.add(rs.string(forColumn: "fiftheenMonthsSeller") ?? "0")
                    data.add(rs.string(forColumn: "dec1Buyer") ?? "0")
                    data.add(rs.string(forColumn: "dec1Seller") ?? "0")
                    data.add(rs.string(forColumn: "dec2Buyer") ?? "0")
                    data.add(rs.string(forColumn: "dec2Seller") ?? "0")
                    data.add(rs.string(forColumn: "dec3Buyer") ?? "0")
                    data.add(rs.string(forColumn: "dec3Seller") ?? "0")
                case MaterialType.cobalt.table(),
                     MaterialType.molybdenum.table():
                    data.add(rs.string(forColumn: "cashBuyer") ?? "0")
                    data.add(rs.string(forColumn: "cashSeller") ?? "0")
                    data.add(rs.string(forColumn: "threeMonthsBuyer") ?? "0")
                    data.add(rs.string(forColumn: "threeMonthsSeller") ?? "0")
                    data.add(rs.string(forColumn: "fiftheenMonthsBuyer") ?? "0")
                    data.add(rs.string(forColumn: "fiftheenMonthsSeller") ?? "0")
                case MaterialType.steel.table():
                    data.add(rs.string(forColumn: "preSettle") ?? "0")
                    data.add(rs.string(forColumn: "open") ?? "0")
                    data.add(rs.string(forColumn: "high") ?? "0")
                    data.add(rs.string(forColumn: "low") ?? "0")
                    data.add(rs.string(forColumn: "close") ?? "0")
                    data.add(rs.string(forColumn: "settle") ?? "0")
                    data.add(rs.string(forColumn: "ch1") ?? "0")
                    data.add(rs.string(forColumn: "ch2") ?? "0")
                    data.add(rs.string(forColumn: "volume") ?? "0")
                    data.add(rs.string(forColumn: "oi") ?? "0")
                    data.add(rs.string(forColumn: "change") ?? "0")
                case MaterialType.gold.table():
                    data.add(rs.string(forColumn: "usdAM") ?? "0")
                    data.add(rs.string(forColumn: "usdPM") ?? "0")
                    data.add(rs.string(forColumn: "gbpAM") ?? "0")
                    data.add(rs.string(forColumn: "gbpPM") ?? "0")
                    data.add(rs.string(forColumn: "euroAM") ?? "0")
                    data.add(rs.string(forColumn: "euroPM") ?? "0")
                case MaterialType.silver.table():
                    data.add(rs.string(forColumn: "usd") ?? "0")
                    data.add(rs.string(forColumn: "gbp") ?? "0")
                    data.add(rs.string(forColumn: "euro") ?? "0")
                case MaterialType.platinum.table(),
                     MaterialType.palladium.table():
                    data.add(rs.string(forColumn: "usdAM") ?? "0")
                    data.add(rs.string(forColumn: "eurAM") ?? "0")
                    data.add(rs.string(forColumn: "gbpAM") ?? "0")
                    data.add(rs.string(forColumn: "usdPM") ?? "0")
                    data.add(rs.string(forColumn: "eurPM") ?? "0")
                    data.add(rs.string(forColumn: "gbpPM") ?? "0")
                case MaterialType.bitcoin.table():
                    data.add(rs.string(forColumn: "open") ?? "0")
                    data.add(rs.string(forColumn: "high") ?? "0")
                    data.add(rs.string(forColumn: "low") ?? "0")
                    data.add(rs.string(forColumn: "close") ?? "0")
                    data.add(rs.string(forColumn: "volume") ?? "0")
                default:
                    ()
                }
                dataList.append(data)
            }
        } catch let error as NSError {
            self.fmdb.rollback()
            print("failed: \(error.localizedDescription)")
        }
        return dataList
    }
    
    // API 호출
    func callAPI(tableName: String) -> Bool {
        guard let startDate = self.getLastDate(tableName: tableName) else {
            return false
        }
        var url: String
        switch tableName {
        case MaterialType.wtiCrudeOil.table():
            url = "https://www.quandl.com/api/v3/datasets/CHRIS/CME_CL1.json" // Wiki Continuous Futures
        case MaterialType.brentCrudeOil.table():
            url = "https://www.quandl.com/api/v3/datasets/CHRIS/ICE_B1.json" // Wiki Continuous Futures
        case MaterialType.opecCrudeOil.table():
            url = "https://www.quandl.com/api/v3/datasets/OPEC/ORB.json" // Organization of the Petroleum Exporting Countries
        case MaterialType.naturalGas.table():
            url = "https://www.quandl.com/api/v3/datasets/CHRIS/CME_NG1.json" // Wiki Continuous Futures
        case MaterialType.coal.table():
            url = "https://www.quandl.com/api/v3/datasets/EIA/COAL.json" // U.S. Energy Information Administration Data
        case MaterialType.aluminum.table():
            url = "https://www.quandl.com/api/v3/datasets/LME/PR_AL.json" // London Metal Exchange
        case MaterialType.cobalt.table():
            url = "https://www.quandl.com/api/v3/datasets/LME/PR_CO.json" // London Metal Exchange
        case MaterialType.copper.table():
            url = "https://www.quandl.com/api/v3/datasets/LME/PR_CU.json" // London Metal Exchange
        case MaterialType.iron.table():
            url = "https://www.quandl.com/api/v3/datasets/COM/FE_TJN.json" // WIKI Commodity Prices
        case MaterialType.lead.table():
            url = "https://www.quandl.com/api/v3/datasets/LME/PR_PB.json" // London Metal Exchange
        case MaterialType.molybdenum.table():
            url = "https://www.quandl.com/api/v3/datasets/LME/PR_MO.json" // London Metal Exchange
        case MaterialType.nickel.table():
            url = "https://www.quandl.com/api/v3/datasets/LME/PR_NI.json" // London Metal Exchange
        case MaterialType.steel.table():
            url = "https://www.quandl.com/api/v3/datasets/CHRIS/SHFE_RB1.json" // Wiki Continuous Futures
        case MaterialType.tin.table():
            url = "https://www.quandl.com/api/v3/datasets/LME/PR_TN.json" // London Metal Exchange
        case MaterialType.zinc.table():
            url = "https://www.quandl.com/api/v3/datasets/LME/PR_ZI.json" // London Metal Exchange
        case MaterialType.gold.table():
            url = "https://www.quandl.com/api/v3/datasets/LBMA/GOLD.json" // London Bullion Market Association
        case MaterialType.silver.table():
            url = "https://www.quandl.com/api/v3/datasets/LBMA/SILVER.json" // London Bullion Market Association
        case MaterialType.platinum.table():
            url = "https://www.quandl.com/api/v3/datasets/LPPM/PLAT.json" // London Bullion Market Association
        case MaterialType.palladium.table():
            url = "https://www.quandl.com/api/v3/datasets/LPPM/PALL.json" // London Bullion Market Association
        case MaterialType.bitcoin.table():
            url = "https://www.quandl.com/api/v3/datasets/BCHARTS/BITSTAMPUSD.json" // Bitcoin Charts Exchange Rate Data
        default:
            url = ""
        }
        url.append("?api_key=\(IDKey.QUANDL_API_KEY)&order=asc&start_date=\(startDate)")
        
        do {
            // REST API를 호출
            let apiURI: URL! = URL(string: url)
            let apidata = try Data(contentsOf: apiURI)
            guard self.remove(tableName: tableName, date: startDate) == true else {
                return false
            }
            
            let apiDictionary = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSDictionary
            
            // 데이터 구조에 따라 차례대로 캐스팅하며 읽어온다.
            let dataset = apiDictionary["dataset"] as! NSDictionary
            let data = dataset["data"] as! NSArray
            
            for row in data {
                guard self.create(tableName: tableName, data: row as! NSArray) == true else {
                    return false
                }
            }
            return true
        } catch {
            NSLog("Parse Erroe!!")
            return false
        }
    }
}
