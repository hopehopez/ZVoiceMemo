//
//  ZLevelMeterView.swift
//  VoiceMemo
//
//  Created by zsq on 2018/8/9.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

class ZLevelMeterView: UIView {

    var level: CGFloat = 0
    var peakLevel: CGFloat = 0
    
    private var ledCount = 0
    private var ledBackgroundColor: UIColor!
    private var ledBorderColor: UIColor!
    private var colorThresholds: [ZLevelMeterColorThreshold]!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = UIColor.clear
        
        ledCount = 20
        ledBackgroundColor = UIColor.init(white: 0, alpha: 0.35)
        ledBorderColor = UIColor.black
        
        let green = UIColor(red: 0.458, green: 1, blue: 0.396, alpha: 1)
        let yellow = UIColor(red: 1, green: 0.930, blue: 0.315, alpha: 1)
        let red = UIColor(red: 1, green: 0.325, blue: 0.329, alpha: 1)
        
        colorThresholds = [ZLevelMeterColorThreshold(maxValue: 0.5, color: green, name: "green"),
        ZLevelMeterColorThreshold(maxValue: 0.8, color: yellow, name: "yellow"),
        ZLevelMeterColorThreshold(maxValue: 1.0, color: red, name: "red")]
        
        
    }
    
    func resetLevelMeter() {
        level = 0
        peakLevel = 0
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.bounds.height)
        context?.rotate(by: CGFloat(-Double.pi/2.0))
        let bounds = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        
        var lightMinValue: CGFloat = 0.0
        
        var peakLED = -1
        
        if self.peakLevel > 0.0 {
            peakLED = Int(peakLevel) * ledCount
            if peakLED > ledCount {
                peakLED = ledCount - 1
            }
        }
        
        for ledIndex in 0..<ledCount {
            var ledColor = colorThresholds[0].color
            let ledMaxValue = CGFloat(ledIndex + 1) / CGFloat(ledCount)
            
            for colorIndex in 0..<colorThresholds.count - 1 {
                let currentThreshold = colorThresholds[colorIndex]
                let nextThreshold = colorThresholds[colorIndex + 1]
                if currentThreshold.maxValue <= ledMaxValue {
                    ledColor = nextThreshold.color
                }
            }
            
            let height = bounds.width
            let width = bounds.height
            
            let ledRect = CGRect(x: 0, y: height * (CGFloat(ledIndex) / CGFloat(ledCount)), width: width, height: height * (1.0 / CGFloat(ledCount)))
//            print(ledRect)
            context?.setFillColor(ledBackgroundColor.cgColor)
            context?.fill(ledRect)
            
            var lightIntensity: CGFloat
            if ledIndex == peakLED {
                lightIntensity = 1.0
            } else {
                lightIntensity = clamp(intensity: (level - lightMinValue) / (ledMaxValue - lightMinValue))
                
            }
            
            var fillColor: UIColor
            if lightIntensity == 1.0 {
                fillColor = ledColor
            } else if lightIntensity >= 0{
                let color = ledColor.cgColor.copy(alpha: lightIntensity)
                fillColor = UIColor(cgColor: color!)
            } else {
                fillColor = UIColor.blue
            }
            
            context?.setFillColor(fillColor.cgColor)
            let fillPath = UIBezierPath(roundedRect: ledRect, cornerRadius: 2.0)
            context?.addPath(fillPath.cgPath)
            
            context?.setStrokeColor(ledBackgroundColor.cgColor)
            let strokePath = UIBezierPath(roundedRect: ledRect.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 2.0)
            context?.addPath(strokePath.cgPath)
            
            context?.drawPath(using: .fill)
            
            lightMinValue = ledMaxValue
        }
        
        
        
    }
    
    func clamp(intensity: CGFloat) -> CGFloat {
        if intensity < 0.0 {
            return 0.0
        } else if intensity > 1.0 {
            return 1.0
        } else {
            return intensity
        }
    }
}
