//
//  MaterialPriceCandleChartVC.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2018. 2. 11..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit
import Firebase

class MaterialPriceCandleChartVC: UIViewController, CHKLineChartDelegate, CustomDateFormatter {
    
    // MARK: - @IBOutlet Property
    @IBOutlet var chartView: CHKLineChartView!
    @IBOutlet var rightBarButton: UIBarButtonItem!
    
    // MARK: - Property
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var param: MaterialPriceListVO?
    lazy var priceData: [NSArray] = {
        let dao = MaterialPriceJsonDataDAO()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var components = DateComponents()
        components.year = -1
        
        let date: String? = formatter.string(from: calendar.date(byAdding: components, to: Date())!)
        
        return dao.find(tableName: (param?.tableName)!, dateFrom: date)
    }()
    
    // MARK: - override / protocol Method
    override func viewDidLoad() {
        // 이벤트 기록
        Analytics.logEvent("원자재_캔들차트_화면", parameters: ["원자재_캔들차트_화면": "원자재_캔들차트_화면" as NSObject])
        
        self.navigationItem.title = self.param?.type
        
        self.chartView.delegate = self
        self.chartView.style = CHKLineChartStyle.base
        self.chartView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfPointsInKLineChart(chart: CHKLineChartView) -> Int {
        return self.priceData.count
    }
    
    func kLineChart(chart: CHKLineChartView, valueForPointAtIndex index: Int) -> CHChartItem {
        let data = self.priceData[index] as! [String]
        let item = CHChartItem()
        if (self.param?.tableName)! == MaterialType.steel.table() {
            item.openPrice = CGFloat(data[2].customFloatConverter)
            item.highPrice = CGFloat(data[3].customFloatConverter)
            item.lowPrice = CGFloat(data[4].customFloatConverter)
            item.closePrice = CGFloat(data[5].customFloatConverter)
            item.vol = CGFloat(data[9].customFloatConverter)
        } else {
            item.openPrice = CGFloat(data[1].customFloatConverter)
            item.highPrice = CGFloat(data[2].customFloatConverter)
            item.lowPrice = CGFloat(data[3].customFloatConverter)
            item.closePrice = CGFloat(data[4].customFloatConverter)
            if (self.param?.tableName)! == MaterialType.bitcoin.table() {
                item.vol = CGFloat(data[5].customFloatConverter)
            } else {
                item.vol = CGFloat(data[7].customFloatConverter)
            }
        }
        return item
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnYAxisForValue value: CGFloat, section: CHSection) -> String {
        var strValue = ""
        if value / 10000 > 1 {
            strValue = (value / 10000).ch_toString(maxF: section.decimal) + "만"
        } else {
            strValue = value.ch_toString(maxF: section.decimal)
        }
        return strValue
    }
    
    func kLineChart(chart: CHKLineChartView, labelOnXAxisForIndex index: Int) -> String {
        let data = self.priceData[index] as! [String]
        return self.convertDateFormat(fromFormat: "yyyyMMdd", toFormat: "yyMMdd", date: data[0])
    }
    
    // 각 파티션의 소수 자릿수 조정
    func kLineChart(chart: CHKLineChartView, decimalAt section: Int) -> Int {
        return 2
    }
    
    // Y축 레이블 너비 조정
    func widthForYAxisLabel(in chart: CHKLineChartView) -> CGFloat {
        return chart.kYAxisLabelWidth
    }
    
    // MARK: - @IBAction Method
    @IBAction func rightBarButtonClicked(_ sender: UIBarButtonItem) {
        //self.appDelegate.isLoadingChart = true
        self.navigationController?.popViewController(animated: true)
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MaterialPriceChartView") as? MaterialPriceChartVC else {
            return
        }
        vc.param = self.param
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
