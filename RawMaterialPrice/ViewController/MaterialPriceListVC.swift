//
//  MaterialPriceListVC.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2017. 11. 2..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit

class MaterialPriceListVC: UITableViewController {
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var indicatorText: UILabel!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var selectionList: [MaterialPriceListVO] = {
        let listDAO = MaterialPriceListDAO()
        return listDAO.findListData(selection: true)
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        let ud = UserDefaults.standard
        if ud.bool(forKey: "TUTORIAL") == false {
            let vc = self.instanceTutorialVC(name: "MasterVC")
            self.present(vc!, animated: false)
            return
        }
        
        if self.appDelegate.isLoadingChart == false {
            self.indicatorView.startAnimating()
            self.indicatorText.isHidden = false
            self.updateData(isRefresh: false)
        } else {
            self.appDelegate.isLoadingChart = false
        }
    }
    
    override func viewDidLoad() {
        self.tableView.allowsSelectionDuringEditing = true
        
        // 당겨서 새로고침
        self.refreshControl = UIRefreshControl()
        //self.refreshControl?.attributedTitle = NSAttributedString(string: "데이터 갱신중")
        //self.refreshControl?.backgroundColor = UIColor.white
        self.refreshControl?.addTarget(self, action: #selector(self.pullToRefresh(_:)), for: .valueChanged)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.selectionList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.selectionList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "priceCell") as! MaterialPriceCell
        
        if let type = row.type, let unit = row.unit, let date = row.date, let todayPrice = row.todayPrice?.customFloatConverter, let dayBeforePrice = row.dayBeforePrice?.customFloatConverter {
            cell.type.text = type
            cell.price.text = "\(todayPrice.customStringConverter)\(unit)"
            cell.date.text = self.convertDateFormat(fromFormat: "yyyyMMdd", toFormat: "yyyy-MM-dd", date: date)
            
            let variation = todayPrice - dayBeforePrice >= 0 ? todayPrice - dayBeforePrice : dayBeforePrice - todayPrice
            cell.variation.text = "\(String(format: "%.2f", variation))(\(String(format: "%.2f", variation / dayBeforePrice * 100))%)"
            if todayPrice - dayBeforePrice > 0 {
                cell.variation.textColor = UIColor.red
                cell.increase.image = UIImage(named: "increase")
            } else if todayPrice - dayBeforePrice < 0 {
                cell.variation.textColor = UIColor.blue
                cell.increase.image = UIImage(named: "decrease")
            } else {
                cell.variation.textColor = UIColor.white
                cell.increase.isHidden = true
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MaterialPriceChartView") as? MaterialPriceChartVC else {
            return
        }
        vc.param = self.selectionList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func updateData(isRefresh: Bool? = nil) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        DispatchQueue.global(qos: .utility).async {
            let jsonDataDAO = MaterialPriceJsonDataDAO()
            let listDAO = MaterialPriceListDAO()
            let list = listDAO.findListData(selection: true)
            
            for data in list {
                if let tableName = data.tableName {
                    guard jsonDataDAO.callAPI(tableName: tableName) == true else {
                        self.warningAlert("데이터 불러오기 실패!")
                        return
                    }
                    guard listDAO.editListData(tableName: tableName) == true else {
                        self.warningAlert("데이터 수정 실패!")
                        return
                    }
                }
            }
            self.selectionList = listDAO.findListData(selection: true)
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.tableView.reloadData()
                if isRefresh == true {
                    self.refreshControl?.endRefreshing()
                } else if isRefresh == false {
                    self.indicatorView.stopAnimating()
                    self.indicatorText.isHidden = true
                }
            }
        }
    }
 
    @objc func pullToRefresh(_ sender: Any) {
        self.updateData(isRefresh: true)
    }
}
