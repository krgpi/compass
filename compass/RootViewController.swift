//
//  RootViewController.swift
//  Polaris
//
//  Created by y.k.noaki on 2018/07/25.
//  Copyright © 2018年 y.k.noaki. All rights reserved.
//

import UIKit
import GLKit
import CoreMotion
import CoreLocation

class RootViewController: UIViewController, CLLocationManagerDelegate{
 
    @IBOutlet weak var superview: UIView!
    @IBOutlet weak var hrlevel: UIView!
    @IBOutlet weak var level: UIView!
    @IBOutlet weak var OrientCircle: UIView!
    @IBOutlet weak var angleLabel: UILabel!
    let manager = CMMotionManager() //manage motion sensor
    let locationManager = CLLocationManager()
    @IBOutlet weak var headingLabel:UILabel!
    @IBOutlet weak var attilabel: UILabel!
    @IBOutlet weak var IdoKeido: UILabel!
    let generator = UINotificationFeedbackGenerator()
    let selectgenerator = UISelectionFeedbackGenerator()
    let tapgenerator = UIImpactFeedbackGenerator(style: .heavy)
    var northflag: Bool = false
    var prvnorthflag: Bool = false
    var henkaku = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.startUpdatingLocation()
        let screenWidth = self.view.bounds.width
        let screenHeight = self.view.bounds.height
        
        //Define Parameter
        let marg:Double = 0.05 //detect horizontal allowable error
        var hrflag: Bool = false //init flag
        var prvhrflag: Bool = false //init flag

        //Collect superview's width and height
        let super_w:Double = Double(screenWidth)
        let super_h:Double = Double(screenHeight)
        //define circle's radius
        let radius:Double = Double(40)
        let OrientCircleRadius:Double = Double(150)
        
        //Draw fundamental direction line
        let drawline = DrawLine(frame: CGRect(x: 0, y: 0,
                                              width: screenWidth, height: screenHeight))
        self.view.addSubview(drawline)
        //Draw orient circle
        self.OrientCircle.frame = CGRect(x:super_w/2 - OrientCircleRadius,y:super_h/2 - OrientCircleRadius,width:OrientCircleRadius*2,height:OrientCircleRadius*2)
        self.OrientCircle.layer.cornerRadius = self.OrientCircle.frame.size.width/2
        self.OrientCircle.clipsToBounds = true
        self.OrientCircle.layer.borderColor = UIColor.red.cgColor
        self.OrientCircle.layer.borderWidth = 1.0
        //Add headingLabel to orient circle
//        self.headingLabel.frame = CGRect(x:OrientCircle.frame.midX - headingLabel.frame.midX, y:OrientCircle.frame.minY - headingLabel.frame.midY, width: 100, height: 30)
//        self.headingLabel.sizeToFit()
//        self.headingLabel.clipsToBounds = true
//        self.headingLabel.center = CGPoint(x:OrientCircle.frame.midX, y:OrientCircle.frame.midY)
//        self.OrientCircle.addSubview(headingLabel)
        //Draw base circle of horizontal
        self.hrlevel.frame = CGRect(x:super_w/2 - radius,y:super_h/2 - radius,width:radius*2,height:radius*2)
        self.hrlevel.layer.cornerRadius = self.hrlevel.frame.size.width/2
        self.hrlevel.clipsToBounds = true
        self.hrlevel.layer.borderColor = UIColor.red.cgColor
        self.hrlevel.layer.borderWidth = 1.0
        
