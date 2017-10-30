//
//  DriverViewController.swift
//  Uber
//
//  Created by Hussi Mac on 2017-10-29.
//  Copyright © 2017 Hussi Mac. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverViewController: UITableViewController, CLLocationManagerDelegate {
    
    var riderRequest : [DataSnapshot] = []
    var locationManger = CLLocationManager();
    var driverlocation = CLLocationCoordinate2D();
    
    
    
    @IBAction func logoutTapped(_ sender: Any)
    {
        try? Auth.auth().signOut();
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return riderRequest.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequest", for: indexPath)
        
        let snapshot = riderRequest[indexPath.row];
        if let riderequestDictionary = snapshot.value as? [String:AnyObject]{
            if let email = riderequestDictionary["email"] as? String {
                
                if let lat = riderequestDictionary["lat"] as? Double {
                    if let lon = riderequestDictionary["lon"] as? Double {
                        
                        let driverCLLocation = CLLocation(latitude: driverlocation.latitude, longitude: driverlocation.longitude);
                        
                        let riderCLLocation = CLLocation(latitude: lat, longitude: lon);
                        
                        let distance = driverCLLocation.distance(from: driverCLLocation) / 1000;
                        let roundedDistance = round(distance * 100) / 100;
                        
                        cell.textLabel?.text = "\(email) -\(roundedDistance)km away "
                    }
                }
                
                
            }
        }
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = riderRequest[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? AcceptRequestViewController{
            
            if let snapshot = sender as? DataSnapshot {
                if let riderequestDictionary = snapshot.value as? [String:AnyObject]{
                    if let email = riderequestDictionary["email"] as? String {
                        
                        if let lat = riderequestDictionary["lat"] as? Double {
                            if let lon = riderequestDictionary["lon"] as? Double {
                               
                                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon);
                                acceptVC.requestLocation = location;
                                acceptVC.requestEmail = email;
                                acceptVC.driverLocation = driverlocation;
                            }
                        }
                    }
                }
            }
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManger.delegate = self;
        locationManger.desiredAccuracy = kCLLocationAccuracyBest;
        locationManger.requestWhenInUseAuthorization();
        locationManger.startUpdatingLocation();
        
        Database.database().reference().child("Riderequest").observe(.childAdded) { (snapshot) in
            
            if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                if let driverlat = rideRequestDictionary["driverLat"] as? Double {
                    
                }else {
                    self.riderRequest.append(snapshot);
                    self.tableView.reloadData();
                }
            }
            

        }
        // Do any additional setup after loading the view.
        
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { (timer) in
            self.tableView.reloadData();
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate{
            driverlocation = coord;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
