//
//  BearTransitViewController.swift
//  CalTransit
//
//  Created by Will Oakley on 10/10/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MapKit
import MKSpinner

class BearTransitViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var firstEntry = false
    var selectedStop: BearTransitStopAnnotation?

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
        let mapRegion = MKCoordinateRegionMake((locationManager.location?.coordinate)!, MKCoordinateSpanMake(0.03, 0.03))
        mapView.setRegion(mapRegion, animated: true)
        
        if(firstEntry){
            print("Loc:")
            print((locationManager.location?.coordinate)!)
            getActiveStops(locationCoordinate: (locationManager.location?.coordinate)!)
        }
    }
    
    func getActiveStops(locationCoordinate: CLLocationCoordinate2D){
        let url = "http://beartransit.daylen.com/api/v1/stops"
        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                for i in 0 ..< json.count {
                    let coordinate = CLLocationCoordinate2DMake(json[i]["lat"].doubleValue, json[i]["lon"].doubleValue)
                    print(coordinate)
                    self.addStopAnnotation(coord: coordinate, name: json[i]["name"].stringValue, id: json[i]["StopId"].stringValue )
                }
            case .failure(let error):
                print(error)
                print("Maybe BearTransit is offline?")
                
            }
        }
    }
    
    func addStopAnnotation(coord: CLLocationCoordinate2D, name: String, id: String){
        print("Making annotation for " + name)
        let c = BearTransitStopAnnotation()
        c.title = name
        c.coordinate = coord
        c.stopID = id
        self.mapView.addAnnotation(c)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is BearTransitStopAnnotation {
            let a = annotation as! BearTransitStopAnnotation
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Stop") {
                annotationView.annotation = annotation
                return annotationView
            } else {
                let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier: a.stopID)
                annotationView.isEnabled = true
                annotationView.canShowCallout = true
                
                let btn = UIButton(type: .detailDisclosure)
                annotationView.rightCalloutAccessoryView = btn
                return annotationView
            }
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if(view.annotation!.isKind(of: MKUserLocation.self))
        {
            return
        }
        else{
            selectedStop = (view.annotation as! BearTransitStopAnnotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Hey!")
    }

}
