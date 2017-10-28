//
//  Constants.swift
//  CalTransit
//
//  Created by Will Oakley on 10/10/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import Foundation
import UIKit

class Constants{
    
    //BART Stuff
    static let BARTAPIKey = "ZMZB-5V9S-9W2T-DWE9"
    static var BARTstationInfo = [String: String]()
    
    //AC Transit Stuff
    static let ACTransitAPIKey = "FF2AA022BCE64E2605DDA817CB624012"
    static var ACTransitStopInfo = [String: String]()
    
    //BearTransit Stuff
    
    
    //Converts bart hex color to UIColor
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}
