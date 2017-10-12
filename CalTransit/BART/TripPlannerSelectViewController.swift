//
//  TripPlannerSelectViewController.swift
//  CalTransit
//
//  Created by Will Oakley on 10/10/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import UIKit
import Alamofire
import MKSpinner
import SwiftyJSON

class TripPlannerSelectViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var stationNames = [String]()
    var stationCodes = [String]()
    
    var selectedDepartureCode: String!
    var selectedArrivalCode: String!
    
    @IBOutlet weak var departPicker: UIPickerView!
    @IBOutlet weak var arrivePicker: UIPickerView!
    @IBOutlet weak var typeSelector: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        departPicker.delegate = self
        departPicker.dataSource = self
        arrivePicker.delegate = self
        arrivePicker.dataSource = self
        datePicker.minimumDate = Date()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updatePickerViews()
    }

    func updatePickerViews(){
        MKFullSpinner.show("Loading Stations...")
        stationNames.removeAll()
        stationCodes.removeAll()
        
        Alamofire.request("http://api.bart.gov/api/stn.aspx?cmd=stns&key=\(Constants.BARTAPIKey)&json=y").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                Constants.stationInfo.removeAll()
                for (key ,subJson) in json["root"]["stations"]["station"] {
                    self.stationNames.append(subJson["name"].stringValue)
                    self.stationCodes.append(subJson["abbr"].stringValue)
                    Constants.stationInfo.updateValue(subJson["name"].stringValue, forKey: subJson["abbr"].stringValue)
                }
                self.departPicker.reloadAllComponents()
                self.arrivePicker.reloadAllComponents()
                self.pickerView(self.departPicker, didSelectRow: 0, inComponent: 0)
                self.pickerView(self.arrivePicker, didSelectRow: 0, inComponent: 0)
                MKFullSpinner.hide()
                
            case .failure(let error):
                print(error)
                MKFullSpinner.hide()
                
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
        if(pickerView == departPicker){
            selectedDepartureCode = stationCodes[row]
        }
        else if(pickerView == arrivePicker){
            selectedArrivalCode = stationCodes[row]
        }
    }
    //---------------------------------
    
    
    @IBAction func searchForTrip(_ sender: Any) {
        
        self.performSegue(withIdentifier: "showTripDetails", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationViewController = segue.destination as? TripPlannerResultViewController {
            destinationViewController.departureCode = selectedDepartureCode
            destinationViewController.arrivalCode = selectedArrivalCode
            destinationViewController.searchType = typeSelector.selectedSegmentIndex
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm+a"
            
            
            destinationViewController.date = dateFormatter.string(from: datePicker.date)
            destinationViewController.time = timeFormatter.string(from: datePicker.date)
        }
    }
}
