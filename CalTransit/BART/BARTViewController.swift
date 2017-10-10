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

let BARTAPIKey = "ZMZB-5V9S-9W2T-DWE9"

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function requests upcoming trains for DBRK station via Alamofire
    @objc func refreshUpcomingTrains(){
        print("Refreshing trains for DBRK")
        Alamofire.request("http://api.bart.gov/api/etd.aspx?cmd=etd&orig=DBRK&key=\(BARTAPIKey)&json=y").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.upcomingTrains = json["root"]["station"][0]["etd"]
                self.tableView.reloadData()
                self.refresh.endRefreshing()
                
            case .failure(let error):
                print(error)
                self.refresh.endRefreshing()

            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 3
        }
        else if(upcomingTrains == nil){
            return 0
        }
        else{
            return upcomingTrains.count
        }
    }
    
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
        else { //upcoming train cell
            let cell:TrainTableViewCell = self.tableView.dequeueReusableCell(withIdentifier:"trainCell", for: indexPath) as! TrainTableViewCell
            cell.directionLabel.text = "Towards " + upcomingTrains[indexPath.row]["destination"].stringValue
            let arrivalMessage = upcomingTrains[indexPath.row]["estimate"][0]["length"].stringValue + " car train arriving in " + upcomingTrains[indexPath.row]["estimate"][0]["minutes"].stringValue + " minutes"
            cell.arrivingInLabel.text = arrivalMessage
            cell.platformLabel.text = "Use Platform " + upcomingTrains[indexPath.row]["estimate"][0]["platform"].stringValue
            if(upcomingTrains[indexPath.row]["estimate"][0]["bikeflag"].intValue == 1){
                cell.bikesLabel.text = "Bikes are allowed"
            }
            else{
                cell.bikesLabel.text = "Bikes are not allowed"
            }
            return cell
        }
    }
    
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
        else{
            return 133
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 1:
            return "Upcoming Trains"
        default:
            return ""
        }
    }


}

