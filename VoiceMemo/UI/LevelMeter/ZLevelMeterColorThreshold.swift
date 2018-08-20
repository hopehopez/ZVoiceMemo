//
//  ZLevelMeterColorThreshold.swift
//  VoiceMemo
//
//  Created by zsq on 2018/8/15.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

class ZLevelMeterColorThreshold: NSObject {

    var maxValue: CGFloat = 0
    var color: UIColor = UIColor.clear
    var name: String = ""
    
    static func colorThreshold(maxValue: CGFloat, color: UIColor, name: String) -> ZLevelMeterColorThreshold{
        return ZLevelMeterColorThreshold(maxValue: maxValue, color: color, name: name)
    }
    
    init(maxValue: CGFloat, color: UIColor, name: String) {
        super.init()
        self.maxValue = maxValue
        self.color = color
        self.name = name
    }
    
    override var description: String {
        return name
    }
}
