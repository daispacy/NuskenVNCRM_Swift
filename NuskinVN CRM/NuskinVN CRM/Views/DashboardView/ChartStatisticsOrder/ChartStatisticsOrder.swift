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

class ChartStatisticsOrder: UIView {

    var months: [String]!
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var chartView: BarChartView!
    
    @IBOutlet var lblTitleChart: UILabel!
    @IBOutlet var lblProcess: UILabel!
    @IBOutlet var lblUnprocess: UILabel!
    
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()

        configChart()
        
        let unitsSold = [26.0, 15.0]
        
        setChart(["".localized(),"".localized()], values: unitsSold)
    }
    
    // MARK: - INTERFACE
    func setChart(_ dataPoints: [String], values: [Double]) {
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        chartView.xAxis.labelCount = dataPoints.count;
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<values.count {
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
        }
        
        chartDataSet.drawIconsEnabled = false
        
        chartDataSet.colors = [UIColor(hex:"0x008ab0"),UIColor(hex:"0xe30b7a")]
        chartDataSet.stackLabels = [];
        chartDataSet.highlightAlpha = 0
        
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.4
        chartData.setValueTextColor(UIColor(hex:Theme.colorDBTextNormal))
        chartData.setValueFont(UIFont(name: Theme.font.normal, size: Theme.fontSize.normal))
        
        chartView.data = chartData
        chartView.animate(yAxisDuration: 1.5)
    }
    
    // MARK: - PRIVATE
    private func configChart() {
        
        lblTitle.text = "title_chart_order".localized()
        lblProcess.text = "process".localized()
        lblUnprocess.text = "unprocess".localized()
        
        lblTitleChart.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        lblTitleChart.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblProcess.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        lblProcess.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblUnprocess.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        lblUnprocess.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        // setup chart
        chartView.noDataText = "no_data_chart_summary_sales".localized()
        
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
        chartView.legend.form = .empty
        chartView.legend.orientation = .horizontal
        chartView.legend.xEntrySpace = 1.0
        chartView.legend.stackSpace = 0.1
        
        chartView.drawBordersEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.drawGridBackgroundEnabled = false
        chartView.drawValueAboveBarEnabled = true
        chartView.drawBarShadowEnabled = false
        
        chartView.backgroundColor = UIColor.white
        chartView.pinchZoomEnabled = false
        chartView.fitBars = false
        chartView.scaleXEnabled = false
        chartView.scaleYEnabled = false
        
        chartView.chartDescription?.text = ""
    }
}
