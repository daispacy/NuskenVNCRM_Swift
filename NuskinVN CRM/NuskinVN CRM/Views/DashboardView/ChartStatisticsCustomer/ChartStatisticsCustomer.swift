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

class ChartStatisticsCustomer: PieChartView {

    var months: [String]!
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()

        configChart()
        
        
        let unitsSold = [20.0, 4.0, 6.0]
        
        setChart(["Jan", "Feb", "Mar"], values: unitsSold)
    }
    
    // MARK: - INTERFACE
    func setChart(_ dataPoints: [String], values: [Double]) {
        noDataText = "no_data_chart_summary_sales".localized()
     
        var dataEntries: [PieChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: nil)
            dataEntries.append(dataEntry)
        }
        
        var chartDataSet:PieChartDataSet = PieChartDataSet()
        
        if let dt = data {
            if(dt.dataSetCount > 0) {
                chartDataSet = data?.dataSets[0] as! PieChartDataSet
                chartDataSet.values = dataEntries
            }
        }
        
        if(chartDataSet.values.count == 0) {
            chartDataSet = PieChartDataSet(values: dataEntries, label:nil)
        }
        
        chartDataSet.sliceSpace = 1.0
        chartDataSet.selectionShift = 10.0
        holeRadiusPercent = 0.8
        
        let chartData = PieChartData(dataSet: chartDataSet)
        chartData.setValueTextColor(UIColor.clear)        
        
        chartDataSet.colors = [UIColor(hex:"0xffab00"),UIColor(hex:"0x38a4dd"),UIColor(hex:"0xff1744")]
        
        data = chartData
        animate(yAxisDuration: 1.5)
    }
    
    // MARK: - PRIVATE
    private func configChart() {
    
        legend.horizontalAlignment = .left
        legend.verticalAlignment = .bottom
        legend.orientation = .vertical
        legend.drawInside = false
        legend.xEntrySpace = 0.0
        legend.yEntrySpace = 0.0
        legend.yOffset = 0.0
        legend.form = .empty
        
        backgroundColor = UIColor.white
        
        chartDescription?.text = ""
    }
}