        generator.prepare() //prepare taptic feedback
        manager.deviceMotionUpdateInterval = 0.05 //Interval of getting sensor value
        guard manager.isDeviceMotionAvailable,
            let queue = OperationQueue.current else{
                return
        }
        manager.startDeviceMotionUpdates(to: queue){data, error in guard let data = data else {return}
            let ro = data.attitude.roll
            let pit = data.attitude.pitch
            let ya = data.attitude.yaw
            self.attilabel.text = "roll:" + String(format: "%.3f",ro) + "\npitch:" + String(format: "%.3f",pit) + "\nyaw:" + String(format: "%.3f",ya)

            //floating circle
            self.level.frame = CGRect(x:super_w/2 + ro*100 - radius,y:super_h/2 + pit*100 - radius,width:radius*2,height:radius*2)
            self.level.layer.cornerRadius = self.level.frame.size.width/2
            self.level.clipsToBounds = true
            self.level.layer.borderColor = UIColor.white.cgColor
            self.level.layer.borderWidth = 5.0
            self.level.isOpaque = true
            
            //Detect Horizontal
            hrflag = -marg..<marg ~= ro &&  -marg..<marg ~= pit //BOOL
            if hrflag != prvhrflag{ //XOR
                switch prvhrflag{
                case true:
                    self.OrientCircle.backgroundColor = UIColor.black
                default:
                    UIView.animate(withDuration: 0.25, animations: {
                        self.OrientCircle.backgroundColor = UIColor.red
                    }, completion:nil)
                    self.generator.notificationOccurred(.success)
                }
            }
            prvhrflag = hrflag //BOOL
            
        } //END manager.startDeviceMotionUpdates
        
        let drawmarker = DrawMarker(frame: CGRect(x: 0, y: 0,
                                                  width: self.OrientCircle.frame.width, height: self.OrientCircle.frame.height))
        self.OrientCircle.addSubview(drawmarker)
        drawmarker.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
        
        if CLLocationManager.locationServicesEnabled() {
            // 何度動いたら更新するか（デフォルトは1度）
            locationManager.headingFilter = 0.1
            // デバイスのどの向きを北とするか（デフォルトは画面上部）
            locationManager.headingOrientation = .portrait
            
            tapgenerator.prepare()
            locationManager.desiredAccuracy=kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingHeading()
            locationManager.delegate = self
        }
        
        view.bringSubviewToFront(level)
        view.bringSubviewToFront(hrlevel)
        view.bringSubviewToFront(headingLabel)
    }//END override func ViewDidLoad
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 {
            return //周辺に磁気の強いものがあるため、正常な値が取得できない
        }
        // Get the heading(direction)
        let heading: CLLocationDirection = ((newHeading.trueHeading > 0) ?
            newHeading.trueHeading : newHeading.magneticHeading);
        let headingStatus = ((newHeading.trueHeading > 0) ?
            "真北" : "磁北");
        UIView.animate(withDuration: 0.5) {
            let angle = CGFloat(heading) * CGFloat.pi / 180 // convert from degrees to radians
            self.OrientCircle.transform  = CGAffineTransform(rotationAngle: -angle)// rotate the picture
        }
        angleLabel.text = String(format: "%0.0f°", heading)
        henkaku = Double(newHeading.trueHeading - newHeading.magneticHeading)
        headingLabel.text = headingStatus
        northflag = 0.0...0.05 ~= CGFloat(heading) || 359.5...360.0 ~= CGFloat(heading)
        if northflag != prvnorthflag{
            switch prvnorthflag{
            case false:
                self.tapgenerator.impactOccurred()
            default:
                break
            }
        }
        prvnorthflag = northflag
        var fheading = CGFloat(heading)
        fheading.round()
        switch fheading {
        case 90.0,180.0,270.0:
            self.selectgenerator.selectionChanged()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,
            CLLocationCoordinate2DIsValid(newLocation.coordinate) else {
                self.IdoKeido.text = "Error"
                return
        }
        
        self.IdoKeido.text = "".appendingFormat("%.2f", newLocation.coordinate.latitude) + " " + "".appendingFormat("%.2f", newLocation.coordinate.longitude) + "\n偏角:" + "".appendingFormat("%.2f", henkaku) + "°"
//        lat = newLocation.coordinate.latitude
//        lng = newLocation.coordinate.longitude
    }
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}//END class RootViewController
