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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchForTrip()
    }
    
    func searchForTrip(){
        MKFullSpinner.show("Searching for trips...")
        let typeCodes = ["depart", "arrive"]
        
        Alamofire.request("http://api.bart.gov/api/sched.aspx?cmd=\(typeCodes[searchType!])&orig=\(departureCode!)&dest=\(arrivalCode!)&date=\(date!)&time=\(time!)&key=\(Constants.BARTAPIKey)&json=y").responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.legs = json["root"]["schedule"]["request"]["trip"][0]["leg"]
                print(self.legs)
                self.tableView.reloadData()
                MKFullSpinner.hide()
                
            case .failure(let error):
                print(error)
                MKFullSpinner.hide()
                
            }
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    

    // MARK: - Table view data source

}
