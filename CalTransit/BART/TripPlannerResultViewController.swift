//
//  TripPlannerResultViewController.swift
//  CalTransit
//
//  Created by Will Oakley on 10/10/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MKSpinner

class TripPlannerResultViewController: UITableViewController {
    
    var departureCode: String?
    var arrivalCode: String? //0 - departing at | 1 - arriving by
    var searchType: Int?
    var date: String?
    var time: String?
    
    var legs: JSON!
    var tripInfo: JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = Constants.stationInfo[departureCode!]! + " - " + Constants.stationInfo[arrivalCode!]!
        searchForTrip()
    }
    
    func searchForTrip(){
        MKFullSpinner.show("Searching for trips...")
        let typeCodes = ["depart", "arrive"]
        
        Alamofire.request("http://api.bart.gov/api/sched.aspx?cmd=\(typeCodes[searchType!])&orig=\(departureCode!)&dest=\(arrivalCode!)&date=\(date!)&time=\(time!)&key=\(Constants.BARTAPIKey)&json=y").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.tripInfo = json
                self.legs = json["root"]["schedule"]["request"]["trip"][0]["leg"]
                //print(json)
                self.tableView.reloadData()
                MKFullSpinner.hide()
                
            case .failure(let error):
                print(error)
                MKFullSpinner.hide()
                // TODO: Implement error handling
            }
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tripInfo != nil){
            if self.legs.count > 1 {
                return self.legs.count + 2
            }
            else {
                return 2
            }
        }
        else{
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tripInfo != nil {
            if self.legs.count == 1 {
                if indexPath.row == 0 {
                    return generateLegCell(legNum: 0, path: indexPath)
                }
                else {
                    return generateSumamryCell(path: indexPath)
                }
            }
            else{
                switch indexPath.row {
                case 0:
                    return generateLegCell(legNum: 0, path: indexPath)
                case 1:
                    return generateTransferCell(prevLegNum: 0, path: indexPath)
                case 2:
                    return generateLegCell(legNum: 1, path: indexPath)
                default:
                    return generateSumamryCell(path: indexPath)
                }
            }
        }
        else {
            return self.tableView.dequeueReusableCell(withIdentifier:"loadingCell", for: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 139
        }
        else if(self.legs.count == 1){
            if(indexPath.row == 1){
                return 44
            }
            else{
                return 149
            }
        }
        else{
            if(indexPath.row == 1){
                return 44
            }
            else if(indexPath.row == 2){
                return 139
            }
            else{
                return 149
            }
            
        }
    }
    
    func generateLegCell(legNum: Int, path: IndexPath) -> UITableViewCell {
        print("Leg Num " + String(legNum))
        let cell:TripSegmentTableViewCell = self.tableView.dequeueReusableCell(withIdentifier:"tripLegCell", for: path) as! TripSegmentTableViewCell
        cell.originLabel.text = Constants.stationInfo[legs[legNum]["@origin"].stringValue]
        cell.destinationLabel.text = Constants.stationInfo[legs[legNum]["@destination"].stringValue]
        cell.departTimeLabel.text = legs[legNum]["@origTimeMin"].stringValue
        cell.arriveTimeLabel.text = legs[legNum]["@destTimeMin"].stringValue
        return cell
    }
    
    func generateSumamryCell(path: IndexPath) -> UITableViewCell{
        let cell:TripSummaryTableViewCell = self.tableView.dequeueReusableCell(withIdentifier:"summaryCell", for: path) as! TripSummaryTableViewCell
        cell.tripTimeLabel.text = "Total Trip Time: " + self.tripInfo["root"]["schedule"]["request"]["trip"][0]["@tripTime"].stringValue
        cell.cashFareLabel.text = "Normal Fare: $" + self.tripInfo["root"]["schedule"]["request"]["trip"][0]["@fare"].stringValue
        cell.clipperFareLabel.text = "Clipper Fare: $" + self.tripInfo["root"]["schedule"]["request"]["trip"][0]["@clipper"].stringValue
        cell.co2EmissionsLabel.text = "You saved " + self.tripInfo["root"]["schedule"]["request"]["trip"][0]["@co2"].stringValue + " lbs of C02 emissions this trip."
        return cell
    }
    
    func generateTransferCell(prevLegNum: Int, path: IndexPath) -> UITableViewCell {
        let cell:TransferTableViewCell = self.tableView.dequeueReusableCell(withIdentifier:"transferInfoCell", for: path) as! TransferTableViewCell
        cell.transferInfoLabel.text = "Transfer at " + self.legs[prevLegNum]["@destination"].stringValue
        return cell
    }
}
