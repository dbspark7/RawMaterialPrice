//
//  ExchangeRateChartVC.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2018. 2. 13..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit
import Firebase

class ExchangeRateChartVC: UIViewController, ChartDelegate, CustomDateFormatter {
    
    // MARK: - @IBOutlet Property
    @IBOutlet var priceLabelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet var dateLabelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var chart: Chart!
    @IBOutlet var segmentControl: UISegmentedControl!
    
    @IBOutlet var date: UILabel!
    @IBOutlet var ttb: UILabel!
    @IBOutlet var tts: UILabel!
    @IBOutlet var deal_bas_r: UILabel!
    @IBOutlet var bkpr: UILabel!
    @IBOutlet var yy_efee_r: UILabel!
    @IBOutlet var ten_dd_efee_r: UILabel!
    @IBOutlet var kftc_bkpr: UILabel!
    @IBOutlet var kftc_deal_bas_r: UILabel!
    
    // MARK: - Property
    fileprivate var priceLabelLeadingMarginInitialConstant: CGFloat!
    fileprivate var dateLabelLeadingMarginInitialConstant: CGFloat!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var param: ExchangeRateListVO?
    
    lazy var priceData: [ExchangeRateDataVO] = {
        return findPriceData()
    }()
    
    // MARK: - override / protocol Method
    override func viewDidLoad() {
        // 이벤트 기록
        Analytics.logEvent("환율_차트_화면", parameters: ["환율_차트_화면": "환율_차트_화면" as NSObject])
        
        self.navigationItem.title = self.param?.type
        
        priceLabelLeadingMarginInitialConstant = priceLabelLeadingMarginConstraint.constant
        dateLabelLeadingMarginInitialConstant = dateLabelLeadingMarginConstraint.constant
        self.initializeChart()
        self.setup()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        // Redraw chart on rotation
        chart.setNeedsDisplay()
    }
    
    // Chart delegate
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            
            priceLabel.text = value.customStringConverter
            
            // Align the label to the touch left position, centered
            var priceConstant = priceLabelLeadingMarginInitialConstant + left - (priceLabel.frame.width / 2)
            
            // Avoid placing the label on the left of the chart
            if priceConstant < priceLabelLeadingMarginInitialConstant {
                priceConstant = priceLabelLeadingMarginInitialConstant
            }
            
            // Avoid placing the label on the right of the chart
            let priceRightMargin = chart.frame.width - priceLabel.frame.width
            
            if priceConstant > priceRightMargin {
                priceConstant = priceRightMargin
            }
            
            priceLabelLeadingMarginConstraint.constant = priceConstant
            
            
        }
        
        if let date = priceData[indexes[0]!].date {
            self.dateLabel.text = date
            
            // Align the label to the touch left position, centered
            var dateConstant = dateLabelLeadingMarginInitialConstant + left - (dateLabel.frame.width / 2)
            
            if dateConstant < dateLabelLeadingMarginInitialConstant {
                dateConstant = dateLabelLeadingMarginInitialConstant
            }
            
            // Avoid placing the label on the right of the chart
            let dateRightMargin = chart.frame.width - dateLabel.frame.width
            
            if dateConstant > dateRightMargin {
                dateConstant = dateRightMargin
            }
            
            dateLabelLeadingMarginConstraint.constant = dateConstant
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        priceLabel.text = ""
        priceLabelLeadingMarginConstraint.constant = priceLabelLeadingMarginInitialConstant
        
        dateLabel.text = ""
        dateLabelLeadingMarginConstraint.constant = dateLabelLeadingMarginInitialConstant
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        
    }
    
    func getStockValues() -> Array<Dictionary<String, Any>> {
        var values = Array<Dictionary<String, Any>>()
        for data in self.priceData {
            values.append(["date": data.date!, "close": data.deal_bas_r!])
        }
        return values
    }
    
    // MARK: - Method
    private func setup() {
        guard let data = self.priceData.last else { return }
        self.date.text = "\(self.convertDateFormat(fromFormat: "yyyyMMdd", toFormat: "yyyy-MM-dd", date: data.date!)) 가격"
        self.ttb.text = data.ttb! + "₩"
        self.tts.text = data.tts! + "₩"
        self.deal_bas_r.text = data.deal_bas_r! + "₩"
        self.bkpr.text = data.bkpr! + "₩"
        self.yy_efee_r.text = data.yy_efee_r
        self.ten_dd_efee_r.text = data.ten_dd_efee_r
        self.kftc_bkpr.text = data.kftc_bkpr! + "₩"
        self.kftc_deal_bas_r.text = data.kftc_deal_bas_r! + "₩"
    }
    
    private func initializeChart() {
        chart.delegate = self
        
        // Initialize data series and labels
        let stockValues = getStockValues()
        
        var serieData: [Double] = []
        //var labels: [Double] = []
        var labelsAsString: Array<String> = []
        
        for (_, value) in stockValues.enumerated() {
            serieData.append((value["close"] as! String).customDoubleConverter)
        }
        
        let series = ChartSeries(serieData)
        series.area = true
        
        // Configure chart layout
        chart.lineWidth = 1//0.5
        chart.labelFont = UIFont.systemFont(ofSize: 12)
        chart.xLabels = []
        chart.xLabelsFormatter = { (labelIndex: Int, labelValue: Double) -> String in
            return labelsAsString[labelIndex]
        }
        //chart.xLabelsTextAlignment = .center
        chart.yLabelsOnRightSide = true
        // Add some padding above the x-axis
        chart.minY = serieData.min()! - 5
        
        chart.add(series)
    }
    
    private func findPriceData() -> [ExchangeRateDataVO] {
        let dao = ExchangeRateJsonDataDAO()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var components = DateComponents()
        switch self.segmentControl.selectedSegmentIndex {
        case 0:
            components.day = -15
        case 1:
            components.month = -3
        case 2:
            components.month = -6
        case 3:
            components.year = -1
        case 4:
            components.year = -3
        case 5:
            components.year = -5
        default:
            return dao.find(tableName: (param?.tableName)!)
        }
        
        let date: String? = formatter.string(from: calendar.date(byAdding: components, to: Date())!)
        
        return dao.find(tableName: (param?.tableName)!, dateFrom: date)
    }
    
    // MARK: - @IBAction Method
    @IBAction func segmentControlClicked(_ sender: UISegmentedControl) {
        self.priceLabel.text = ""
        self.dateLabel.text = ""
        self.priceData = findPriceData()
        self.chart.removeAllSeries()
        self.initializeChart()
    }
}
