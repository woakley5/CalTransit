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

    var upcomingTrains = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshUpcomingTrains()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function requests upcoming trains for DBRK station via Alamofire
    func refreshUpcomingTrains(){
        print("Refreshing trains for DBRK")
        Alamofire.request("http://api.bart.gov/api/etd.aspx?cmd=etd&orig=DBRK&key=\(BARTAPIKey)&json=y").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let est = json["root"]["station"][0]["etd"]
                //print(est.rawString())
                self.updateTrainTable(j: est.rawString()!)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateTrainTable(j: String){
        let json = JSON(parseJSON: j)
        //print(json)
        for i in 0 ..< json.count{
            let s = json[i]["destination"].rawString()!
            print(s)
            upcomingTrains.append(s)
        }
        self.tableView.reloadData()
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
            cell.directionLabel.text = upcomingTrains[indexPath.row]
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
            return 100
        }
    }


}

