//
//  BARTViewController.swift
//  CalTransit
//
//  Created by Will Oakley on 10/9/17.
//  Copyright © 2017 Will Oakley. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MKSpinner

class BARTViewController: UITableViewController {

    var upcomingTrains: JSON!
    private let refresh = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(BARTViewController.refreshUpcomingTrains), for: .valueChanged)
        refresh.backgroundColor = UIColor.gray
        refresh.tintColor = UIColor.white
        
        refreshUpcomingTrains()
        MKFullSpinner.show("Loading Trains...")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function requests upcoming trains for DBRK station via Alamofire
    @objc func refreshUpcomingTrains(){
    
        print("Refreshing trains for DBRK")
        Alamofire.request("http://api.bart.gov/api/etd.aspx?cmd=etd&orig=DBRK&key=\(Constants.BARTAPIKey)&json=y").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.upcomingTrains = json["root"]["station"][0]["etd"]
                self.tableView.reloadData()
                self.refresh.endRefreshing()
                MKFullSpinner.hide()
                
            case .failure(let error):
                print(error)
                self.refresh.endRefreshing()
                MKFullSpinner.hide()

            }
        }
    }
    
    //Sets number of sections (Main section, upcoming trains and further options section)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    //Sets the number of rows in each section defined above
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 3 //Always 3 cells in first section
        }
        else if(section == 2){
            return 2
        }
        else if(upcomingTrains == nil){
            return 0 //None in second if upcomingTrains JSON fails to update
        }
        else {
            return upcomingTrains.count //Updates to number of upcoming trains when JSON updates
        }
    }
    
    //Defines all cells of the tableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            switch indexPath.row{
                case 0:
                    let cell = self.tableView.dequeueReusableCell(withIdentifier:"mainCell", for: indexPath)
                    return cell
                case 1:
                    let cell = self.tableView.dequeueReusableCell(withIdentifier:"orangeCell", for: indexPath)
                    return cell
                case 2:
                    let cell = self.tableView.dequeueReusableCell(withIdentifier:"redCell", for: indexPath)
                    return cell
                default:
                    return self.tableView.dequeueReusableCell(withIdentifier:"redCell", for: indexPath)
                }
        }
        else if(indexPath.section == 1) { //upcoming train cell
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
        else{
            switch indexPath.row{
            case 0:
                let cell = self.tableView.dequeueReusableCell(withIdentifier:"otherStationsCell", for: indexPath)
                return cell
            default:
                let cell = self.tableView.dequeueReusableCell(withIdentifier:"tripPlannerCell", for: indexPath)
                return cell
            }
        }
    }
    
    //Returns heights of each cell - Static for section 1 cells and universal for section 2
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0){
            switch indexPath.row{
            case 0:
                return 100
            case 1:
                return 10
            case 2:
                return 10
            default:
                return 0
            }
        }
        else if(indexPath.section == 1){
            return 135
        }
        else{
            return 44
        }
    }
    
    //Gives titles of each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 1:
            return "Upcoming Trains"
        case 2:
            return "Other Tools"
        default:
            return ""
        }
    }
    

}

