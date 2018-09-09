//
//  MaterialPriceChartVC.swift
//  RawMaterialPrice
//
//  Created by 박수성 on 2018. 2. 18..
//  Copyright © 2018년 dbspark7. All rights reserved.
//

import UIKit
import Firebase

class MaterialPriceChartVC: UIViewController, ChartDelegate, CustomDateFormatter {
    
    // MARK: - @IBOutlet Property
    @IBOutlet var priceLabelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet var dateLabelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var chart: Chart!
    @IBOutlet var dataFromLabel: UILabel!
    @IBOutlet var segmentControl: UISegmentedControl!
    
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var button4: UIButton!
    @IBOutlet var button5: UIButton!
    @IBOutlet var button6: UIButton!
    @IBOutlet var button7: UIButton!
    @IBOutlet var button8: UIButton!
    @IBOutlet var button9: UIButton!
    @IBOutlet var button10: UIButton!
    @IBOutlet var button11: UIButton!
    @IBOutlet var button12: UIButton!
    
    @IBOutlet var date: UILabel!
    @IBOutlet var label1: UILabel!
    @IBOutlet var label2: UILabel!
    @IBOutlet var label3: UILabel!
    @IBOutlet var label4: UILabel!
    @IBOutlet var label5: UILabel!
    @IBOutlet var label6: UILabel!
    @IBOutlet var label7: UILabel!
    @IBOutlet var label8: UILabel!
    @IBOutlet var label9: UILabel!
    @IBOutlet var label10: UILabel!
    @IBOutlet var label11: UILabel!
    @IBOutlet var label12: UILabel!
    
    // MARK: - Property
    fileprivate var priceLabelLeadingMarginInitialConstant: CGFloat!
    fileprivate var dateLabelLeadingMarginInitialConstant: CGFloat!
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var param: MaterialPriceListVO?
    
    lazy var priceData: [NSArray] = {
        return findPriceData()
    }()
    
