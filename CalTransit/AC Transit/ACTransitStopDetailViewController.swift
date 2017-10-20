//
//  ACTransitStopDetailViewController.swift
//  CalTransit
//
//  Created by Will Oakley on 10/19/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON
import MKSpinner

class ACTransitStopDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var stopID: String?
    var stopName: String?
    var stopCoordinate: CLLocationCoordinate2D?
    var upcomingBuses: JSON!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        mapView.mapType = MKMapType.satelliteFlyover
        let displayTitle = stopName?.replacingOccurrences(of: ":", with: "/")
        navigationItem.title = displayTitle
        let a = MKPointAnnotation()
        a.coordinate = stopCoordinate!
        a.title = displayTitle
        mapView.addAnnotation(a)
        mapView.setRegion(MKCoordinateRegionMake(a.coordinate, MKCoordinateSpanMake(0.0001, 0.0001)), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getStopInfo()
    }
    
    func getStopInfo(){
        MKFullSpinner.show("Getting Stop Info...")
        let url = "https://api.actransit.org/transit/stops/\(self.stopID!)/predictions/?token=\(Constants.ACTransitAPIKey)"
        print(url)
        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                self.upcomingBuses = json
                self.tableView.reloadData()
                MKFullSpinner.hide()
                
            case .failure(let error):
                print(error)
                MKFullSpinner.hide()
                
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(upcomingBuses == nil){
            return 0
        }
        else{
            return upcomingBuses.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Upcoming Buses"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:BusTableViewCell = self.tableView.dequeueReusableCell(withIdentifier:"busCell", for: indexPath) as! BusTableViewCell
        //print(upcomingBuses)
        cell.routeLabel.text = "Route " + upcomingBuses[indexPath.row]["RouteName"].stringValue
        cell.arriveTimeLabel.text = "Arriving at: " + upcomingBuses[indexPath.row]["PredictedDeparture"].stringValue
        cell.delayLabel.text = "Delay of: " + upcomingBuses[indexPath.row]["PredictedDelayInSeconds"].stringValue
        cell.lastUpdatedLabel.text = "Last Updated: " + upcomingBuses[indexPath.row]["PredictionDateTime"].stringValue
        cell.vehicleId = upcomingBuses[indexPath.row]["VehicleId"].stringValue
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected something!")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }

}
