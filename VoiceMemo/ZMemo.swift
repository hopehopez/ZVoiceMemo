//
//  ZMemo.swift
//  VoiceMemo
//
//  Created by zsq on 2018/8/9.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

class ZMemo: NSObject, NSCoding {
    
    
    
    var title: String!
    var url: URL!
    var dateString: String!
    var timeString: String!
    
    override init() {
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(dateString, forKey: "dateString")
        aCoder.encode(timeString, forKey: "timeString")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        title = aDecoder.decodeObject(forKey: "title") as! String
        url = aDecoder.decodeObject(forKey: "url") as! URL
        dateString = aDecoder.decodeObject(forKey: "dateString") as! String
        timeString = aDecoder.decodeObject(forKey: "timeString") as! String
    }
    
    func initWithTitle(_ title: String, url: URL) {
//        super.init()
        
        self.title = title
        self.url = url;
        let date = Date()
        self.dateString = dateString(with: date)
        self.timeString = timeString(with: date)
        
    }
    
    
    
    func formatter(with format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
    
    func dateString(with date: Date) -> String {
        let df = formatter(with: "yyyyMMdd")
        return df.string(from: date)
    }
    
    func timeString(with date: Date) -> String {
        let df = formatter(with: "HHmmss")
        return df.string(from: date)
    }
    
    static func memo(with title: String, url: URL) -> ZMemo{
        let memo = ZMemo()
        memo.initWithTitle(title, url: url)
        return memo
    }
    
    func deleteMemo() -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            print("unable to delete: \(error.localizedDescription)")
            return false
        }
        
    }

}
