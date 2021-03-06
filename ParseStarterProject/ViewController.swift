/**
* Copyright (c) 2015-present, Nunnotha, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController, UIImagePickerControllerDelegate, UIAdaptivePresentationControllerDelegate, UITextFieldDelegate {
    
    var signupActive:Bool = true
    
    @IBOutlet var logo: UIImageView!
    
    @IBOutlet var logoLabel: UILabel!
    
    @IBOutlet var userNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var registeredLabel: UILabel!
    @IBOutlet var formLabel: UILabel!
    @IBOutlet var loginLabel: UIButton!
    @IBOutlet var signUpLabel: UIButton!
    var counter = 0
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func alerter (title: String, message: String, actionTitle: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func signUp(sender: AnyObject) {
        
        if userNameField.text == "" || passwordField.text == "" {
            //alert user to fill out form
            alerter("Error in form", message: "Please enter a username and password", actionTitle: "Got it!")
          
        
        } else {
            
            //show spinner
            activityIndicator.frameForAlignmentRect(CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            var errorMessage = "Please try again later."
            
            
            if signupActive {
                //sign up user
                let user = PFUser()
                user.username = userNameField.text
                user.password = passwordField.text
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error == nil {
                        //signup successful
                        self.performSegueWithIdentifier("login", sender: self)
                        let followMyself = PFObject(className: "Followers")
                        
                        followMyself["follower"] = PFUser.currentUser()?.objectId
                        
                        followMyself["following"] = PFUser.currentUser()?.objectId
                        
                        followMyself.saveInBackground()

                       
                    } else {
                        if let errorString = error?.userInfo["error"] as? String {
                            
                            errorMessage = errorString
                            self.alerter("Failed Sign up", message: errorMessage, actionTitle: "Try Again")
                            
                            
                        }
                    }
                    
                })
                
            } else {
                
                PFUser.logInWithUsernameInBackground(userNameField.text!, password: passwordField.text!, block: { (user, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if user != nil {
                        //login successful
                        self.performSegueWithIdentifier("login", sender: self)
                        
                    } else {
                    
                        if let errorString = error?.userInfo["error"] as? String {
                            //alert user of error
                            errorMessage = errorString
                            self.alerter("Failed Log In", message: errorMessage, actionTitle: "Try Again")
                        }
                        
                    }
                    
                })
            }
            
            
        }
        
        
        
    }
    
    @IBAction func login(sender: AnyObject) {
        
        if signupActive {
        
            formLabel.text = "Go ahead and log in."
            registeredLabel.text = "Not a user yet?"
            signUpLabel.setTitle("Log In", forState: UIControlState.Normal)
            loginLabel.setTitle("Sign Up", forState: UIControlState.Normal)
            
            signupActive = false
        
        } else {
            
            formLabel.text = "Use the form below to sign up"
            registeredLabel.text = "Already Registered?"
            signUpLabel.setTitle("Sign Up", forState: UIControlState.Normal)
            loginLabel.setTitle("Log In", forState: UIControlState.Normal)
            
            signupActive = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.userNameField.delegate = self
        self.passwordField.delegate = self
        
        
       
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField:UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }

    
    override func viewDidLayoutSubviews() {
        if counter == 0 {
            logo.center = CGPointMake(logo.center.x, logo.center.y + 400)
            logoLabel.center = CGPointMake(logoLabel.center.x - 400, logoLabel.center.y)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser()?.objectId != nil {
            self.performSegueWithIdentifier("login", sender: self)
            }
        
        if counter == 0 {
        UIView.animateWithDuration(1) { () -> Void in
            self.logo.center = CGPointMake(self.logo.center.x, self.logo.center.y-400)
            
            self.logoLabel.center = CGPointMake(self.logoLabel.center.x + 400, self.logoLabel.center.y)
            
            self.counter++
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

