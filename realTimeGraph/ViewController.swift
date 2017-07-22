//
//  ViewController.swift
//  realTimeGraph
//
//  Created by Keshav Bansal on 21/07/17.
//  Copyright © 2017 Keshav. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import UserNotificationsUI

class ViewController: UIViewController {
    
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var label: UILabel!
    @IBOutlet var chart: Chart!
    var data = [Float]()
    var series = ChartSeries([])
    var currentStored: Int = 0
    
    let requestIdentifier = "SampleRequest"
    var previousNumber: Int = 0
    
    func triggerNotification(){
        
        print("notification will be triggered in five seconds..Hold on tight")
        
        let content = UNMutableNotificationContent()
        content.title = "Consecutive numbers!"
        content.body = "\(self.previousNumber) generated consecutively."
        content.sound = UNNotificationSound.default()
        
        //To Present image in notification
        if let path = Bundle.main.path(forResource: "monkey", ofType: "png") {
            let url = URL(fileURLWithPath: path)
            
            do {
                let attachment = try UNNotificationAttachment(identifier: "sampleImage", url: url, options: nil)
                content.attachments = [attachment]
            } catch {
                print("attachment not found.")
            }
        }
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier:requestIdentifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().add(request){(error) in
            
            if (error != nil){
                
                print(error?.localizedDescription as Any)
            }
        }
    }
//    
//    @IBAction func stopNotification(_ sender: AnyObject) {
//        
//        print("Removed all pending notifications")
//        let center = UNUserNotificationCenter.current()
//        center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
//        
//    }

    override func viewDidAppear(_ animated: Bool) {
        self.headingLabel.frame.origin.y = self.view.frame.midY - self.headingLabel.frame.height/2
        UIView.animate(withDuration: 2.0, animations: {
            self.headingLabel.frame.origin.y = 50
        }, completion: {finished in
            self.chart.isHidden = false
            self.headingLabel.frame.origin.y = 50
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentStored = UserDefaults.standard.integer(forKey: "totalStored")
        
        
        chart.labelFont = UIFont.systemFont(ofSize: 12)
        chart.labelColor = UIColor.white
        chart.yLabels = [0,1,2,3,4,5,6,7,8,9,10]
        chart.yLabelsOnRightSide = false
        
        self.chart.minY = 0
        self.chart.maxY = 10
        
        let appDel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Capture")
        request.returnsObjectsAsFaults = false

        SocketIOManager.sharedInstance.connectToServer(completion: {(value, state) in
            print(value)
            self.currentStored = self.currentStored + 1
            self.label.text = "Random Numbers Stored = \(self.currentStored)"
            
            self.data.append(Float(value))
            if self.data.count > 10{
                self.data.remove(at: 0)
            }
            
            self.series = ChartSeries(self.data)
            self.series.area = true
            self.series.colors = (above: ChartColors.redColor(), below: ChartColors.greenColor(), 7)
            self.chart.removeAllSeries()
            self.chart.add(self.series)
            
            if state == true {
                if value == self.previousNumber{
                    self.triggerNotification()
            }
            self.previousNumber = value
                
            let newEntry = NSEntityDescription.insertNewObject(forEntityName: "Capture", into: context)
            newEntry.setValue(value, forKey: "value")
            newEntry.setValue(NSDate().timeIntervalSince1970, forKey: "time")
            do{
                try context.save()
                UserDefaults.standard.set(self.currentStored, forKey: "totalStored")
            }catch{
                print("There was a problem!")
            }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController:UNUserNotificationCenterDelegate{
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Tapped in notification")
    }
    
    //This is key callback to present notification while the app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Notification being triggered")
        //You can either present alert ,sound or increase badge while the app is in foreground too with ios 10
        //to distinguish between notifications
        if notification.request.identifier == requestIdentifier{
            
            completionHandler( [.alert,.sound,.badge])
            
        }
    }
}
