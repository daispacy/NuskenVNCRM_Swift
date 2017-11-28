//
//  ChartStatisticsSales.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 9/23/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import Charts
import Charts.Swift

class ChartStatisticsCombined: CViewSwitchLanguage {

    var months: [String]!
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var chartView: CombinedChartView!
    @IBOutlet weak var chartViewSales: CombinedChartView!
    @IBOutlet weak var chartViewSales1: CombinedChartView!
    
    @IBOutlet var lblTitleChart: UILabel!
    @IBOutlet var lblProcess: UILabel!
    @IBOutlet var lblUnprocess: UILabel!
    
    @IBOutlet weak var lblFirst: UILabel!
    @IBOutlet weak var lblSecond: UILabel!
    @IBOutlet weak var lblThird: UILabel!
    @IBOutlet weak var lblMarkOne: UILabel!
    @IBOutlet weak var lblMarkTwo: UILabel!
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()

        configChart()                
    }
    
    override func reloadTexts() {
        // set text here
    }
    
    // MARK: - INTERFACE
    func loadData(_ from:NSDate? = nil,_ to:NSDate? = nil,_ lifetime:Bool = true,_ customer:Customer? = nil) {
        
        let calendar = Calendar.current
        // Calculate start and end of the current year (or month with `.month`):
        let days1 = calendar.dateComponents([.day], from: from! as Date, to: to! as Date)
        var toDate = to
        if Int(days1.day!) > 300 && (toDate! as Date).currentYear == Date().currentYear{
            toDate = Date() as NSDate
        }
        
        UserManager.getDataOrderStatus(from, toDate: toDate, isLifeTime: lifetime,customer) {[weak self] data in
            guard let _self = self else {return}
            DispatchQueue.main.async {
                var valuesOrders:[[Double]] = []
                var valuesSales:[[Double]] = []
                var titles:[String] = []
                if data.count > 0 {
                    for item in data {
                        titles.append(item["date"] as! String)
                        if let dt = item["data"] as? JSON {
                            if let price1 = Double(dt["total_orders_price_process"] as! String),
                                let price2 = Double(dt["total_orders_price_unprocess"] as! String),
                                let total1 = Double(dt["total_orders_processed"] as! String),
                                let total2 = Double(dt["total_orders_not_processed"] as! String) {
                                
                                valuesOrders.append([total1,total2])
                                valuesSales.append([price1,price2])
                            }
                        }
                    }
                }
                if titles.count == 3 {
                    _self.setTitleOption(one: titles[0], two: titles[1], three: titles[2])
                } else {
                    _self.lblFirst.text = ""
                    _self.lblSecond.text = ""
                    _self.lblThird.text = ""
                }
                _self.setChart([], values: valuesOrders, valuesSales: valuesSales)
            }
        }
    }
    
    func setChart(_ dataPoints: [String], values: [[Double]], valuesSales:[[Double]]) {
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        chartView.xAxis.labelCount = dataPoints.count;
//        chartViewSales.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
//        chartViewSales.xAxis.labelCount = dataPoints.count;
       
        // line
        let barData = self.generateBarData(values.flatMap{$0.first!}, values.flatMap{$0.last!})
        
        let chartData = CombinedChartData()
        chartData.barData = barData
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        let valuesNumberFormatter = ChartValueFormatter(numberFormatter: numberFormatter)
        barData.setValueFormatter(valuesNumberFormatter)
        
        chartData.setValueTextColor(UIColor(hex:Theme.colorDBTextNormal))
        chartData.setValueFont(UIFont(name: Theme.font.normal, size: Theme.fontSize.normal))
        
        chartView.data = chartData
        chartView.animate(yAxisDuration: 1.5)
        
        // line1
        let lineData1 = self.generateLineData(valuesSales.flatMap{$0.first!})
        
        let chartData1 = CombinedChartData()
        chartData1.lineData = lineData1
        let lineFormatter = PriceValueFormatter(numberFormatter: numberFormatter)
        lineData1.setValueFormatter(lineFormatter)
        
        chartData1.setValueTextColor(UIColor(hex:Theme.colorDBTextNormal))
        chartData1.setValueFont(UIFont(name: Theme.font.normal, size: Theme.fontSize.normal))
        
        chartViewSales.data = chartData1
        chartViewSales.animate(xAxisDuration: 1.5)
        
        // line2
        let lineData2 = self.generateLineData2(valuesSales.flatMap{$0.last!})
        
        let chartData2 = CombinedChartData()
        chartData2.lineData = lineData2
        
        lineData2.setValueFormatter(lineFormatter)
        
        chartData2.setValueTextColor(UIColor(hex:Theme.colorDBTextNormal))
        chartData2.setValueFont(UIFont(name: Theme.font.normal, size: Theme.fontSize.normal))
        
        chartViewSales1.data = chartData2
        chartViewSales1.animate(xAxisDuration: 1.5)
        
        if chartViewSales.data!.yMax > chartViewSales1.data!.yMax {
            chartViewSales1.leftAxis.axisMaximum = chartViewSales.data!.yMax
        } else {
            chartViewSales.leftAxis.axisMaximum = chartViewSales1.data!.yMax
        }
    }
    
    func setTitleOption(one:String,two:String, three:String) {
        lblFirst.text = one
        lblSecond.text = two
        lblThird.text = three
    }
    // MARK: - PRIVATE
    func generateLineData(_ values1:[Double]) -> LineChartData {
        let d:LineChartData = LineChartData()
        
        var entries:[ChartDataEntry] = []
        
        var i:Double = 0
        for item in values1 {
            entries.append(ChartDataEntry(x: i, y: item/1000000))
            i += 1
        }
        
        let set:LineChartDataSet = LineChartDataSet(values: entries, label: "")
        set.setColor(UIColor(hex:"0x008ab0"))
        set.lineWidth = 1.5
        set.setCircleColor(UIColor(hex:"0x008ab0"))
        set.circleRadius = 1.0
        set.circleHoleRadius = 0.5
        set.fillColor = UIColor(hex:"0x008ab0")
        set.mode = .cubicBezier
        set.cubicIntensity = 0.1
        set.drawValuesEnabled = true
        set.valueFont = UIFont(name:Theme.font.normal,size:Theme.fontSize.small)!
        set.valueTextColor = UIColor(hex:"0x008ab0")
        set.axisDependency = .left
        set.values = entries
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//        numberFormatter.locale = Locale.current
//        let valuesNumberFormatter = PriceValueFormatter(numberFormatter: numberFormatter)
//        set.valueFormatter = valuesNumberFormatter
        
        d.addDataSet(set)
        
        return d
    }
    
    func generateLineData2(_ values1:[Double]) -> LineChartData {
        let d:LineChartData = LineChartData()
        
        var entries:[ChartDataEntry] = []
        
        var i:Double = 0
        for item in values1 {
            entries.append(ChartDataEntry(x: i, y: item/1000000))
            i += 1
        }
        
        let set:LineChartDataSet = LineChartDataSet(values: entries, label: "")
        set.setColor(UIColor(hex:"0xe30b7a"))
        set.lineWidth = 1.5
        set.setCircleColor(UIColor(hex:"0xe30b7a"))
        set.circleRadius = 1.0
        set.circleHoleRadius = 0.5
        set.fillColor = UIColor(hex:"0xe30b7a")
        set.cubicIntensity = 0.1
        set.mode = .cubicBezier
        set.drawValuesEnabled = true
        set.valueFont = UIFont(name:Theme.font.normal,size:Theme.fontSize.small)!
        set.valueTextColor = UIColor(hex:"0xe30b7a")
        set.axisDependency = .left
        set.values = entries
//        let numberFormatter = NumberFormatter()
//        numberFormatter.numberStyle = .decimal
//        numberFormatter.locale = Locale.current
//        let valuesNumberFormatter = PriceValueFormatter(numberFormatter: numberFormatter)
//        set.valueFormatter = valuesNumberFormatter
        
        d.addDataSet(set)
        
        return d
    }
    
    func generateBarData(_ values1:[Double],_ values2:[Double]) -> BarChartData {
        
        var entries1:[BarChartDataEntry] = []
        var entries2:[BarChartDataEntry] = []
        
        var i:Double = 0
        for item in values1 {
            entries1.append(BarChartDataEntry(x: i, y: item))
            i += 1
        }
        
        i = 0
        for item in values2 {
            entries2.append(BarChartDataEntry(x: i, y: item))
            i += 1
        }
        
        let set1 = BarChartDataSet(values: entries1, label: "")
        set1.setColor(UIColor(hex:"0x008ab0"))
        set1.valueFont = UIFont(name:Theme.font.bold,size:Theme.fontSize.small)!
        set1.valueTextColor = UIColor(hex:"0x008ab0")
        set1.axisDependency = .left
        
        let set2 = BarChartDataSet(values: entries2, label: "")
        set2.setColor(UIColor(hex:"0xe30b7a"))
        set2.valueFont = UIFont(name:Theme.font.bold,size:Theme.fontSize.small)!
        set2.valueTextColor = UIColor(hex:"0xe30b7a")
        set2.axisDependency = .left
        
        let groupSpace = 0.25
        let barSpace = 0.02 // x2 dataset
        let barWidth = 0.2 // x2 dataset
        // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
        
        let d = BarChartData(dataSets: [set1,set2])
        d.barWidth = barWidth
        
        // make this BarData object grouped
        d.groupBars(fromX: 0.0, groupSpace: groupSpace, barSpace: barSpace) // start at x = 0
        
        return d
    }
    
    private func configChart() {
        
        lblTitle.text = "title_chart_order".localized()
        lblMarkOne.text = "value_order_process".localized()
        lblMarkTwo.text = "value_order_unprocess".localized()
        lblProcess.text = "order_process".localized()
        lblUnprocess.text = "order_unprocess".localized()
        
        lblTitleChart.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        lblTitleChart.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblProcess.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        lblProcess.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblUnprocess.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        lblUnprocess.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblMarkOne.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        lblMarkOne.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblMarkTwo.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        lblMarkTwo.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblFirst.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblFirst.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblSecond.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblSecond.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblThird.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.normal)
        lblThird.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        // setup chart
        chartView.noDataText = "no_data_chart_summary_sales".localized()
        
        chartView.drawOrder = [
            DrawOrder.bar.rawValue
        ]
        
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelPosition = .topInside
        chartView.xAxis.granularityEnabled = false
        chartView.xAxis.labelTextColor = UIColor(hex:Theme.colorDBTextNormal)
        
        chartView.leftAxis.enabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.leftAxis.labelTextColor = UIColor(hex:Theme.colorDBTextNormal)
        chartView.rightAxis.enabled = false

        
        chartView.legend.horizontalAlignment = .center
        chartView.legend.verticalAlignment = .bottom
        chartView.legend.drawInside = false
        chartView.legend.form = .empty
        chartView.legend.orientation = .horizontal
        chartView.legend.xEntrySpace = 1.0
        chartView.legend.stackSpace = 0.1
        chartView.extraBottomOffset = -70
        
        chartView.drawBordersEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.drawBarShadowEnabled = false
        
        chartView.pinchZoomEnabled = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        chartView.backgroundColor = UIColor.clear
        chartView.barData?.highlightEnabled = false
        
        chartView.chartDescription?.text = ""
        
        // setup chart
        configChart(chart: chartViewSales)
        configChart(chart: chartViewSales1)
    }
    
    func configChart(chart:CombinedChartView) {
        // setup chart
        chart.noDataText = "".localized()
        
        chart.drawOrder = [
            DrawOrder.line.rawValue
        ]
        
        chart.xAxis.drawAxisLineEnabled = false
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.labelPosition = .bottomInside
        chart.xAxis.granularityEnabled = false
        chart.xAxis.labelTextColor = UIColor.clear
        
        chart.leftAxis.enabled = true
        chart.leftAxis.drawAxisLineEnabled = false
        chart.leftAxis.drawGridLinesEnabled = false
        chart.leftAxis.labelTextColor = UIColor.clear
        
        chart.rightAxis.enabled = true
        chart.rightAxis.drawAxisLineEnabled = false
        chart.rightAxis.drawGridLinesEnabled = false
        chart.rightAxis.labelTextColor = UIColor.clear
        
        chart.legend.horizontalAlignment = .right
        chart.legend.verticalAlignment = .bottom
        chart.legend.drawInside = false
        chart.legend.form = .empty
        chart.legend.orientation = .horizontal
        chart.legend.xEntrySpace = 1.0
        chart.legend.stackSpace = 0.1
        chart.extraBottomOffset = -30
        
        chart.drawBordersEnabled = false
        chart.drawValueAboveBarEnabled = true
        chart.drawGridBackgroundEnabled = false
        chart.drawValueAboveBarEnabled = true
        chart.drawBarShadowEnabled = false
        chart.barData?.highlightEnabled = false
        
        chart.pinchZoomEnabled = false
        chart.scaleXEnabled = false
        chart.scaleYEnabled = false
        chart.leftAxis.drawZeroLineEnabled = false
        chart.backgroundColor = UIColor.clear
        
        chart.chartDescription?.text = ""
    }
}


