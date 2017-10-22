//
//  ACTransitBusInfoViewController.swift
//  CalTransit
//
//  Created by Will Oakley on 10/21/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import MKSpinner
import SwiftyJSON

class ACTransitBusInfoViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var busID: String?
   
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View loaded!")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View Appeared!")
        loadBusData(showSpinner: true)
    }
    
    @IBAction func refreshBusLocation(_ sender: Any) {
        loadBusData(showSpinner: false)
    }
    
    func loadBusData(showSpinner: Bool){
        if(showSpinner){
            MKFullSpinner.show("Loading bus info...")
        }
        let url = "https://api.actransit.org/transit/vehicle/\(busID!)/?token=\(Constants.ACTransitAPIKey)"
        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                self.placeBusOnMap(lat: json["Latitude"].doubleValue, long: json["Longitude"].doubleValue)
                
            case .failure(let error):
                print(error)
                MKFullSpinner.hide()
                
            }
        }
    }

    func placeBusOnMap(lat: Double, long: Double){
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "My Bus"
        mapView.addAnnotation(annotation)
        MKFullSpinner.hide()
        mapView.setRegion(MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.0001, 0.0001)), animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLoction: CLLocation = locations[0]
        let latitude = userLoction.coordinate.latitude
        let longitude = userLoction.coordinate.longitude
        let latDelta: CLLocationDegrees = 0.05
        let lonDelta: CLLocationDegrees = 0.05
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
    }

}
