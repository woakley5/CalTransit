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

class ACTransitViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var firstEntry = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
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
        //print("Updated!")
        let mapRegion = MKCoordinateRegionMake((locationManager.location?.coordinate)!, MKCoordinateSpanMake(0.05, 0.05))
        mapView.setRegion(mapRegion, animated: true)
        
        if(firstEntry){
            print("Loc:")
            print((locationManager.location?.coordinate)!)
            getNearestStops(locationCoordinate: (locationManager.location?.coordinate)!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error!")
    }
    
    func getNearestStops(locationCoordinate: CLLocationCoordinate2D) {
        firstEntry = false
        MKFullSpinner.show("Refreshing stops...")
        let searchRadius = 2000
        let url = "https://api.actransit.org/transit/stops/\(locationCoordinate.latitude)/\(locationCoordinate.longitude)/\(searchRadius)/?token=FF2AA022BCE64E2605DDA817CB624012"
        print(url)
        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                for i in 0 ..< json.count {
                    let coordinate = CLLocationCoordinate2DMake(json[i]["Latitude"].doubleValue, json[i]["Longitude"].doubleValue)
                    self.addStopAnnotation(coord: coordinate, name: json[i]["Name"].stringValue)
                }
                MKFullSpinner.hide()
            case .failure(let error):
                print(error)
                print("Maybe you arent in the AC Transit service area?")
                MKFullSpinner.hide()
                
            }
        }
       
    }
    
    @IBAction func refreshStops(_ sender: Any) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        getNearestStops(locationCoordinate: (self.locationManager.location?.coordinate)!)
    }
    
    func addStopAnnotation(coord: CLLocationCoordinate2D, name: String){
        let c = MKPointAnnotation()
        c.title = name
        c.coordinate = coord
        self.mapView.addAnnotation(c)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Selected an annotation!")
    }

}

