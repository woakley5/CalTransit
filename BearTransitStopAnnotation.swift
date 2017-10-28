//
//  BearTransitStopAnnotation.swift
//  CalTransit
//
//  Created by Will Oakley on 10/28/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import UIKit
import MapKit

class BearTransitStopAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var stopID: String?
    var title: String?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.stopID = nil
    }
    
}

