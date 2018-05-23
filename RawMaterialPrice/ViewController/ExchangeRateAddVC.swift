//
//  ExchangeRateAddVC.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2018. 2. 5..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit

class ExchangeRateAddVC: UITableViewController {
    
    let listDAO = ExchangeRateListDAO()
    
    lazy var selectionList: [ExchangeRateListVO] = {
        return listDAO.findListData(selection: true)
    }()
    
    lazy var nonSelectionList: [ExchangeRateListVO] = {
        return listDAO.findListData(selection: false)
    }()
    
    override func viewDidLoad() {
        self.tableView.allowsSelectionDuringEditing = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.isEditing = true
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "stateCell")
        
        if indexPath.section == 0 {
            cell?.textLabel?.text = self.selectionList[indexPath.row].type
        } else {
            cell?.textLabel?.text = self.nonSelectionList[indexPath.row].type
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
        tableView.beginUpdates()
        if indexPath.section == 0 {
            // 포함된 항목에서 제거되는 항목은 turn을 21로 수정
            guard listDAO.editTurn(tableName: self.selectionList[indexPath.row].tableName!, turn: Int32(21)) == true else {
                self.warningAlert("데이터 수정 실패!")
                return
            }
            
            // 제거되는 항목 이후의 항목은 turn 값을 1씩 차감
            for row in indexPath.row + 1..<self.selectionList.count {
                guard listDAO.editTurn(tableName: self.selectionList[row].tableName!, turn: Int32(row - 1)) == true else {
                    self.warningAlert("데이터 수정 실패!")
                    return
                }
            }
            
            // 제거되는 항목의 row 삭제
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // section 1에 제거되는 항목의 row 삽입
            for row in (0..<self.nonSelectionList.count).reversed() {
                if self.selectionList[indexPath.row].state_cd! > self.nonSelectionList[row].state_cd! {
                    tableView.insertRows(at: [IndexPath.init(row: row + 1, section: 1)], with: .automatic)
                    break
                } else if row == 0 {
                    tableView.insertRows(at: [IndexPath.init(row: row, section: 1)], with: .automatic)
                }
            }
        } else {
            // 포함된 항목으로 추가되는 항목은 turn을 포함된 항목의 count 값으로 수정
            guard listDAO.editTurn(tableName: self.nonSelectionList[indexPath.row].tableName!, turn: Int32(self.selectionList.count)) == true else {
                self.warningAlert("데이터 수정 실패!")
                return
            }
            
            // 포함된 항목의 row 삭제
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // section 0에 포함된 row 삽입
            tableView.insertRows(at: [IndexPath.init(row: self.selectionList.count, section: 0)], with: .automatic)
        }
        
        // 리스트 갱신
        self.selectionList = listDAO.findListData(selection: true)
        self.nonSelectionList = listDAO.findListData(selection: false)
        
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // selectionList의 turn에 목적지 row 반영
        guard listDAO.editTurn(tableName: self.selectionList[sourceIndexPath.row].tableName!, turn: Int32(destinationIndexPath.row)) == true else {
            self.warningAlert("데이터 수정 실패!")
            return
        }
        
        // 출발점 row가 목적지 row보다 뒤에 있을 때
        if sourceIndexPath.row > destinationIndexPath.row {
            // 목적지 row부터 출발점 row - 1까지 selectionList의 turn에 row + 1 반영
            for row in destinationIndexPath.row..<sourceIndexPath.row {
                guard listDAO.editTurn(tableName: self.selectionList[row].tableName!, turn: Int32(row + 1)) == true else {
                    self.warningAlert("데이터 수정 실패!")
                    return
                }
            }
        } else { // 출발점 row가 목적지 row보다 앞에 있을 때
            // 출발점 row + 1부터 목적지 row까지 selectionList의 turn에 row - 1 반영
            for row in sourceIndexPath.row + 1...destinationIndexPath.row {
                guard listDAO.editTurn(tableName: self.selectionList[row].tableName!, turn: Int32(row - 1)) == true else {
                    self.warningAlert("데이터 수정 실패!")
                    return
                }
            }
        }
        // selectionList 갱신
        self.selectionList = listDAO.findListData(selection: true)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
}
