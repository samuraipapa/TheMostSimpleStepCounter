//
//  ViewController.swift
//  TheMostSimpleStepCounter
//
//  Created by GrownYoda on 3/1/15.
//  Copyright (c) 2015 yuryg. All rights reserved.
//

import UIKit
import CoreMotion  // import CoreMotion

class ViewController: UIViewController {

    // UI Labels
    @IBOutlet weak var labelCurrentSteps: UILabel!
    @IBOutlet weak var labelCurrentDistance: UILabel!
    @IBOutlet weak var labelLast24Hrs: UILabel!
    @IBOutlet weak var labelLast7Days: UILabel!
    
    @IBOutlet weak var generalMessagesTextView: UITextView!
    
    
    // Bool's to Hold Hardware Avaiablity
    var motionActivityAvail = false
    var pedStepCountingAvail = false
    var pedDistanceAvail = false
    var authorizationAvail = false
    
    //  Class Level Pedometer Object
    let myPedometer = CMPedometer()
    
    
    // String to Hold Data
    var historicStepData = ""
    var stepData24hrs = ""
    var distanceData24hr = ""
    var stepData7Days = ""
    var distanceData7Days = ""
    
    var stepDataNow = ""
    var distanceDataNow = 0.00
    
    // NSTimer
    var displayTimer = NSTimer()
    
    
    @IBAction func switch1Toggled(sender: UISwitch) {
        displayHistoricData()
        
        if sender.on{
            getHistoricalData()
            getLiveStepData()
            writeInGeneralMessagesTextView("Getting Live Step Data")
            startUpdateTimer()
        } else{
            myPedometer.stopPedometerUpdates()
            writeInGeneralMessagesTextView("Turned Of Live Step Data")
            getHistoricalData()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        writeInGeneralMessagesTextView("Application Loaded")
        writeInGeneralMessagesTextView("Checking Availablity On This Device")
        checkAvailablity()
        
        getHistoricalData()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //  Updates the UITextView with Message String
    func writeInGeneralMessagesTextView(passedString:String){
        
        generalMessagesTextView.text = passedString + "\r" + generalMessagesTextView.text
    }
    
    // Checks HardWare (User's Device) For Support
    func  checkAvailablity(){        
        
        if CMPedometer.isStepCountingAvailable() {
            writeInGeneralMessagesTextView("Step Counting: is Available")
            pedStepCountingAvail = true
        } else {
            writeInGeneralMessagesTextView("Step Counting: is NOT Available")
            pedStepCountingAvail = false
        }
        
        
        if CMPedometer.isDistanceAvailable() {
            writeInGeneralMessagesTextView("Distance: is Available")
            pedDistanceAvail = true
        } else {
            writeInGeneralMessagesTextView("Distance is NOT Available")
            pedDistanceAvail = false
            
            }
        }
    
    // SetUp Motion Manager
    
    
    //  Fill Out Historic Steps and Distance
    func getHistoricalData(){
    
    let now = NSDate()
    let twoDaysAgo = NSDate(timeIntervalSinceNow: -2*24*60*60)
    let last24hrs = NSDate(timeIntervalSinceNow: -24*60*60)
    let lastSevenDays = NSDate(timeIntervalSinceNow: -7*24*60*60)
        
    println("now is \(now)")
    println("twoDaysAgo is \(twoDaysAgo)")

        
        myPedometer.queryPedometerDataFromDate(last24hrs, toDate: now, withHandler: { data, error in
            
            if (error == nil){
                println("step Data: \(data.numberOfSteps) ")
                println("distance data \(data.distance)")
                self.stepData24hrs = "\(data.numberOfSteps) "
                self.distanceData24hr = "\(data.distance.integerValue / 1609) "
                
            }   else {
                println("step error: \(error)")
                self.stepData24hrs = "step error: \(error)"
                self.displayTimer.invalidate()
                
            }        })
       
        
        myPedometer.queryPedometerDataFromDate(lastSevenDays, toDate: now, withHandler: { data, error in
            
            if (error == nil){
                
                // debugging
                println("stepData7Days: \(data.numberOfSteps) ")
                println("distanceData7Days \(data.distance)")
                
                self.stepData7Days = "\(data.numberOfSteps) "
                self.distanceData7Days = "\(data.distance.integerValue / 1609)"
                
                
            }   else {
                println("step error: \(error)")
                self.stepData7Days = "step error: \(error)"
                
            }        })

    }

    func displayHistoricData(){
     labelLast24Hrs.text = stepData24hrs + "Steps  / " +  distanceData24hr + " Miles"
     labelLast7Days.text = stepData7Days + "Steps  / " + distanceData7Days + " Miles"
        
    }
    
    
    
    // Get Live Step and Distance Data
    func getLiveStepData(){
        let now = NSDate()

        myPedometer.startPedometerUpdatesFromDate(now, withHandler: { data, error in
            
            if (error == nil){
                self.stepDataNow = "\(data.numberOfSteps) "
                self.distanceDataNow = data.distance.doubleValue / 1609.00
                
            }   else {
                println("step error: \(error)")
                self.stepDataNow = "step error: \(error)"
                
            }        })


    }

    // Display Current Data
    func displayLiveStepData(){
        labelCurrentSteps.text = stepDataNow + " Steps"
      //  labelCurrentDistance.text = distanceDataNow + " Kilos"
        
        let myString = String.localizedStringWithFormat("%.5f %@", distanceDataNow, "Miles")
        labelCurrentDistance.text = myString
        
    }
    
    func startUpdateTimer(){
        displayTimer =  NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("displayLiveStepData"), userInfo: nil, repeats: true)
    }
    

}
