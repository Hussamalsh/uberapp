//
//  AcceptRequestViewController.swift
//  Uber
//
//  Created by Hussi Mac on 2017-10-29.
//  Copyright © 2017 Hussi Mac. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class AcceptRequestViewController: UIViewController {

    var requestLocation = CLLocationCoordinate2D();
    var driverLocation = CLLocationCoordinate2D();
    var requestEmail = ""
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var acceptTapped: UIButton!
    
    @IBAction func acceptTappedreq(_ sender: Any)
    {
        //Update the ride Request
        Database.database().reference().child("Riderequest").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat":self.driverLocation.latitude,"driverLon":self.driverLocation.longitude])
            Database.database().reference().child("Riderequest").removeAllObservers();
        }
        
        //Give directions
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude);
        
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placeMark,error ) in
            if let placemarks = placeMark{
                if placemarks.count > 0 {
                    let placemark = MKPlacemark(placemark: placemarks[0]);
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = self.requestEmail;
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving];
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true);
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        map.addAnnotation(annotation)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
