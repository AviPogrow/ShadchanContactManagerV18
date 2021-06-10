//
//  YeshivaAndCollegeWorkingViewController.swift
//  NasiShadchanHelper
//
//  Created by user on 5/1/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import Firebase

class YeshivaAndCollegeWorkingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // ----------------------------------
    // MARK: - IB-OUTLET(S)
    //
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
   
    
    var arrGirlsList = [NasiGirl]()
    var arrProTracKSingleGirls = [NasiGirl]()
    var arrNoProTrackSingleGirls = [NasiGirl]()
    var arrFilterList = [NasiGirl]()
    var arrTempFilterList = [NasiGirl]()
    let cellID = "HTCollegeTableCell"
    
    var selectedCategory = "YeshivaandCollege/Working"
    
    let str1 = "Doesnotneedprofessionaltrack"
    let str2 = "N/A"
    let str3 = "Needsprofessionaltrack"
    var searchActive:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
      
        
        //let point = CGPoint(x: 0, y:(self.navigationController?.navigationBar.frame.size.height)!)
        //self.tableView.setContentOffset(point, animated: true)
        
        tableView.dataSource = self
        tableView.delegate = self
       
        
       
        
        self.arrGirlsList = self.arrGirlsList.sorted(by: { Int($0.age ) < Int($1.age ) })
        
        
        self.arrGirlsList = self.arrGirlsList.filter { (singleGirl) -> Bool in
            return singleGirl.category == Constant.CategoryTypeName.kPredicateString2 || singleGirl.category == Constant.CategoryTypeName.kPredicateString3 || singleGirl.category == Constant.CategoryTypeName.kCategoryString1 ||
                singleGirl.category ==
               Constant.CategoryTypeName.kCategoryString3
        }
        
        
        self.arrNoProTrackSingleGirls = self.arrGirlsList.filter { (singleGirl) -> Bool in
            return singleGirl.professionalTrack == "does not need professional track" || singleGirl.professionalTrack == "Does not need professional track"
        }
        
        self.arrProTracKSingleGirls = self.arrGirlsList.filter { (singleGirl) -> Bool in
            return singleGirl.professionalTrack == "Needs professional track"
        }
        
        
        arrFilterList = arrProTracKSingleGirls
        tableView.reloadData()
        
        let segmentColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: segmentColor]
        segmentControl.selectedSegmentTintColor = segmentColor
        segmentControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        segmentControl.setTitleTextAttributes(selectedTextAttributes, for: .highlighted)
    }
    
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        if segmentControl.selectedSegmentIndex == 0 {
            arrFilterList = arrProTracKSingleGirls
          
            //let proTrackSorted = self.arrProTracKSingleGirls.sorted(by: { String($0.lastNameOfGirl ) < String($1.lastNameOfGirl ) })
            
            //for (index, value) in proTrackSorted.enumerated() {
                //print("the index is \(index) and value is\(value.lastNameOfGirl)" + " " + "\(value.professionalTrack)")
           // }
            /*
            Analytics.logEvent("YeshivaAndCollegeWorking_screen_segmentControl_act", parameters: [
                "item_name": "Need Pro Track",
            ])
 */
        } else if segmentControl.selectedSegmentIndex == 1 {
            
            arrFilterList = arrNoProTrackSingleGirls
            /*
            Analytics.logEvent("YeshivaAndCollegeWorking_screen_segmentControl_act", parameters: [
                "item_name": "Does Not Need Pro Track",
            ])
 */
            
        }
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFilterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as!  HTCollegeTableViewCell
    
        let currentSingle = arrFilterList[indexPath.row]
        cell.profileImageView.loadImageFromUrl(strUrl: currentSingle.imageDownloadURLString, imgPlaceHolder: "")
         //cell.profileImageView.loadImageUsingCacheWithUrlString(currentSingle.imageDownloadURLString)
        
        // 1st Label - Age
        cell.nameLabel.text = (currentSingle.nameSheIsCalledOrKnownBy ) + " " + (currentSingle.lastNameOfGirl)
        // 2nd Label - Age/Height
        let heightInFt = currentSingle.heightInFeet 
        let heightInInches = currentSingle.heightInInches 
        
        let height = "\(heightInFt)\'" + "\(heightInInches)\""
        
        // currentSingle.dateOfBirth
        cell.ageHeightLabel.text = "\(currentSingle.age)" + "-" + height // 2nd Age - Height
        
        // 3rd Label
        cell.cityLabel.textColor = UIColor.black
        cell.cityLabel.text =  currentSingle.cityOfResidence
        
        // 4th Label
        cell.categoryLabel.textColor = .lightGray
        cell.categoryLabel.text = currentSingle.category     
        
        // 5th Label is seminary
        cell.seminaryLabel.text = currentSingle.seminaryName 
        
        
        // 6th label - Pro Track
        let segmentColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
        
        if (currentSingle.professionalTrack == "does not need professional track") || (currentSingle.professionalTrack == "Does not need professional track") {
            
            
            cell.professionalTrackLabel.textColor = segmentColor
            cell.professionalTrackLabel.text = "Doesn't Need Pro Track"
        } else {
            cell.professionalTrackLabel.textColor = segmentColor
            cell.professionalTrackLabel.text = "Needs Pro Track"
        }
        return cell
    }
    
   
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowDetails" {
            let controller = segue.destination as! ShadchanListDetailViewController
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                
                let currentSingle = arrFilterList[indexPath.row]
              
                controller.selectedNasiGirl = currentSingle
                
            
                
                /*
                Analytics.logEvent("view_ShowSingleDetail", parameters: [
                    "selected_item_name": currentSingle.firstNameOfGirl ?? "",
                    "selected_item_number": indexPath.row,
                    "screen_name": "YeshivaAndCollege"
                ])
                 */
                
            }
        }
    }
    
}

// MARK: - SEARCHBAR DELEGATE(S)
extension YeshivaAndCollegeWorkingViewController:UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if segmentControl.selectedSegmentIndex == 0 {
            arrTempFilterList = arrProTracKSingleGirls
        }  else {
            arrTempFilterList = arrNoProTrackSingleGirls
        }
        
        let searchFinalText = searchText.uppercased()
        if searchFinalText.count != 0 {
            arrFilterList.removeAll()
            if arrTempFilterList.count != 0 {
                for a in 0...arrTempFilterList.count-1{
                    if ((arrTempFilterList[a].lastNameOfGirl.uppercased()).contains(searchFinalText)){
                        arrFilterList.append(arrTempFilterList[a])
                    }
                }
                self.displayFilteredEmotionsInTable()
            } else {
                arrFilterList.removeAll()
                arrFilterList = arrTempFilterList
                self.displayFilteredEmotionsInTable()
            }
        } else {
            arrFilterList.removeAll()
            arrFilterList = arrTempFilterList
            self.displayFilteredEmotionsInTable()
        }
    }
    
    func displayFilteredEmotionsInTable () {
        if arrFilterList.count > 0 {
        } else {
            print("there is no data")
        }
        self.tableView.reloadData()
        
    }
}
