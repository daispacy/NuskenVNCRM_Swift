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

class ChartStatisticsPie: CViewSwitchLanguage {

    var months: [String]!
    
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var chartView: PieChartView!
    
    @IBOutlet var lblTitleChart: UILabel!
    @IBOutlet var lblProcess: UILabel!
    @IBOutlet var lblUnprocess: UILabel!
    @IBOutlet var lblInvaid: UILabel!
    @IBOutlet var stackInvalid: UIStackView!
    
    
    // MARK: - INIT
    override func awakeFromNib() {
        super.awakeFromNib()

        configChart()                
    }
    
    override func reloadTexts() {
        // set text here
    }
    
    // MARK: - INTERFACE
    func setChart(_ dataPoints: [String], values: [Double]) {
        chartView.noDataText = "no_data_chart_order".localized()
        
        var dataEntries: [PieChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: nil)
            dataEntries.append(dataEntry)
        }
        
        var chartDataSet:PieChartDataSet = PieChartDataSet()
        
        if let dt = chartView.data {
            if(dt.dataSetCount > 0) {
                chartDataSet = chartView.data?.dataSets[0] as! PieChartDataSet
                chartDataSet.values = dataEntries
            }
        }
        
        if(chartDataSet.values.count == 0) {
            chartDataSet = PieChartDataSet(values: dataEntries, label:nil)
        }
        
        chartDataSet.sliceSpace = 1.0
        chartDataSet.selectionShift = 1
        chartView.holeRadiusPercent = 0
        
        let chartData = PieChartData(dataSet: chartDataSet)
        chartData.setValueTextColor(UIColor.white)
        chartData.setValueFont(UIFont(name: Theme.font.bold, size: Theme.fontSize.normal))
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale.current
        let valuesNumberFormatter = ChartValueFormatter(numberFormatter: numberFormatter)
        chartData.setValueFormatter(valuesNumberFormatter)
        
        chartDataSet.colors = [UIColor(hex:"0x008ab0"),UIColor(hex:"0xe30b7a")]
        
        chartView.data = chartData
        chartView.animate(yAxisDuration: 1.5)
    }
    
    func setTitleOption(one:String,two:String, three:String? = nil) {
        lblProcess.text = one
        lblUnprocess.text = two
        if let th = three {
            lblInvaid.text = th
        } else {
            stackInvalid.removeFromSuperview()
        }
    }
    
    // MARK: - PRIVATE
    private func configChart() {
        
        lblTitle.text = "title_chart_order".localized()
        
        lblTitleChart.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        lblTitleChart.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblProcess.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        lblProcess.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblInvaid.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        lblInvaid.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        lblUnprocess.font = UIFont(name: Theme.font.normal, size: Theme.fontSize.small)
        lblUnprocess.textColor = UIColor(hex:Theme.colorDBTextNormal)
        
        chartView.legend.horizontalAlignment = .left
        chartView.legend.verticalAlignment = .bottom
        chartView.legend.orientation = .vertical
        chartView.legend.drawInside = false
        chartView.legend.xEntrySpace = 0.0
        chartView.legend.yEntrySpace = 0.0
        chartView.legend.yOffset = 0.0
        chartView.legend.form = .empty
        
        backgroundColor = UIColor.white
        
        chartView.chartDescription?.text = ""
    }
}
