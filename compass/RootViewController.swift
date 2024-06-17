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

class RootViewController: UIViewController {
	
	private let motionManager = CMMotionManager()
	private let locationManager = CLLocationManager()
	
	@IBOutlet weak var hrlevel: UIView!
	@IBOutlet weak var level: UIView!
	@IBOutlet weak var orientCircleView: UIView!
	@IBOutlet weak var angleLabel: UILabel!
	@IBOutlet weak var headingLabel:UILabel!
	@IBOutlet weak var attilabel: UILabel!
	@IBOutlet weak var latlonLabel: UILabel!
	
	private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
	private let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
	private let tapFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
	
	private var northflag = false
	private var prvnorthflag = false
	private var henkaku = 0.0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		locationManager.delegate = self
		locationManager.startUpdatingLocation()
		let screenWidth = self.view.bounds.width
		let screenHeight = self.view.bounds.height
		
		//Define Parameter
		let marg: Double = 0.05 //detect horizontal allowable error
		var hrflag = false //init flag
		var prvhrflag = false //init flag
		
		//define circle's radius
		let radius = Double(40)
		let OrientCircleRadius = Double(150)
		
		//Draw fundamental direction line
		let drawline = DrawLine(frame: CGRect(x: 0, y: 0,
											  width: screenWidth, height: screenHeight))
		self.view.addSubview(drawline)
		self.view.sendSubviewToBack(drawline)
		//Draw orient circle
		self.orientCircleView.frame = CGRect(x: screenWidth / 2 - OrientCircleRadius, y: screenHeight / 2 - OrientCircleRadius, width: OrientCircleRadius * 2, height: OrientCircleRadius * 2)
		self.orientCircleView.layer.cornerRadius = self.orientCircleView.frame.size.width / 2
		self.orientCircleView.clipsToBounds = true
		self.orientCircleView.layer.borderColor = UIColor.red.cgColor
		self.orientCircleView.layer.borderWidth = 1.0

		//Draw base circle of horizontal
		self.hrlevel.frame = CGRect(x: screenWidth / 2 - radius, y: screenHeight / 2 - radius, width: radius * 2, height: radius * 2)
		self.hrlevel.layer.cornerRadius = self.hrlevel.frame.size.width / 2
		self.hrlevel.clipsToBounds = true
		self.hrlevel.layer.borderColor = UIColor.red.cgColor
		self.hrlevel.layer.borderWidth = 1.0
		
		notificationFeedbackGenerator.prepare() //prepare taptic feedback
		motionManager.deviceMotionUpdateInterval = 0.05 //Interval of getting sensor value
		guard motionManager.isDeviceMotionAvailable,
			  let queue = OperationQueue.current else {
			return
		}
		motionManager.startDeviceMotionUpdates(to: queue){ data, error in
			guard let data = data else {
				return
			}
			let ro = data.attitude.roll
			let pit = data.attitude.pitch
			let ya = data.attitude.yaw
			self.attilabel.text = "roll:" + String(format: "%.3f",ro) + "\npitch:" + String(format: "%.3f",pit) + "\nyaw:" + String(format: "%.3f",ya)
			
			//floating circle
			self.level.frame = CGRect(x: screenWidth / 2 + ro * 100 - radius,y:screenHeight/2 + pit * 100 - radius, width: radius * 2, height: radius * 2)
			self.level.layer.cornerRadius = self.level.frame.size.width / 2
			self.level.clipsToBounds = true
			self.level.layer.borderColor = UIColor.white.cgColor
			self.level.layer.borderWidth = 5.0
			self.level.isOpaque = true
			
			//Detect Horizontal
			hrflag = -marg..<marg ~= ro &&  -marg..<marg ~= pit //BOOL
			if hrflag != prvhrflag { //XOR
				switch prvhrflag{
				case true:
					self.orientCircleView.backgroundColor = UIColor.black
				default:
					UIView.animate(withDuration: 0.25, animations: {
						self.orientCircleView.backgroundColor = UIColor.red
					}, completion:nil)
					self.notificationFeedbackGenerator.notificationOccurred(.success)
				}
			}
			prvhrflag = hrflag //BOOL
			
		}
		
		let drawmarker = DrawMarker(frame:
										CGRect(
											x: 0,
											y: 0,
											width: self.orientCircleView.frame.width,
											height: self.orientCircleView.frame.height
										)
		)
		self.orientCircleView.addSubview(drawmarker)
		drawmarker.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.0)
	}
	
}

extension RootViewController: CLLocationManagerDelegate {
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		// 何度動いたら更新するか（デフォルトは1度）
		manager.headingFilter = 0.1
		// デバイスのどの向きを北とするか（デフォルトは画面上部）
		manager.headingOrientation = .portrait
		
		tapFeedbackGenerator.prepare()
		manager.desiredAccuracy=kCLLocationAccuracyBestForNavigation
		manager.startUpdatingHeading()
		manager.delegate = self
	}
	
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
			self.orientCircleView.transform  = CGAffineTransform(rotationAngle: -angle)// rotate the picture
		}
		angleLabel.text = String(format: "%0.0f°", heading)
		henkaku = Double(newHeading.trueHeading - newHeading.magneticHeading)
		headingLabel.text = headingStatus
		northflag = 0.0...0.05 ~= CGFloat(heading) || 359.5...360.0 ~= CGFloat(heading)
		if northflag != prvnorthflag{
			switch prvnorthflag{
			case false:
				self.tapFeedbackGenerator.impactOccurred()
			default:
				break
			}
		}
		prvnorthflag = northflag
		var fheading = CGFloat(heading)
		fheading.round()
		switch fheading {
		case 90.0, 180.0, 270.0:
			self.selectionFeedbackGenerator.selectionChanged()
		default:
			break
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let newLocation = locations.last,
			  CLLocationCoordinate2DIsValid(newLocation.coordinate) else {
			self.latlonLabel.text = "Error"
			return
		}
		
		self.latlonLabel.text = "".appendingFormat("%.2f", newLocation.coordinate.latitude) + " " + "".appendingFormat("%.2f", newLocation.coordinate.longitude) + "\n偏角:" + "".appendingFormat("%.2f", henkaku) + "°"
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .notDetermined:
			locationManager.requestWhenInUseAuthorization()
		default:
			break
		}
	}
	
}
