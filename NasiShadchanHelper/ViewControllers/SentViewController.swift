//
//  SentViewController.swift
//  NasiShadchanHelper
//
//  Created by username on 12/17/20.
//  Copyright © 2020 user. All rights reserved.
//


import UIKit
import Firebase

class SentViewController: UITableViewController {
    
   let sentResRef = Database.database().reference(withPath: "sentsegment")
    
    var arrayOfNasiGirls: [NasiGirl] = [NasiGirl]()
    var reversedArrayOfNasiGirls: [NasiGirl] = [NasiGirl]()
    //var sentGirlsAutoIDs: [String] = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    

    
        self.arrayOfNasiGirls.removeAll()
        tableView.allowsMultipleSelectionDuringEditing = true
        
       // get the current user's id
       guard let myId = UserInfo.curentUser?.id else {return}
        
       // go to the sent list and traverse to the current users node
       let userSentRef = self.sentResRef.child(myId)
    
      // for each child in the list we extract the key value pairs
      userSentRef.observe(.childAdded, with: { (snapshot) in
        
    
            
            // get the key value pairs as a dictionary
            let value = snapshot.value as? [String: AnyObject]
            let girlUUID = value!["userId"]
            let girlUUIDString = "\(girlUUID!)"
            
           
            // get the key which is the ChildAutoID
            let sentListKey = snapshot.key
            let sentListRef = snapshot.ref
            
           let nasiGirlsListRef = Database.database().reference(withPath: "NasiGirlsList")
                
           // go to the main list of girls using the girls UUID
           let currentGirlRef = nasiGirlsListRef.child(girlUUIDString)
                
            // get the key value pairs for that specific girl
            // which will be returned in snapshot
            currentGirlRef.observe(.value, with: { snapshot in

            // pass the snapshot of the girl's key value pairs
            // to the init
            let nasiGirl = NasiGirl(snapshot: snapshot)
            nasiGirl.sentListKey = sentListKey
            nasiGirl.sentListRef = "\(sentListRef)"
            
            // add the girl to a swift array that will power the tableView
            // reverse the array so the last appears first
            self.arrayOfNasiGirls.append(nasiGirl)
            self.arrayOfNasiGirls.reverse()
                
            //self.sentGirlsAutoIDs.append(sentGirlAutoID)
            //self.sentGirlsAutoIDs.reverse()
                
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
            })
                
            }, withCancel: nil)
             }, withCancel: nil)
            
      
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    
      // 1. segue id
           if segue.identifier == "ShowProfileDetails" {
         
           // 2. segue destination as
           let controller = segue.destination as! ShadchanListDetailViewController
            // 3. get index path
            if let indexPath = tableView.indexPath(for: sender
                                      as! UITableViewCell) {
            //4. index into array to get current girl
            let currentNasiGirl = arrayOfNasiGirls[indexPath.row]
            controller.selectedNasiGirl = currentNasiGirl
            }
        }
    }
    
    // MARK: UITableView Delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfNasiGirls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
     let cellID = "GirlSentCell"
     let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! GirlSentCell
         
      let nasiGirl = arrayOfNasiGirls[indexPath.row]
            
        /*
           let girlFirstName = nasiGirl.nameSheIsCalledOrKnownBy
            let girlLastName = nasiGirl.lastNameOfGirl
        _ = nasiGirl.imageDownloadURLString
            let girlsName = girlFirstName + " " + girlLastName
            

          
         cell.mainLabel.text = girlsName
        let timestamp = (Date().timeIntervalSince1970) as NSNumber
        
        let seconds = timestamp.doubleValue
        let timestampDate = Date(timeIntervalSince1970: seconds)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        let formattedString = dateFormatter.string(from: timestampDate)
        
        cell.timeLabel.numberOfLines = 0
        cell.timeLabel.text = "last sent at " + formattedString
        cell.timeLabel.isHidden = true 
        
        //cell.timeLabel.text = "\(timestamp)"
        cell.timeLabel.textColor = .secondaryLabel
        
        
        //cell.profileImageView.loadImageUsingCacheWithUrlString(nasiGirl.imageDownloadURLString)
       
 */
        cell.configureCellFor(currentGirl: nasiGirl)
        return cell
     }
    
      
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       return true
     }
    
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
            
            let currentGirl = arrayOfNasiGirls[indexPath.row]
            let currentGirlRef = currentGirl.sentListRef
            let currentGirlKey = currentGirl.sentListKey
            //let sentGirlAutoIDKey = sentGirlsAutoIDs[indexPath.row]
             
            guard let myId = UserInfo.curentUser?.id else {return}
            
            self.sentResRef.child(myId).child(currentGirlKey).removeValue {
                (error, dbRef) in
               
                
                
                if error != nil {
                print(error!.localizedDescription)
                
                } else {
                    
                    
              
                self.arrayOfNasiGirls.remove(at: indexPath.row)
                
                let indexPathsToDelete = [indexPath]
                self.tableView.deleteRows(at: indexPathsToDelete, with: .left)
                //self.tableView.reloadData()
                
            }
           }
          }
        }
}
