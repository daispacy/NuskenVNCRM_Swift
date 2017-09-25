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

class ChartStatisticsCustomer: UIView {

    var months: [String]!
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var chartView: BarChartView!
    @IBOutlet var chartViewHeight: NSLayoutConstraint!
    
    @IBOutlet var btnMenu1: CButtonChart!
    @IBOutlet var btnMenu2: CButtonChart!
    @IBOutlet var btnMenu3: CButtonChart!
    @IBOutlet var btnMenu4: CButtonChart!
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()

        configChart()
        
       menuPress(btnMenu4)
    }
    
    // MARK: - INTERFACE
    func setChart(_ dataPoints: [String], values: [Double]) {
        chartView.noDataText = "no_data_chart_summary_sales".localized()
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        chartView.xAxis.labelCount = dataPoints.count;
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x:Double(i), y:values[i])
            dataEntries.append(dataEntry)
        }
        
        var chartDataSet:BarChartDataSet = BarChartDataSet()
        
        if let dt = chartView.data {
            if(dt.dataSetCount > 0) {
                chartDataSet = chartView.data?.dataSets[0] as! BarChartDataSet
                chartDataSet.values = dataEntries
            }
        }
        
        if(chartDataSet.values.count == 0) {
            chartDataSet = BarChartDataSet(values: dataEntries, label:nil)
            chartDataSet.highlightAlpha = 0
            chartDataSet.axisDependency = .left
            chartDataSet.stackLabels = []
        }
        
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.7
        chartData.setValueTextColor(UIColor(hex:Theme.colorDBTextNormal))
        
        chartDataSet.colors = [UIColor(hex:Theme.colorDBChartProcess)]
        
        chartView.data = chartData
        chartView.animate(yAxisDuration: 1.5)
    }
    
    // MARK: - EVENT
    @IBAction func menuPress(_ sender: UIButton) {
        btnMenu1.isSelected = false
        btnMenu2.isSelected = false
        btnMenu3.isSelected = false
        btnMenu4.isSelected = false
        
        sender.isSelected = !sender.isSelected
        
        var unitsSold = [20.0, 4.0, 6.0]
        
        switch sender {
        case btnMenu1:
            months = ["Jan", "Feb", "Mar"]
            unitsSold = [22.0, 41.0, 6.0]
            break
        case btnMenu2:
            months = ["Apr", "May", "Jun"]
            unitsSold = [26.0, 4.0, 65.0]
            break
        case btnMenu3:
            months = ["Jul", "Aug", "Sep"]
            unitsSold = [22.0, 55.0, 34.0]
            break
        case btnMenu4:
            months = ["Oct", "Nov", "Dec"]
            unitsSold = [80.0, 45.0, 13.0]
            break
        default:
            months = ["Oct", "Nov", "Dec"]
            break
        }
        
        setChart(months, values: unitsSold)
    }
    
    // MARK: - PRIVATE
    private func configChart() {
    
        lblTitle.textColor = UIColor(hex:Theme.colorDBTitleChart)
        lblTitle.text = "title_chart_customer".localized()
        btnMenu1.setTitle("1st_quarter", for: .normal)
        btnMenu2.setTitle("2st_quarter", for: .normal)
        btnMenu3.setTitle("3st_quarter", for: .normal)
        btnMenu4.setTitle("4st_quarter", for: .normal)
        
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.granularityEnabled = false
        chartView.xAxis.labelTextColor = UIColor(hex:Theme.colorDBTextNormal)
        
//        chartView.leftAxis.enabled = true
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = true
        chartView.leftAxis.labelTextColor = UIColor.clear
        
        chartView.rightAxis.enabled = false

        
        chartView.legend.horizontalAlignment = .center
        chartView.legend.verticalAlignment = .bottom
        chartView.legend.drawInside = false
        chartView.legend.form = .none
        chartView.legend.orientation = .horizontal
        chartView.legend.xEntrySpace = 0.0
        
        chartView.drawBordersEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.drawGridBackgroundEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.drawBarShadowEnabled = false
        
        chartView.backgroundColor = UIColor.white
        chartView.pinchZoomEnabled = false
        chartView.fitBars = true
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        
        chartView.chartDescription?.text = ""
        
        chartViewHeight.constant = chartView.bounds.size.height*60/100
    }
}
