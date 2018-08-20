//
//  ZLevelPar.swift
//  VoiceMemo
//
//  Created by zsq on 2018/8/19.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

class ZLevelPair: NSObject {
    
    var level: CGFloat = 0.0
    var peakLevel: CGFloat = 0.0
    
    init(with level: CGFloat, peakLevel: CGFloat) {
        super.init()
        self.level = level
        self.peakLevel = peakLevel
    }
    

}
