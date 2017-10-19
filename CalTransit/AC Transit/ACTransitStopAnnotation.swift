//
//  ACTransitStopAnnotation.swift
//  CalTransit
//
//  Created by Will Oakley on 10/18/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import UIKit
import MapKit

class ACTransitStopAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var id: Int
    
    init(stopId: Int, stopTitle: String, coord: CLLocationCoordinate2D) {
        self.id = stopId
        self.title = stopTitle
        self.coordinate = coord
        super.init()
    }
    
}
