//
//  TodayVC.swift
//  RawMaterialPriceTodayExtension
//
//  Created by 박수성 on 2018. 2. 9..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayVC: UITableViewController, NCWidgetProviding, CustomDateFormatter {
    
    // MARK: - Property
    // 위젯 리스트
    lazy var todayExtensionList: [TodayExtensionListVO] = {
        let listDAO = TodayExtensionListDAO()
        return listDAO.findList(selection: true)
    }()
    
    // MARK: - override / protocol Method
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todayExtensionList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.todayExtensionList.count {
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
        
        let row = self.todayExtensionList[indexPath.row]
        guard let tableName = row.tableName else { return cell }
        
        if tableName == "wtiCrudeOil" || tableName == "brentCrudeOil" || tableName == "opecCrudeOil" || tableName == "naturalGas" || tableName == "coal" || tableName == "aluminum" || tableName == "cobalt" || tableName == "copper" || tableName == "iron" || tableName == "lead" || tableName == "molybdenum" || tableName == "nickel" || tableName == "steel" || tableName == "tin" || tableName == "zinc" || tableName == "gold" || tableName == "silver" || tableName == "platinum" || tableName == "palladium" || tableName == "bitcoin" {
            let dao = MaterialPriceListDAO()
            let data = dao.findListData(tableName: tableName)
            
            if let type = data.first?.type, let unit = data.first?.unit, let date = data.first?.date, let todayPrice = data.first?.todayPrice?.customFloatConverter, let dayBeforePrice = data.first?.dayBeforePrice?.customFloatConverter {
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
            let dao = ExchangeRateListDAO()
            let data = dao.findListData(tableName: tableName)
            
            if let type = data.first?.type, let unit = data.first?.unit, let dayBeforePrice = data.first?.dayBeforePrice?.customFloatConverter, let todayPrice = data.first?.todayPrice?.customFloatConverter, let date = data.first?.date {
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
    
    // MARK: - Method
    private func updateData() {
        DispatchQueue.global(qos: .utility).async {
            let materialPriceJsonDataDAO = MaterialPriceJsonDataDAO()
            let materialPriceListDAO = MaterialPriceListDAO()
            let exchangeRateJsonDataDAO = ExchangeRateJsonDataDAO()
            let exchangeRateListDAO = ExchangeRateListDAO()
            
            _ = exchangeRateJsonDataDAO.callAPI()
            
            for data in self.todayExtensionList {
                guard let tableName = data.tableName else { return }
                
                if tableName == "wtiCrudeOil" || tableName == "brentCrudeOil" || tableName == "opecCrudeOil" || tableName == "naturalGas" || tableName == "coal" || tableName == "aluminum" || tableName == "cobalt" || tableName == "copper" || tableName == "iron" || tableName == "lead" || tableName == "molybdenum" || tableName == "nickel" || tableName == "steel" || tableName == "tin" || tableName == "zinc" || tableName == "gold" || tableName == "silver" || tableName == "platinum" || tableName == "palladium" || tableName == "bitcoin" {
                    _ = materialPriceJsonDataDAO.callAPI(tableName: tableName)
                    _ = materialPriceListDAO.editListData(tableName: tableName)
                } else {
                    _ = exchangeRateListDAO.editListData(tableName: tableName)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - @IBAction Method
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        let url = URL(string: "priceTodayExtension://")
        self.extensionContext?.open(url!, completionHandler: nil)
    }
}
