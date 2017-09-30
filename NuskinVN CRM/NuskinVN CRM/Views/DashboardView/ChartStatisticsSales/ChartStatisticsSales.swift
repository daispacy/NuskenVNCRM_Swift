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

class ChartStatisticsSales: UIView {

    var months: [String]!
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var chartView: HorizontalBarChartView!
    @IBOutlet var chartViewHeight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
//        heigthConstraint = NSLayoutConstraint.init(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.size.height/1.5)
//        addConstraint(heigthConstraint!)
        
        configChart()
        
        months = ["Jan", "Feb"]
        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        setChart(months, values: unitsSold)
    }
    
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
            chartDataSet.stackLabels = []
        }
        
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.1
        
        chartDataSet.colors = [UIColor(hex:"0x008ab0"),UIColor(hex:"0xe30b7a")]
        
        chartView.data = chartData
    }
    
    private func configChart() {
        
        lblTitle.textColor = UIColor(hex:Theme.colorDBTitleChart)
        lblTitle.text = "title_chart_sales".localized()
        
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.granularityEnabled = false        
        chartView.xAxis.labelTextColor = UIColor(hex:Theme.colorDBTextNormal)
        
        chartView.leftAxis.enabled = false
        
        chartView.rightAxis.enabled = true
        chartView.rightAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.rightAxis.labelTextColor = UIColor(hex:Theme.colorDBButtonChartTextNormal)
        chartView.rightAxis.axisMinimum = 0.0
        
        chartView.legend.horizontalAlignment = .left
        chartView.legend.verticalAlignment = .bottom
        chartView.legend.drawInside = false
        chartView.legend.form = .none
        chartView.legend.orientation = .horizontal
        chartView.legend.xEntrySpace = 4.0
        
        chartView.drawBordersEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.drawValueAboveBarEnabled = false
        chartView.drawBarShadowEnabled = true
        
        chartView.backgroundColor = UIColor.white
        chartView.pinchZoomEnabled = false
        chartView.fitBars = true
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        
        chartView.chartDescription?.text = ""
        
        chartView.animate(yAxisDuration: 2.5)
        
        chartViewHeight.constant = chartView.bounds.size.height*70/100
    }
}
