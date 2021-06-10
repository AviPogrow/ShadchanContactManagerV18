//
//  FirebaseManager.swift
//  NasiShadchanHelper
//
//  Created by username on 12/14/20.
//  Copyright © 2020 user. All rights reserved.
//


import UIKit
import Firebase

class ResearchViewController: UITableViewController {
    //var nasiSingle: NasiGirlsList!
    //var items: [NasiGirlsList] = []
    
    // an array of NasiGirlList objects
    //var arrFavGirlsList = [NasiGirlsList]()
    
    // will hold the final list for presentation
     // var arrMainGirlsList = [NasiGirlsList]()
    
    // array of dictionaries
    //var arrayOfResearchDictionaries = [[String : String]]()
    // array of strings holding the childAutoID
    //var aryChildKey = [String]()
    //var isAlreadyInResearchList: Bool = false
    //var isAlreadyInSentList: Bool = false
    //var arrayOfGirlUIDs = [String]()
    //var currentAutoIDKey = ""
    //var childAutoIDKeys = [String]()
    //var arrayOfNasiGirls = [NasiGirl]()
    
    let researchRef = Database.database().reference(withPath: "research")
    
    var arrayOfResearchNasiGirls: [NasiGirl] = [NasiGirl]()
    var researchGirlsAutoIDs: [String] = [String]()
    
    //override func viewWillAppear(_ animated: Bool) {
      //  super.viewWillAppear(animated)
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
      self.arrayOfResearchNasiGirls.removeAll()
      tableView.allowsMultipleSelectionDuringEditing = true
        
      // get the id of current user
      guard let myId = UserInfo.curentUser?.id else {return}
        
        // pass current userID to the research list
        let userResearchRef = self.researchRef.child(myId)
        
        // get each child node under the current user's research list
        userResearchRef.observe(.childAdded, with: { (snapshot) in
        
       
          let value = snapshot.value as? [String: AnyObject]
          let girlUUID = value!["userId"]
          let girlUUIDString = "\(girlUUID!)"
            
            // get the key which is the ChildAutoID
           let researchListKey = snapshot.key
           let researchListRef = snapshot.ref
            
           
                  
           // go to the main list of nasi girls
           let nasiGirlsListRef = Database.database().reference(withPath: "NasiGirlsList")
               
             // pass in the girls UUID and get her key value pairs
             let currentGirlRef = nasiGirlsListRef.child(girlUUIDString)
                      
            currentGirlRef.observe(.value, with: { snapshot in

            
            let nasiGirl = NasiGirl(snapshot: snapshot)
                
            // set the research list key from the snapshot
            nasiGirl.researchListKey = researchListKey
            nasiGirl.researchListRef = "\(researchListRef)"
            
            self.arrayOfResearchNasiGirls.append(nasiGirl)
            self.arrayOfResearchNasiGirls.reverse()
                
           
            
                
            DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                  })
                      
             }, withCancel: nil)
            }, withCancel: nil)
        
    }
    

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
      if segue.identifier == "ShowResearchListDetail" {
    let controller = segue.destination as! ShadchanListDetailViewController
            
      if let indexPath = tableView.indexPath(for: sender
        as! UITableViewCell) {
               
               
        
        let currentNasiGirl = arrayOfResearchNasiGirls[indexPath.row]
        controller.selectedNasiGirl = currentNasiGirl
        }
    }
    
    }
    
    
    
    
    // MARK: UITableView Delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrayOfResearchNasiGirls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
      let cell = tableView.dequeueReusableCell(withIdentifier: "GirlResearchCell", for: indexPath) as! GirlResearchCell
        
      let nasiGirl = arrayOfResearchNasiGirls[indexPath.row]
      
           let girlFirstName = nasiGirl.nameSheIsCalledOrKnownBy
            let girlLastName = nasiGirl.lastNameOfGirl
        _ = nasiGirl.imageDownloadURLString
            let girlsName = girlFirstName + " " + girlLastName
            
            cell.mainLabel.text = girlsName
            cell.profileImageView.contentMode = .scaleAspectFit
            
      
        cell.profileImageView.loadImageFromUrl(strUrl: nasiGirl.imageDownloadURLString, imgPlaceHolder: "")
        
        //cell.profileImageView.loadImageUsingCacheWithUrlString(nasiGirl.imageDownloadURLString)
      
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
        
        let currentGirl = arrayOfResearchNasiGirls[indexPath.row]
        let currentGirlRef = currentGirl.researchListRef
        let currentGirlKey = currentGirl.researchListKey
      
        
        guard let myId = UserInfo.curentUser?.id else {return}
          
        self.researchRef.child(myId).child(currentGirlKey).removeValue {
             (error, dbRef) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
                       
            } else {
                self.arrayOfResearchNasiGirls.remove(at: indexPath.row)
                
                let indexPathsToDelete = [indexPath]
                self.tableView.deleteRows(at: indexPathsToDelete, with: .left)
                //self.tableView.reloadData()
            }
          }
        }
     }
    
    
   
    
}
