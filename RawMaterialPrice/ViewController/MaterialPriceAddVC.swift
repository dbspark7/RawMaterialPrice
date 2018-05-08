//
//  MaterialPriceAddVC.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2017. 11. 2..
//  Copyright © 2017년 dbspark7. All rights reserved.
//

import UIKit

class MaterialPriceAddVC: UITableViewController {
    
    lazy var selectionList: [MaterialPriceListVO] = {
        let listDAO = MaterialPriceListDAO()
        return listDAO.findListData(selection: true)
    }()
    
    lazy var nonSelectionList: [MaterialPriceListVO] = {
        let listDAO = MaterialPriceListDAO()
        return listDAO.findListData(selection: false)
    }()
    
    override func viewDidLoad() {
        self.tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isEditing = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let listDAO = MaterialPriceListDAO()
        
        // selection section의 tableLabel 순서대로 selectionList turn 재정렬
        for row in 0..<self.selectionList.count {
            for data in self.selectionList {
                if data.type == self.tableView.cellForRow(at: IndexPath.init(row: row, section: 0))?.textLabel?.text {
                    if let tableName = data.tableName {
                        guard listDAO.editTurn(tableName: tableName, turn: Int32(row)) == true else {
                            self.warningAlert("데이터 수정 실패!")
                            return
                        }
                    }
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let textHeader = UILabel(frame: CGRect(x: 10, y: 5, width: 200, height: 30))
        textHeader.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight(rawValue: 2))
        textHeader.textColor = UIColor.orange
        
        if section == 0 {
            textHeader.text = "포함된 항목"
        } else {
            textHeader.text = "리스트 항목 추가"
        }
        
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        v.backgroundColor = UIColor(red:0.00, green:0.08, blue:0.17, alpha:1.0)
        
        v.addSubview(textHeader)
        return v
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.selectionList.count
        } else {
            return self.nonSelectionList.count
        }
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "materialCell")
        
        if indexPath.section == 0 {
            let selectionRow = self.selectionList[indexPath.row]
            cell?.textLabel?.text = selectionRow.type
        } else {
            let nonSelectionRow = self.nonSelectionList[indexPath.row]
            cell?.textLabel?.text = nonSelectionRow.type
        }
        
        return cell!
    }
 
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return UITableViewCellEditingStyle.delete
        } else {
            return UITableViewCellEditingStyle.insert
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let listDAO = MaterialPriceListDAO()
        
        var trigger = true
        if indexPath.section == 0 {
            // 선택한 row 추가
            tableView.beginUpdates()
            
            var row: Int?
            if self.nonSelectionList.count != 0 {
                for count in 0..<self.nonSelectionList.count {
                    if self.selectionList[indexPath.row].type_cd! < self.nonSelectionList[count].type_cd! {
                        row = count
                        trigger = false
                        break
                    }
                }
            }
            if self.nonSelectionList.count == 0 || trigger == true {
                row = self.nonSelectionList.count
            }
            tableView.insertRows(at: [IndexPath.init(row: row!, section: 1)], with: .automatic)
            
            guard listDAO.editTurn(tableName: self.selectionList[indexPath.row].tableName!, turn: Int32(20)) == true else {
                self.warningAlert("데이터 수정 실패!")
                return
            }
            self.selectionList = listDAO.findListData(selection: true)
            self.nonSelectionList = listDAO.findListData(selection: false)
            
            // 선택한 row 삭제
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            // 선택한 row 라벨 텍스트 삽입
            let newCell = self.tableView.cellForRow(at: IndexPath.init(row: row!, section: 1))
            newCell?.textLabel?.text = self.nonSelectionList[row!].type
        }
        
        if indexPath.section == 1 {
            // 선택한 row 추가
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath.init(row: self.selectionList.count, section: 0)], with: .automatic)
            
            guard listDAO.editTurn(tableName: self.nonSelectionList[indexPath.row].tableName!, turn: Int32(self.selectionList.count)) == true else {
                self.warningAlert("데이터 수정 실패!")
                return
            }
            self.selectionList = listDAO.findListData(selection: true)
            self.nonSelectionList = listDAO.findListData(selection: false)
            
            // 선택한 row 삭제
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            // 선택한 row 라벨 텍스트 삽입
            let newCell = self.tableView.cellForRow(at: IndexPath.init(row: self.selectionList.count - 1, section: 0))
            newCell?.textLabel?.text = self.selectionList[self.selectionList.count - 1].type
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard destinationIndexPath.section == 0 else {
            tableView.reloadData()
            return
        }
    }
 
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
}
