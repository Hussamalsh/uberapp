//
//  ViewController.swift
//  Uber
//
//  Created by Hussi Mac on 2017-10-28.
//  Copyright © 2017 Hussi Mac. All rights reserved.
//

import UIKit
import FirebaseAuth


class ViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var buttomButton: UIButton!
    
    @IBOutlet weak var rider: UILabel!
    @IBOutlet weak var driver: UILabel!
    
    var signupMode = true;
    
    func displayAlert(title:String, message:String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler:nil));
        self.present(alertController, animated: true, completion: nil);
    }
    
    @IBAction func topTapped(_ sender: Any)
    {
        if email.text!.isEmpty || password.text!.isEmpty
        {
            displayAlert(title: "Missing Infomation", message: "You must provide both Email and Password");
        }else {
            if let _email = email.text {
                if let _password = password.text{
                    if signupMode{  //Sign Up
                        var handle = Auth.auth().createUser(withEmail: _email, password: _password, completion: { (user,error ) in
                            if error != nil{
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else{
                                // self.displayAlert(title: "Infomation", message: "Sign Up Success");
                                if self.riderDriverSwitch.isOn{
                                    //Driver
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest();
                                    req?.displayName = "Driver"
                                    req?.commitChanges(completion: nil);
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                }else {
                                    //Rider
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest();
                                    req?.displayName = "Rider"
                                    req?.commitChanges(completion: nil);
                                    self.performSegue(withIdentifier: "riderseg", sender: nil)
                                }
                                
                            }
                        })
                    }else { // log in
                        var handle = Auth.auth().signIn(withEmail: _email, password: _password, completion: { (user, error) in
                            if error != nil{
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else{
                                //self.displayAlert(title: "Infomation", message: "Log In Success");
                                
                                if user?.displayName == "Driver"
                                {//driver
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                }else { //rider
                                    self.performSegue(withIdentifier: "riderseg", sender: nil)
                                }
                                
                            }
                        })
                    }
                    
                }
            }
        }
        
    }
    @IBAction func buttomTapped(_ sender: Any)
    {
        if signupMode
        {
            topButton.setTitle("Log In", for: .normal);
            buttomButton.setTitle("Sign In", for: .normal);
            rider.isHidden = true;
            driver.isHidden = true;
            riderDriverSwitch.isHidden = true;
            signupMode = false;
        }else{
            topButton.setTitle("Sign In", for: .normal);
            buttomButton.setTitle("Log In", for: .normal);
            rider.isHidden = false;
            driver.isHidden = false;
            riderDriverSwitch.isHidden = false;
            signupMode = true;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

