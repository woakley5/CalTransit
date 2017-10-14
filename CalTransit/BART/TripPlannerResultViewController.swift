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
    var transferStation: String!
    
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
                var leg = 0
                for i in 0 ..< self.tableView.numberOfRows(inSection: 0) {
                    if( i == 0 || i == 2) {
                        self.updateCellColor(route: self.legs[leg]["@line"].stringValue, cell: self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! TripSegmentTableViewCell)
                        leg += 1
                    }
                }
                
                
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
        if(indexPath.row == 0){ //First cell is always a train cell - set height
            return 139
        }
        else if(self.legs.count == 1){
            return 149 //Summary cell for 1 segment trip
        }
        else{ // Multiple leg cells
            if(indexPath.row == 1){
                return 44 //Transfer height
            }
            else if(indexPath.row == 2){
                return 139 //2nd Leg cell
            }
            else{
                return 149 //Summary cell
            }
            
        }
    }
    
    func generateLegCell(legNum: Int, path: IndexPath) -> UITableViewCell {
        print("Leg Num " + String(legNum))
        let cell:TripSegmentTableViewCell = self.tableView.dequeueReusableCell(withIdentifier:"tripLegCell", for: path) as! TripSegmentTableViewCell
        cell.routeLabel.text = Constants.stationInfo[legs[legNum]["@origin"].stringValue]! + " -> " + Constants.stationInfo[legs[legNum]["@destination"].stringValue]!
        if(path.row == 0){
            self.transferStation = Constants.stationInfo[legs[legNum]["@destination"].stringValue]!
        }
        cell.departTimeLabel.text = legs[legNum]["@origTimeMin"].stringValue
        cell.arriveTimeLabel.text = legs[legNum]["@destTimeMin"].stringValue
        return cell
    }
    
    func updateCellColor(route: String, cell: TripSegmentTableViewCell) {
        MKFullSpinner.show("Getting Train Info...")
        let r = route.replacingOccurrences(of: "ROUTE ", with: "", options: .literal, range: nil)
        print(r)
        Alamofire.request("http://api.bart.gov/api/route.aspx?cmd=routeinfo&route=\(r)&key=\(Constants.BARTAPIKey)&json=y").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let color = Constants.hexStringToUIColor(hex: json["root"]["routes"]["route"]["hexcolor"].stringValue)
                print(json["root"]["routes"]["route"]["color"].stringValue)
                cell.background.backgroundColor = color
                print(json)
                self.tableView.reloadData()
                MKFullSpinner.hide()
                
            case .failure(let error):
                print(error)
                MKFullSpinner.hide()
                // TODO: Implement error handling
            }
        }
    }
    
    func generateSumamryCell(path: IndexPath) -> UITableViewCell{
        let cell:TripSummaryTableViewCell = self.tableView.dequeueReusableCell(withIdentifier:"summaryCell", for: path) as! TripSummaryTableViewCell
        cell.tripTimeLabel.text = "Total Trip Time: " + self.tripInfo["root"]["schedule"]["request"]["trip"][0]["@tripTime"].stringValue + " minutes"
        cell.cashFareLabel.text = "Normal Fare: $" + self.tripInfo["root"]["schedule"]["request"]["trip"][0]["@fare"].stringValue
        cell.clipperFareLabel.text = "Clipper Fare: $" + self.tripInfo["root"]["schedule"]["request"]["trip"][0]["@clipper"].stringValue
        cell.co2EmissionsLabel.text = "You will save " + self.tripInfo["root"]["schedule"]["request"]["trip"][0]["@co2"].stringValue + " lbs of C02 emissions with this trip."
        return cell
    }
    
    func generateTransferCell(prevLegNum: Int, path: IndexPath) -> UITableViewCell {
        let cell:TransferTableViewCell = self.tableView.dequeueReusableCell(withIdentifier:"transferInfoCell", for: path) as! TransferTableViewCell
        cell.transferInfoLabel.text = "Transfer at " + self.transferStation
        return cell
    }
}
