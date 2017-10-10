//
//  OtherStationsViewController.swift
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

class OtherStationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var stationNames = [String]()
    var stationCodes = [String]()
    var stationLocations = [CLLocationCoordinate2D]()
    var upcomingTrains: JSON!

    @IBOutlet weak var stationPicker: UIPickerView!
    @IBOutlet weak var stationMap: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Other Stations"
        stationPicker.delegate = self
        stationPicker.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        updatePickerView()
        let region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.720338, -121.8747757), MKCoordinateSpanMake(0.62, 0.4))
        self.stationMap.setRegion(region, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func updatePickerView(){
        stationNames.removeAll()
        stationCodes.removeAll()
        stationLocations.removeAll()
        
        Alamofire.request("http://api.bart.gov/api/stn.aspx?cmd=stns&key=\(Constants.BARTAPIKey)&json=y").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for (key ,subJson) in json["root"]["stations"]["station"] {
                    self.stationNames.append(subJson["name"].stringValue)
                    self.stationCodes.append(subJson["abbr"].stringValue)
                    self.stationLocations.append(CLLocationCoordinate2DMake(CLLocationDegrees(subJson["gtfs_latitude"].floatValue), CLLocationDegrees(subJson["gtfs_longitude"].floatValue)))
                }
                self.stationPicker.reloadAllComponents()
                self.pickerView(self.stationPicker, didSelectRow: 0, inComponent: 0)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //Picker View delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stationNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return stationNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.stationMap.removeAnnotations(self.stationMap.annotations)
        let a = MKPointAnnotation()
        a.coordinate = stationLocations[row]
        self.stationMap.addAnnotation(a)
        print(a.coordinate)
        self.stationMap.setRegion(MKCoordinateRegionMake(a.coordinate, MKCoordinateSpanMake(0.05, 0.05)), animated: true)
        getStationInfo(stationCode: stationCodes[row])
        MKFullSpinner.show("Loading Trains...")
    }
    //---------------------------------
    
    func getStationInfo(stationCode: String){
        Alamofire.request("http://api.bart.gov/api/etd.aspx?cmd=etd&orig=\(stationCode)&key=\(Constants.BARTAPIKey)&json=y").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.upcomingTrains = json["root"]["station"][0]["etd"]
                self.tableView.reloadData()
                MKFullSpinner.hide()
                
            case .failure(let error):
                print(error)
                MKFullSpinner.hide()
                
            }
        }
    }
    
    //Table View delegate methods
    //Sets number of sections (Main section, upcoming trains and further options section)
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Sets the number of rows in each section defined above
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(upcomingTrains == nil){
            return 0 //None in second if upcomingTrains JSON fails to update
        }
        else {
            return upcomingTrains.count //Updates to number of upcoming trains when JSON updates
        }
    }
    
    //Defines all cells of the tableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TrainTableViewCell = self.tableView.dequeueReusableCell(withIdentifier:"trainCell", for: indexPath) as! TrainTableViewCell
        cell.directionLabel.text = upcomingTrains[indexPath.row]["destination"].stringValue + " bound train"
        
        let arrivalMessage = upcomingTrains[indexPath.row]["estimate"][0]["length"].stringValue + " car train arriving in " + upcomingTrains[indexPath.row]["estimate"][0]["minutes"].stringValue + " minutes"
        cell.arrivingInLabel.text = arrivalMessage
        
        cell.platformLabel.text = "Use Platform " + upcomingTrains[indexPath.row]["estimate"][0]["platform"].stringValue
        
        if(upcomingTrains[indexPath.row]["estimate"][0]["bikeflag"].intValue == 1){
            cell.bikesLabel.text = "Bikes are allowed"
        }
        else{
            cell.bikesLabel.text = "Bikes are not allowed"
        }
        
        cell.coloredBackgroundView.backgroundColor = Constants.hexStringToUIColor(hex: upcomingTrains[indexPath.row]["estimate"][0]["hexcolor"].stringValue)
        return cell
    
    }
    
    //Returns heights of each cell - Static for section 1 cells and universal for section 2
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Upcoming Trains"
    }

}
