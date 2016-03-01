//
//  FeedTableViewController.swift
//  ChallengeMe
//
//  Created by Darryl Nunn on 2/18/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {
    
    var usersBeingFollowed = [String]()
    var imageFiles = [PFFile]()
    var imageId = [String]()
    var imageComment = [""]
    var usernames = [String]()
    var imageStarCount = [Int]()
    
    func addStar (sender: AnyObject) {
        
        
        let star = sender as! UIButton
        star.setImage(UIImage(named: "star.png"), forState: .Normal)
        var imageIdentification = imageId[star.tag]
        var starCount = imageStarCount[star.tag]
        starCount++
        var post = PFQuery(className: "Post")
        post.getObjectInBackgroundWithId(imageIdentification) { (object, error) -> Void in
            if error != nil {
                print(error)
            } else {
                object!["stars"] = starCount
                object?.saveInBackground()
                
            }
        }
        
        print("hi")
    
    }
    
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        
        
        let getFollowedUsersQuery = PFQuery(className: "Followers")
        
        getFollowedUsersQuery.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
        
        getFollowedUsersQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            self.usernames.removeAll(keepCapacity: true)
            self.imageComment.removeAll(keepCapacity: true)
            self.imageFiles.removeAll(keepCapacity: true)
            self.usersBeingFollowed.removeAll(keepCapacity: true)
            self.imageStarCount.removeAll(keepCapacity: true)
            self.imageId.removeAll(keepCapacity: true)
            
            
            if let objects = objects {
                
                for object in objects {
                    
                    let followedUser = object["following"] as! String
                    
                    let getFollowedUsers = PFQuery(className: "Post")
                    
                    getFollowedUsers.whereKey("userId", equalTo: followedUser)
                    getFollowedUsers.orderByDescending("createdAt")
                    
                    
                    getFollowedUsers.findObjectsInBackgroundWithBlock({ (imageObjects, error) -> Void in
                        
                        
                        if let objects = imageObjects {
                            
                            for images in objects {
                                
                                
                                self.imageFiles.append(images["imageFile"] as! PFFile)
                                self.imageComment.append(images["imageComment"] as! String)
                                self.usernames.append(images["username"] as! String)
                                self.imageStarCount.append(images["stars"] as! Int)
                                self.imageId.append(images.objectId!)
                                self.tableView.reloadData()
                                
                                
                                
                                
                                
                                
                            }
                            
                            
                            
                        }
                        
                        
                    })
                    
                    
                }
                
                
            }
            
            
            
            
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCellWithIdentifier("imagePostCell", forIndexPath: indexPath) as! cell
        
        if imageComment.count > 0{
            myCell.userLabel.text = "\(usernames[indexPath.row]) completed the \(imageComment[indexPath.row]) challenge!"
            myCell.starLabel.text = "\(imageStarCount[indexPath.row]) Stars!"
            imageFiles[indexPath.row].getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let downloadedImage = UIImage(data: data!) {
                    
                    myCell.imagePost.image = downloadedImage
                    
                }
            })
        }
        
        //set the tag so that it can be passed to the star button
        myCell.starButtonImage.tag = indexPath.row
        myCell.starButtonImage.addTarget(self, action: "addStar:", forControlEvents: .TouchUpInside)
        
        return myCell
    }
    
}
