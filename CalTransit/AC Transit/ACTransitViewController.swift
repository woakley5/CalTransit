//
//  ACTransitViewController.swift
//  CalTransit
//
//  Created by Will Oakley on 10/9/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import MKSpinner
import SwiftBus

class ACTransitViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var firstEntry = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        else{
            print("No locations access!")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        firstEntry = true
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updated!")
        let mapRegion = MKCoordinateRegionMake((locationManager.location?.coordinate)!, MKCoordinateSpanMake(0.05, 0.05))
        mapView.setRegion(mapRegion, animated: true)
        
        if(firstEntry){
            getNearestStops(locationCoordinate: (locationManager.location?.coordinate)!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error!")
    }
    
    func getNearestStops(locationCoordinate: CLLocationCoordinate2D) {
        firstEntry = false
        MKFullSpinner.show("Refreshing stops")
        /*Alamofire.request("http://api.actransit.org/transit/stops/\(locationCoordinate.latitude)/\(locationCoordinate.longitude)/?token=\(Constants.ACTransitAPIKey)").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                MKFullSpinner.hide()
            case .failure(let error):
                print(error)
                MKFullSpinner.hide()
                
            }
        }*/
       
    }

}

