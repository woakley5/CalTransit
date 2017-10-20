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

class ACTransitStopDetailViewController: UIViewController {
    
    var stopID: String?
    var stopName: String?
    var stopCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                
                MKFullSpinner.hide()
            case .failure(let error):
                print(error)
                MKFullSpinner.hide()
                
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
