//
//  PeopleViewController.swift
//  Staff Tracking app
//
//  Created by Phillip Zamora on 3/9/20.
//  Copyright © 2020 Phillip Zamora. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userIdLbl: UILabel!
    @IBOutlet weak var travelStatusLbl: UILabel!
    @IBOutlet weak var travelMinLbl: UILabel!
    @IBOutlet weak var workMinLbl: UILabel!
    @IBOutlet weak var totalMinLbl: UILabel!
    @IBOutlet weak var totalMiles: UILabel!
    @IBOutlet weak var lastUpdateLbl: UILabel!
    
    var person:thing.subordinatesLog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLbl.text="\(person?.FirstName ?? "") \(person?.LastName ?? "")"
        
        userIdLbl.text=String(person?.UserId ?? -1)
        travelStatusLbl.text = person?.TravelStatus
        travelMinLbl.text = String(person?.TodayTravelMinutes ?? 0)
        workMinLbl.text = String(person?.TodayWorkMinutes ?? 0)
        totalMinLbl.text = String(person?.TodayTravelMinutes ?? 0)
        totalMiles.text = String(person?.TodayTotalMiles ?? 0)
        lastUpdateLbl.text = person?.LastUpdateDateTimeUTC
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
