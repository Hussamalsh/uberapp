//
//  RiderViewController.swift
//  Uber
//
//  Created by Hussi Mac on 2017-10-28.
//  Copyright © 2017 Hussi Mac. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {
    
    
    var locationManager = CLLocationManager();
    var userlocation = CLLocationCoordinate2D();
    var uberhasbeenCalled = false;
    var driverOntheWay = false;
    var driverLocation = CLLocationCoordinate2D();
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var calltappedB: UIButton!
    
    @IBAction func calltapped(_ sender: Any)
    {
        if let email = Auth.auth().currentUser?.email
        {
            if uberhasbeenCalled {
                uberhasbeenCalled = false;
                calltappedB.setTitle("Call An Uber", for: .normal)
                Database.database().reference().child("Riderequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                    snapshot.ref.removeValue()
                    Database.database().reference().child("Riderequest").removeAllObservers();
                })
            }else {
                let rideRequestDictionary : [String:Any] = ["email":email,"lat":userlocation.latitude,"lon":userlocation.longitude];
                Database.database().reference().child("Riderequest").childByAutoId().setValue(rideRequestDictionary);
                uberhasbeenCalled = true;
                calltappedB.setTitle("Cancel Uber", for: .normal)
            }

        }
        
    }
    
    @IBAction func logout(_ sender: Any)
    {
        try? Auth.auth().signOut();
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
        
        // Do any additional setup after loading the view.
        
        if let email = Auth.auth().currentUser?.email
        {
            Database.database().reference().child("Riderequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                self.uberhasbeenCalled = true;
                self.calltappedB.setTitle("Cacel Uber", for: .normal);
                Database.database().reference().child("Riderequest").removeAllObservers();
                
                if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                    if let driverlat = rideRequestDictionary["driverLat"] as? Double {
                        if let driverlon = rideRequestDictionary["driverLon"] as? Double {
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverlat, longitude: driverlon);
                            self.driverOntheWay = true;
                        }
                    }
            })
        }
            
     }
    }
    
    func displayRiderAndDriver(){
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let cord = manager.location?.coordinate{
            let center = CLLocationCoordinate2D(latitude: cord.latitude, longitude: cord.longitude)

            userlocation = center;
            
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            map.setRegion(region, animated: true);
            
            map.removeAnnotations(map.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = center;
            annotation.title = "Your Location";
            map.addAnnotation(annotation);
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
