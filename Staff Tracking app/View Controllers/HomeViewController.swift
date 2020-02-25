//
//  HomeViewController.swift
//  Staff Tracking app
//
//  Created by Phillip Zamora on 2/22/20.
//  Copyright © 2020 Phillip Zamora. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetButton.isEnabled=false
        pauseButton.isEnabled=false
        startButton.isEnabled=true
        workTimerLabel.isEnabled=false
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var workButton: UIButton!
    @IBOutlet weak var workTimerLabel: UILabel!
    
    var isTravel=false;
    
    @IBAction func workButton( sender:Any ){
        
        isTravel = !isTravel
        
        if isTravel {
            
            workButton.setImage(UIImage(named: "WorkMode"), for: .normal)
            workTimerLabel.isEnabled=true
            workTimerLabel.backgroundColor = UIColor.green
            timerLabel.isEnabled=false
            timerLabel.backgroundColor = UIColor.black
           
        }
        else {
            workButton.setImage(UIImage(named: "TravelMode"), for: .normal)
            timerLabel.isEnabled=true
            timerLabel.backgroundColor = UIColor.green
            workTimerLabel.isEnabled=false
            workTimerLabel.backgroundColor = UIColor.black
            
            
        }
    }
    
    var timer = Timer();
    var isTimerRunning = false
    var counter = 0.0
    var workCounter=0.0
    
    @IBAction func resetDidTap( sender:Any ){
        timer.invalidate()
        isTimerRunning = false
        
        if workTimerLabel.isEnabled{
            workCounter=0.0
            workTimerLabel.text="00.00.00.0"
        }
        else{
            counter=0.0
            timerLabel.text="00.00.00.0"
        }
        
        resetButton.isEnabled=false
        pauseButton.isEnabled=false
        startButton.isEnabled=true
         workButton.isEnabled=true
    }
    @IBAction func  pauseDidTap( sender:Any ){
        resetButton.isEnabled=true
        pauseButton.isEnabled=false
        startButton.isEnabled=true
         workButton.isEnabled=true
        isTimerRunning = false
        timer.invalidate()
    }
    @IBAction func startDidTap( sender:Any ){
        if !isTimerRunning{
            timer = Timer.scheduledTimer( timeInterval:0.1, target:self, selector:#selector(runtime),userInfo:nil,repeats:true)
            isTimerRunning=true
            workButton.isEnabled=false
            resetButton.isEnabled=true
            pauseButton.isEnabled=true
            startButton.isEnabled=false
        }
    }
    @objc func runtime(){
        
        var flooredCounter = 0
        
        if workTimerLabel.isEnabled{
            workCounter += 0.1
            
            flooredCounter = Int(floor(workCounter))
        }
        else{
            counter += 0.1
            flooredCounter = Int(floor(counter))
        }
        
        
        
        let hour = flooredCounter/3600
        
        let minute = (flooredCounter % 3600) / 60
        
        var minuteString = "\(minute)"
        if minute<10{
            minuteString="0\(minute)"
        }
        let second = (flooredCounter % 3600) % 60
       
        var secondString = "\(second)"
        if second<10{
            secondString="0\(second)"
        }
        
        
        var deciSecond=""
        
        if workTimerLabel.isEnabled{
            deciSecond = String(format:"%.1f", workCounter).components(separatedBy: ".").last!
            workTimerLabel.text = "\(hour):\(minuteString):\(secondString):\(deciSecond)"
        }
        else{
            deciSecond = String(format:"%.1f", counter).components(separatedBy: ".").last!
            timerLabel.text = "\(hour):\(minuteString):\(secondString):\(deciSecond)"
        }
        
        
    }

}
