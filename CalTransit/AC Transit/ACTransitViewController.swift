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

class ACTransitViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var firstEntry = false
    
    var selectedStop: ACTransitStopAnnotation?
    var stopIDs = [String]()
    
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
        let url = "https://api.actransit.org/transit/stops/\(locationCoordinate.latitude)/\(locationCoordinate.longitude)/\(searchRadius)/?token=\(Constants.ACTransitAPIKey)"
        self.stopIDs.removeAll()
        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                for i in 0 ..< json.count {
                    let coordinate = CLLocationCoordinate2DMake(json[i]["Latitude"].doubleValue, json[i]["Longitude"].doubleValue)
                    self.addStopAnnotation(coord: coordinate, name: json[i]["Name"].stringValue, id: json[i]["StopId"].stringValue)
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
    
    func addStopAnnotation(coord: CLLocationCoordinate2D, name: String, id: String){
        if(!self.stopIDs.contains(id)){
            self.stopIDs.append(id)
            let c = ACTransitStopAnnotation()
            c.title = name.replacingOccurrences(of: ":", with: "/")
            c.coordinate = coord
            c.stopID = id
            self.mapView.addAnnotation(c)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is ACTransitStopAnnotation {
            let a = annotation as! ACTransitStopAnnotation
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
            selectedStop = (view.annotation as! ACTransitStopAnnotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegue(withIdentifier: "showStopDetails", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationViewController = segue.destination as? ACTransitStopDetailViewController {
            destinationViewController.stopID = selectedStop?.stopID
            destinationViewController.stopName = selectedStop?.title
            destinationViewController.stopCoordinate = selectedStop?.coordinate
        }
    }
}

