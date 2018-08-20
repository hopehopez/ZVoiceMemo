//
//  ZMeterTable.swift
//  VoiceMemo
//
//  Created by zsq on 2018/8/9.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

class ZMeterTable: NSObject {
    
    let MIN_DB: CGFloat = -60
    let TABLE_SIZE: Int = 300
    
    var scaleFactor: CGFloat = 0.0
    var meterTabel: [CGFloat] = []

    override init() {
        super.init()
        
        let dbResolution = MIN_DB / CGFloat(TABLE_SIZE - 1)
        scaleFactor = 1 / dbResolution
        
        let minAmp = dbToAmp(db: MIN_DB)
        let ampRange = 1.0 - minAmp
        let invAmpRange = 1.0 / ampRange
        
        for i in 0..<TABLE_SIZE {
            let decibels = CGFloat(i) * dbResolution
            let amp = dbToAmp(db: decibels)
            let adjAmp = (amp - minAmp) * invAmpRange
            meterTabel.append(adjAmp)
        }
        
    }
    
   private func dbToAmp(db: CGFloat) -> CGFloat {
        return CGFloat(powf(10.0, Float(0.05 * db)))
    }
    
    func value(for power: CGFloat) -> CGFloat {
        if power < MIN_DB {
            return 0.0
        } else if power > 0 {
            return 1.0
        } else {
            let index = Int(power * scaleFactor)
            return meterTabel[index]
        }
    }
}
