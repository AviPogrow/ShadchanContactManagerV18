//
//  AllNasiGirlsViewController.swift
//  NasiShadchanHelper
//
//  Created by username on 1/12/21.
//  Copyright © 2021 user. All rights reserved.
//

import UIKit
import Firebase
class AllNasiGirlsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var allNasiGirlsList: [NasiGirl] = []
     @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        

        fetchAndCreateNasiGirlsArray()
    //allNasiGirlsList = self.allNasiGirlsList.sorted(by: { ($0.lastNameOfGirl ) < ($1.lastNameOfGirl ) })
    //self.allNasiGirlsList = self.allNasiGirlsList.filter { (singleGirl) -> Bool in
    //    return singleGirl.category != Constant.CategoryTypeName.CategoryEngaged1
    }
        
    func fetchAndCreateNasiGirlsArray() {
        
      self.view.showLoadingIndicator()
        
      allNasiGirlsList.removeAll()
        
      let allNasiGirlsRef = Database.database().reference().child("NasiGirlsList")
        
        guard let myId = UserInfo.curentUser?.id else {return}
        
        allNasiGirlsRef.observe(.childAdded, with: { (snapshot) in
        
        let nasiGirl = NasiGirl(snapshot: snapshot)
        self.allNasiGirlsList.append(nasiGirl)
       
        self.allNasiGirlsList = self.allNasiGirlsList.sorted(by: { ($0.lastNameOfGirl) < ($1.lastNameOfGirl)
            
        })
        self.allNasiGirlsList = self.allNasiGirlsList.filter { (singleGirl) -> Bool in
            return singleGirl.category != Constant.CategoryTypeName.CategoryEngaged1
        }
            
        DispatchQueue.main.async(execute: {
        self.view.hideLoadingIndicator()
        self.tableView.reloadData()
        })
      })
    }
     
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("the array is \(allNasiGirlsList.debugDescription)")
        
        
        
        return allNasiGirlsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllNasiListCell", for: indexPath) as! AllGirlsTableViewCell
        
        let currentGirl = allNasiGirlsList[indexPath.row]
        
        let imageURLString = currentGirl.imageDownloadURLString
        
        cell.configureCellForGirl(girl: currentGirl)
        
        cell.profileImageView.loadImageFromUrl(strUrl: currentGirl.imageDownloadURLString, imgPlaceHolder: "")
    
        return cell
    }
    
   
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK:- Navigation
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "ShowProfileDetails" {
               
               let controller = segue.destination as! ShadchanListDetailViewController
               
               if let indexPath = tableView.indexPath(for: sender
                   as! UITableViewCell) {
                   
                  
                   let currentGirl = allNasiGirlsList[indexPath.row]
                   
                   controller.selectedNasiGirl = currentGirl
            }
        }
    }
    
    
    
    
    
}