    // MARK: - override / protocol Method
    override func viewDidLoad() {
        // 이벤트 기록
        Analytics.logEvent("원자재_차트_화면", parameters: ["원자재_차트_화면": "원자재_차트_화면" as NSObject])
        
        if let type = self.param?.type, let dataFrom = self.param?.dataFrom {
            self.navigationItem.title = type
            self.dataFromLabel.text = "Data from \(dataFrom) of Quandl"
        }
        priceLabelLeadingMarginInitialConstant = priceLabelLeadingMarginConstraint.constant
        dateLabelLeadingMarginInitialConstant = dateLabelLeadingMarginConstraint.constant
        self.initializeChart()
        self.setup()
        
        if (self.param?.tableName)! != MaterialType.wtiCrudeOil.table() && (self.param?.tableName)! != MaterialType.brentCrudeOil.table() && (self.param?.tableName)! != MaterialType.naturalGas.table() && (self.param?.tableName)! != MaterialType.steel.table() && (self.param?.tableName)! != MaterialType.bitcoin.table() {
            self.navigationItem.rightBarButtonItem = nil
        }
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
        
        if let date = priceData[indexes[0]!][0] as? String {
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
    
    // MARK: - Method
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
        chart.lineWidth = 1
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
    
    private func setup() {
        guard let data = self.priceData.last else { return }
        self.date.text = "\(self.convertDateFormat(fromFormat: "yyyyMMdd", toFormat: "yyyy-MM-dd", date: data[0] as! String)) 가격"
        switch (self.param?.tableName)! {
        case MaterialType.wtiCrudeOil.table(),
             MaterialType.naturalGas.table():
            self.button1.setTitle("Open", for: .normal)
            self.label1.text = (data[1] as! String).customFloatConverter.customStringConverter + "$"
            self.button2.setTitle("High", for: .normal)
            self.label2.text = (data[2] as! String).customFloatConverter.customStringConverter + "$"
            self.button3.setTitle("Low", for: .normal)
            self.label3.text = (data[3] as! String).customFloatConverter.customStringConverter + "$"
            self.button4.setTitle("Last", for: .normal)
            self.label4.text = (data[4] as! String).customFloatConverter.customStringConverter + "$"
            self.button5.setTitle("Change", for: .normal)
            self.label5.text = (data[5] as! String).customFloatConverter.customStringConverter + "$"
            self.button6.setTitle("Settle", for: .normal)
            self.label6.text = (data[6] as! String).customFloatConverter.customStringConverter + "$"
            self.button7.setTitle("Volume", for: .normal)
            self.label7.text = (data[7] as! String).customFloatConverter.customStringConverter
            self.button8.setTitle("Previous Day Open Interest", for: .normal)
            self.button8.titleLabel?.font = UIFont.systemFont(ofSize: 8)
            self.label8.text = (data[8] as! String).customFloatConverter.customStringConverter
            self.button9.isHidden = true
            self.label9.isHidden = true
            self.button10.isHidden = true
            self.label10.isHidden = true
            self.button11.isHidden = true
            self.label11.isHidden = true
            self.button12.isHidden = true
            self.label12.isHidden = true
        case MaterialType.brentCrudeOil.table():
            self.button1.setTitle("Open", for: .normal)
            self.label1.text = (data[1] as! String).customFloatConverter.customStringConverter + "$"
            self.button2.setTitle("High", for: .normal)
            self.label2.text = (data[2] as! String).customFloatConverter.customStringConverter + "$"
            self.button3.setTitle("Low", for: .normal)
            self.label3.text = (data[3] as! String).customFloatConverter.customStringConverter + "$"
            self.button4.setTitle("Last", for: .normal)
            self.label4.text = (data[4] as! String).customFloatConverter.customStringConverter + "$"
            self.button5.setTitle("Change", for: .normal)
            self.label5.text = (data[5] as! String).customFloatConverter.customStringConverter + "$"
            self.button6.setTitle("Settle", for: .normal)
            self.label6.text = (data[6] as! String).customFloatConverter.customStringConverter + "$"
            self.button7.setTitle("Volume", for: .normal)
            self.label7.text = (data[7] as! String).customFloatConverter.customStringConverter
            self.button8.setTitle("Previous Day Open Interest", for: .normal)
            self.button8.titleLabel?.font = UIFont.systemFont(ofSize: 8)
            self.label8.text = (data[8] as! String).customFloatConverter.customStringConverter
            self.button9.setTitle("EFP Volume", for: .normal)
            self.label9.text = (data[9] as! String).customFloatConverter.customStringConverter
            self.button10.setTitle("EFS Volume", for: .normal)
            self.label10.text = (data[10] as! String).customFloatConverter.customStringConverter
            self.button11.setTitle("Block Volume", for: .normal)
            self.label11.text = (data[11] as! String).customFloatConverter.customStringConverter
            self.button12.isHidden = true
            self.label12.isHidden = true
        case MaterialType.opecCrudeOil.table(),
             MaterialType.iron.table():
            self.button1.setTitle("Value", for: .normal)
            self.label1.text = (data[1] as! String).customFloatConverter.customStringConverter + "$"
            self.button2.isHidden = true
            self.label2.isHidden = true
            self.button3.isHidden = true
            self.label3.isHidden = true
            self.button4.isHidden = true
            self.label4.isHidden = true
            self.button5.isHidden = true
            self.label5.isHidden = true
            self.button6.isHidden = true
            self.label6.isHidden = true
            self.button7.isHidden = true
            self.label7.isHidden = true
            self.button8.isHidden = true
            self.label8.isHidden = true
            self.button9.isHidden = true
            self.label9.isHidden = true
            self.button10.isHidden = true
            self.label10.isHidden = true
            self.button11.isHidden = true
            self.label11.isHidden = true
            self.button12.isHidden = true
            self.label12.isHidden = true
        case MaterialType.coal.table():
            self.button1.setTitle("Central Appalachia", for: .normal)
            self.label1.text = (data[1] as! String).customFloatConverter.customStringConverter + "$"
            self.button2.setTitle("Northern Appalachia", for: .normal)
            self.label2.text = (data[2] as! String).customFloatConverter.customStringConverter + "$"
            self.button3.setTitle("Illinois Basin", for: .normal)
            self.label3.text = (data[3] as! String).customFloatConverter.customStringConverter + "$"
            self.button4.setTitle("Powder River Basin", for: .normal)
            self.label4.text = (data[4] as! String).customFloatConverter.customStringConverter + "$"
            self.button5.setTitle("Uinta Basin", for: .normal)
            self.label5.text = (data[5] as! String).customFloatConverter.customStringConverter + "$"
            self.button6.isHidden = true
            self.label6.isHidden = true
            self.button7.isHidden = true
            self.label7.isHidden = true
            self.button8.isHidden = true
            self.label8.isHidden = true
            self.button9.isHidden = true
            self.label9.isHidden = true
            self.button10.isHidden = true
            self.label10.isHidden = true
            self.button11.isHidden = true
            self.label11.isHidden = true
            self.button12.isHidden = true
            self.label12.isHidden = true
        case MaterialType.aluminum.table(),
             MaterialType.copper.table(),
             MaterialType.lead.table(),
             MaterialType.nickel.table(),
             MaterialType.tin.table(),
             MaterialType.zinc.table():
            self.button1.setTitle("Cash Buyer", for: .normal)
            self.label1.text = (data[1] as! String).customFloatConverter.customStringConverter + "$"
            self.button2.setTitle("Cash Seller", for: .normal)
            self.label2.text = (data[2] as! String).customFloatConverter.customStringConverter + "$"
            self.button3.setTitle("3-months Buyer", for: .normal)
            self.label3.text = (data[3] as! String).customFloatConverter.customStringConverter + "$"
            self.button4.setTitle("3-months Seller", for: .normal)
            self.label4.text = (data[4] as! String).customFloatConverter.customStringConverter + "$"
            self.button5.setTitle("15-months Buyer", for: .normal)
            self.label5.text = (data[5] as! String).customFloatConverter.customStringConverter + "$"
            self.button6.setTitle("15-months Seller", for: .normal)
            self.label6.text = (data[6] as! String).customFloatConverter.customStringConverter + "$"
            self.button7.setTitle("Dec 1 Buyer", for: .normal)
            self.label7.text = (data[7] as! String).customFloatConverter.customStringConverter + "$"
            self.button8.setTitle("Dec 1 Seller", for: .normal)
            self.label8.text = (data[8] as! String).customFloatConverter.customStringConverter + "$"
            self.button9.setTitle("Dec 2 Buyer", for: .normal)
            self.label9.text = (data[9] as! String).customFloatConverter.customStringConverter + "$"
            self.button10.setTitle("Dec 2 Seller", for: .normal)
            self.label10.text = (data[10] as! String).customFloatConverter.customStringConverter + "$"
            self.button11.setTitle("Dec 3 Buyer", for: .normal)
            self.label11.text = (data[11] as! String).customFloatConverter.customStringConverter + "$"
            self.button12.setTitle("Dec 3 Seller", for: .normal)
            self.label12.text = (data[12] as! String).customFloatConverter.customStringConverter + "$"
        case MaterialType.cobalt.table(),
             MaterialType.molybdenum.table():
            self.button1.setTitle("Cash Buyer", for: .normal)
            self.label1.text = (data[1] as! String).customFloatConverter.customStringConverter + "$"
            self.button2.setTitle("Cash Seller", for: .normal)
            self.label2.text = (data[2] as! String).customFloatConverter.customStringConverter + "$"
            self.button3.setTitle("3-months Buyer", for: .normal)
            self.label3.text = (data[3] as! String).customFloatConverter.customStringConverter + "$"
            self.button4.setTitle("3-months Seller", for: .normal)
            self.label4.text = (data[4] as! String).customFloatConverter.customStringConverter + "$"
            self.button5.setTitle("15-months Buyer", for: .normal)
            self.label5.text = (data[5] as! String).customFloatConverter.customStringConverter + "$"
            self.button6.setTitle("15-months Seller", for: .normal)
            self.label6.text = (data[6] as! String).customFloatConverter.customStringConverter + "$"
            self.button7.isHidden = true
            self.label7.isHidden = true
            self.button8.isHidden = true
            self.label8.isHidden = true
            self.button9.isHidden = true
            self.label9.isHidden = true
            self.button10.isHidden = true
            self.label10.isHidden = true
            self.button11.isHidden = true
            self.label11.isHidden = true
            self.button12.isHidden = true
            self.label12.isHidden = true
        case MaterialType.steel.table():
            self.button1.setTitle("Pre Settle", for: .normal)
            self.label1.text = (data[1] as! String).customFloatConverter.customStringConverter + "元"
            self.button2.setTitle("Open", for: .normal)
            self.label2.text = (data[2] as! String).customFloatConverter.customStringConverter + "元"
            self.button3.setTitle("High", for: .normal)
            self.label3.text = (data[3] as! String).customFloatConverter.customStringConverter + "元"
            self.button4.setTitle("Low", for: .normal)
            self.label4.text = (data[4] as! String).customFloatConverter.customStringConverter + "元"
            self.button5.setTitle("Close", for: .normal)
            self.label5.text = (data[5] as! String).customFloatConverter.customStringConverter + "元"
            self.button6.setTitle("Settle", for: .normal)
            self.label6.text = (data[6] as! String).customFloatConverter.customStringConverter + "元"
            self.button7.setTitle("Ch1", for: .normal)
            self.label7.text = (data[7] as! String).customFloatConverter.customStringConverter
            self.button8.setTitle("Ch2", for: .normal)
            self.label8.text = (data[8] as! String).customFloatConverter.customStringConverter
            self.button9.setTitle("Volume", for: .normal)
            self.label9.text = (data[9] as! String).customFloatConverter.customStringConverter
            self.button10.setTitle("O.I.", for: .normal)
            self.label10.text = (data[10] as! String).customFloatConverter.customStringConverter
            self.button11.setTitle("Change", for: .normal)
            self.label11.text = (data[11] as! String).customFloatConverter.customStringConverter
            self.button12.isHidden = true
            self.label12.isHidden = true
        case MaterialType.gold.table():
            self.button1.setTitle("USD AM", for: .normal)
            self.label1.text = (data[1] as! String).customFloatConverter.customStringConverter + "$"
            self.button2.setTitle("USD PM", for: .normal)
            self.label2.text = (data[2] as! String).customFloatConverter.customStringConverter + "$"
            self.button3.setTitle("GBP AM", for: .normal)
            self.label3.text = (data[3] as! String).customFloatConverter.customStringConverter + "$"
            self.button4.setTitle("GBP PM", for: .normal)
            self.label4.text = (data[4] as! String).customFloatConverter.customStringConverter + "$"
            self.button5.setTitle("EURO AM", for: .normal)
            self.label5.text = (data[5] as! String).customFloatConverter.customStringConverter + "$"
            self.button6.setTitle("EURO PM", for: .normal)
            self.label6.text = (data[6] as! String).customFloatConverter.customStringConverter + "$"
            self.button7.isHidden = true
            self.label7.isHidden = true
            self.button8.isHidden = true
            self.label8.isHidden = true
            self.button9.isHidden = true
            self.label9.isHidden = true
            self.button10.isHidden = true
            self.label10.isHidden = true
            self.button11.isHidden = true
            self.label11.isHidden = true
            self.button12.isHidden = true
            self.label12.isHidden = true
        case MaterialType.silver.table():
            self.button1.setTitle("USD", for: .normal)
            self.label1.text = (data[1] as! String).customFloatConverter.customStringConverter + "$"
            self.button2.setTitle("GBP", for: .normal)
            self.label2.text = (data[2] as! String).customFloatConverter.customStringConverter + "$"
            self.button3.setTitle("EURO", for: .normal)
            self.label3.text = (data[3] as! String).customFloatConverter.customStringConverter + "$"
            self.button4.isHidden = true
            self.label4.isHidden = true
            self.button5.isHidden = true
            self.label5.isHidden = true
            self.button6.isHidden = true
            self.label6.isHidden = true
            self.button7.isHidden = true
            self.label7.isHidden = true
            self.button8.isHidden = true
            self.label8.isHidden = true
            self.button9.isHidden = true
            self.label9.isHidden = true
            self.button10.isHidden = true
            self.label10.isHidden = true
            self.button11.isHidden = true
            self.label11.isHidden = true
            self.button12.isHidden = true
            self.label12.isHidden = true
        case MaterialType.platinum.table(),
             MaterialType.palladium.table():
            self.button1.setTitle("USD AM", for: .normal)
            self.label1.text = (data[1] as! String).customFloatConverter.customStringConverter + "$"
            self.button2.setTitle("EUR AM", for: .normal)
            self.label2.text = (data[2] as! String).customFloatConverter.customStringConverter + "$"
            self.button3.setTitle("GBP AM", for: .normal)
            self.label3.text = (data[3] as! String).customFloatConverter.customStringConverter + "$"
            self.button4.setTitle("USD PM", for: .normal)
            self.label4.text = (data[4] as! String).customFloatConverter.customStringConverter + "$"
            self.button5.setTitle("EUR PM", for: .normal)
            self.label5.text = (data[5] as! String).customFloatConverter.customStringConverter + "$"
            self.button6.setTitle("GBP PM", for: .normal)
            self.label6.text = (data[6] as! String).customFloatConverter.customStringConverter + "$"
            self.button7.isHidden = true
            self.label7.isHidden = true
            self.button8.isHidden = true
            self.label8.isHidden = true
            self.button9.isHidden = true
            self.label9.isHidden = true
            self.button10.isHidden = true
            self.label10.isHidden = true
            self.button11.isHidden = true
            self.label11.isHidden = true
            self.button12.isHidden = true
            self.label12.isHidden = true
        case MaterialType.bitcoin.table():
            self.button1.setTitle("Open", for: .normal)
            self.label1.text = (data[1] as! String).customFloatConverter.customStringConverter + "$"
            self.button2.setTitle("High", for: .normal)
            self.label2.text = (data[2] as! String).customFloatConverter.customStringConverter + "$"
            self.button3.setTitle("Low", for: .normal)
            self.label3.text = (data[3] as! String).customFloatConverter.customStringConverter + "$"
            self.button4.setTitle("Close", for: .normal)
            self.label4.text = (data[4] as! String).customFloatConverter.customStringConverter + "$"
            self.button5.setTitle("Volume", for: .normal)
            self.label5.text = (data[5] as! String).customFloatConverter.customStringConverter
            self.button6.isHidden = true
            self.label6.isHidden = true
            self.button7.isHidden = true
            self.label7.isHidden = true
            self.button8.isHidden = true
            self.label8.isHidden = true
            self.button9.isHidden = true
            self.label9.isHidden = true
            self.button10.isHidden = true
            self.label10.isHidden = true
            self.button11.isHidden = true
            self.label11.isHidden = true
            self.button12.isHidden = true
            self.label12.isHidden = true
        default:
            ()
        }
    }
    
    private func getStockValues() -> Array<Dictionary<String, Any>> {
        var result = Array<Dictionary<String, Any>>()
        for data in self.priceData {
            switch (self.param?.tableName)! {
            case MaterialType.wtiCrudeOil.table(),
                 MaterialType.naturalGas.table(),
                 MaterialType.steel.table():
                result.append(["date": data[0], "close": data[6]])
            case MaterialType.brentCrudeOil.table(),
                 MaterialType.bitcoin.table():
                result.append(["date": data[0], "close": data[4]])
            case MaterialType.opecCrudeOil.table(),
                 MaterialType.iron.table(),
                 MaterialType.gold.table(),
                 MaterialType.silver.table(),
                 MaterialType.platinum.table(),
                 MaterialType.palladium.table():
                result.append(["date": data[0], "close": data[1]])
            case MaterialType.coal.table():
                result.append(["date": data[0], "close": data[2]])
            case MaterialType.aluminum.table(),
                 MaterialType.cobalt.table(),
                 MaterialType.copper.table(),
                 MaterialType.lead.table(),
                 MaterialType.molybdenum.table(),
                 MaterialType.nickel.table(),
                 MaterialType.tin.table(),
                 MaterialType.zinc.table():
                result.append(["date": data[0], "close": data[3]])
            default:
                ()
            }
        }
        return result
    }
    
    private func findPriceData() -> [NSArray] {
        let dao = MaterialPriceJsonDataDAO()
        
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
    
    @IBAction func rightBarButtonClicked(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "MaterialPriceCandleChartView") as? MaterialPriceCandleChartVC else {
            return
        }
        vc.param = self.param
        self.navigationController?.pushViewController(vc, animated: false)
    }
}
