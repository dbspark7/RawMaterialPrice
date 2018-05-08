//
//  TodayVC.swift
//  RawMaterialPriceTodayExtension
//
//  Created by 박수성 on 2018. 2. 9..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayVC: UITableViewController, NCWidgetProviding {
    
    lazy var materialPriceList: [MaterialPriceListVO] = {
        let listDAO = MaterialPriceListDAO()
        return listDAO.findListData(isTodayExtension: true)
    }()
    
    lazy var exchangeRateList: [ExchangeRateListVO] = {
        let listDAO = ExchangeRateListDAO()
        return listDAO.findListData(isTodayExtension: true)
    }()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.materialPriceList.count + self.exchangeRateList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let count = self.materialPriceList.count + self.exchangeRateList.count
        switch count {
        case 4:
            return self.view.frame.height / 4
        case 3:
            return self.view.frame.height / 3
        case 2:
            return self.view.frame.height / 2
        default:
            return self.view.frame.height
        }
    } 
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todayCell") as! TodayCell
        
        if indexPath.row < self.materialPriceList.count {
            let row = self.materialPriceList[indexPath.row]
            if let type = row.type, let unit = row.unit, let date = row.date, let todayPrice = row.todayPrice?.customFloatConverter, let dayBeforePrice = row.dayBeforePrice?.customFloatConverter {
                cell.name.text = type
                cell.date.text = self.convertDateFormat(fromFormat: "yyyyMMdd", toFormat: "MM/dd", date: date)
                cell.price.text = "\(todayPrice.customStringConverter)\(unit)"
                
                let variation = todayPrice - dayBeforePrice >= 0 ? todayPrice - dayBeforePrice : dayBeforePrice - todayPrice
                cell.variation.text = "\(String(format: "%.2f", variation))(\(String(format: "%.2f", variation / dayBeforePrice * 100))%)"
                if todayPrice - dayBeforePrice > 0 {
                    cell.variation.textColor = UIColor.red
                    cell.increaseImage.image = UIImage(named: "increase")
                } else if todayPrice - dayBeforePrice < 0 {
                    cell.variation.textColor = UIColor.blue
                    cell.increaseImage.image = UIImage(named: "decrease")
                } else {
                    cell.variation.textColor = UIColor.white
                    cell.increaseImage.isHidden = true
                }
            }
        } else {
            let row = self.exchangeRateList[indexPath.row - self.materialPriceList.count]
            if let type = row.type, let unit = row.unit, let dayBeforePrice = row.dayBeforePrice?.customFloatConverter, let todayPrice = row.todayPrice?.customFloatConverter, let date = row.date {
                cell.name.text = type
                cell.date.text = self.convertDateFormat(fromFormat: "yyyyMMdd", toFormat: "MM/dd", date: date)
                cell.price.text = "\(todayPrice.customStringConverter)\(unit)"
                
                let variation = todayPrice - dayBeforePrice >= 0 ? todayPrice - dayBeforePrice : dayBeforePrice - todayPrice
                cell.variation.text = "\(String(format: "%.2f", variation))(\(String(format: "%.2f", variation / dayBeforePrice * 100))%)"
                if todayPrice - dayBeforePrice > 0 {
                    cell.variation.textColor = UIColor.red
                    cell.increaseImage.image = UIImage(named: "increase")
                } else if todayPrice - dayBeforePrice < 0 {
                    cell.variation.textColor = UIColor.blue
                    cell.increaseImage.image = UIImage(named: "decrease")
                } else {
                    cell.variation.textColor = UIColor.white
                    cell.increaseImage.isHidden = true
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: "priceTodayExtension://")
        self.extensionContext?.open(url!, completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateData()
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }

    private func updateData() {
        DispatchQueue.global(qos: .utility).async {
            let materialPriceJsonDataDAO = MaterialPriceJsonDataDAO()
            let materialPriceListDAO = MaterialPriceListDAO()
            let exchangeRateJsonDataDAO = ExchangeRateJsonDataDAO()
            let exchangeRateListDAO = ExchangeRateListDAO()
            
            for data in self.materialPriceList {
                if let tableName = data.tableName {
                    _ = materialPriceJsonDataDAO.callAPI(tableName: tableName)
                    _ = materialPriceListDAO.editListData(tableName: tableName)
                }
            }
            _ = exchangeRateJsonDataDAO.callAPI()
            for data in self.exchangeRateList {
                if let tableName = data.tableName {
                    _ = exchangeRateListDAO.editListData(tableName: tableName)
                }
            }
            self.materialPriceList = materialPriceListDAO.findListData(isTodayExtension: true)
            self.exchangeRateList = exchangeRateListDAO.findListData(isTodayExtension: true)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        let url = URL(string: "priceTodayExtension://")
        self.extensionContext?.open(url!, completionHandler: nil)
    }
}
