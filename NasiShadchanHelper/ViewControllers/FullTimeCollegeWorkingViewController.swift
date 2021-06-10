//
//  FullTimeCollegeWorkingViewController.swift
//  NasiShadchanHelper
//
//  Created by user on 4/30/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import Firebase

class FullTimeCollegeWorkingViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    // ----------------------------------
    // MARK: - IB-OUTLET(S)
    //
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    

    let cellIdentifier = "FullTimeCollegeCell"
    var searchActive:Bool = false
    
    // larger array with all girls that gets filtered
    // down
    var arrGirlsList = [NasiGirl]()
    
    // arrays for each segment
    var arrNeedsKoveaSingleGirls = [NasiGirl]()
    var arrDoesNotNeedKoveaSingleSirls = [NasiGirl]()
    
    // arrFilterList is the reduced array that drives the
    // tableView
    var arrFilterList = [NasiGirl]()
    
    // a temp array for the search bar
    var arrTempFilterList = [NasiGirl]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
       
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // sort the arrGirls lsit by date of birt
        // then filter out the categories and return a smaller
        // list
        // then filter out if koveahIttim == Needs kovea
        // and filter out if does not need
        // and each array is used for different segment
        arrGirlsList = self.arrGirlsList.sorted(by: { Int($0.age ) < Int($1.age ) })
    
        // make sure the elements have at least one of these category
        // titles have FTC as part of their category
        // and return the reduced array
        arrGirlsList = self.arrGirlsList.filter { (girlList) -> Bool in
            return girlList.category == Constant.CategoryTypeName.kCategoryString0  || girlList.category == Constant.CategoryTypeName.kCategoryString1 || girlList.category == Constant.CategoryTypeName.kPredicateString2
        }
        
        // make one array for needs and kovea and one for
        // does not need
        arrNeedsKoveaSingleGirls = self.arrGirlsList.filter { (singleGirl) -> Bool in
            return singleGirl.koveahIttim == "Need koveah ittim"
        }
    
        arrDoesNotNeedKoveaSingleSirls = self.arrGirlsList.filter { (singleGirl) -> Bool in
            return singleGirl.koveahIttim == "does not need koveah ittim"
        }
        arrFilterList = arrNeedsKoveaSingleGirls
        /*
         if segmentControl.selectedSegmentIndex == 0 {
         return arrDoesNotNeedKoveaSingleSirls.count
         } else {
         return arrNeedsKoveaSingleGirls.count
         }*/
        
        tableView.reloadData()
        
        let segmentColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: segmentColor]
        segmentControl.selectedSegmentTintColor = segmentColor
        segmentControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        segmentControl.setTitleTextAttributes(selectedTextAttributes, for: .highlighted)
    }
    
    // MARK: -Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    
    
    
    // listen for segment change and assign the correct filterd array
    // to the arrFilterlist that drives the tableView
    // and reload the tableView
    @IBAction func segmentControlTapped(_ sender: UISegmentedControl) {
        
        let selectedIndex = sender.selectedSegmentIndex
        print("the selectedIndex is \(selectedIndex) and title is \(String(describing: sender.titleForSegment(at: selectedIndex)))")
        
        print("the array of needs koveah\(arrNeedsKoveaSingleGirls.count)")
        
    
        if segmentControl.selectedSegmentIndex == 0 {
            arrFilterList = arrNeedsKoveaSingleGirls
          
            
            
            
            
            /*
            Analytics.logEvent("fullTimeCollegeWorking_screen_segmentControl_act", parameters: [
                "item_name": "Doesn't_Need_Koveah",
            ])
 */
            
        }  else {
            arrFilterList = arrDoesNotNeedKoveaSingleSirls
            
            
            /*
            Analytics.logEvent("fullTimeCollegeWorking_screen_segmentControl_act", parameters: [
                "item_name": "Needs_Koveah_Ittim",
            ])
             */
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table View Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrFilterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as!
        FTCollegeTableViewCell
        
        
        
        let segmentColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
        
       
        let currentGirl = arrFilterList[indexPath.row]
        /*
         if segmentControl.selectedSegmentIndex == 0 {
         currentGirl = arrDoesNotNeedKoveaSingleSirls[indexPath.row]
         } else {
         currentGirl = arrNeedsKoveaSingleGirls[indexPath.row]
         }*/
        
        
        cell.nameLabel.text = (currentGirl.nameSheIsCalledOrKnownBy ) + " " + (currentGirl.lastNameOfGirl )
        
        let heightInFt = currentGirl.heightInFeet 
        let heightInInches = currentGirl.heightInInches 
        
        let height = "\(heightInFt)\'" + "\(heightInInches)\""
        
        cell.ageHeightLabel.text = "\(currentGirl.age)" + "-" + height // 2nd Age - Height
        
        // 3rd label - city
        cell.cityLabel.text = currentGirl.cityOfResidence 
        
        // 4th Label is category codes Label
        cell.categoryLabel.text = currentGirl.category 
        
        // 5th Label -  seminary
        cell.seminaryLabel.text = currentGirl.seminaryName 
        //cell.proPlanLabel.text = currentGirl.city
        
        // 6th Label - Pro Track
        // 6th Label Kovea Ittim
        if currentGirl.koveahIttim == "does not need koveah ittim" {
            cell.koveahIttimLabel.backgroundColor = UIColor.white
            cell.koveahIttimLabel.textColor = segmentColor
            cell.koveahIttimLabel.text = "Doesn't need kovea ittim"
        } else {
            
            cell.koveahIttimLabel.textColor = segmentColor
            cell.koveahIttimLabel.backgroundColor = UIColor.white
            cell.koveahIttimLabel.text = "Need kovea ittimm"
        }
        
        cell.profileImageView.loadImageFromUrl(strUrl: currentGirl.imageDownloadURLString, imgPlaceHolder: "")
        
        
        return cell
    }
    
    
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSingleDetails" {
            
            let controller = segue.destination as! ShadchanListDetailViewController
            
            if let indexPath = tableView.indexPath(for: sender
                as! UITableViewCell) {
                
               
                let currentGirl = arrFilterList[indexPath.row]
                
                controller.selectedNasiGirl = currentGirl
                

                
                /*
                Analytics.logEvent("view_ShowSingleDetail", parameters: [
                    "selected_item_name": currentGirl.firstNameOfGirl ?? "",
                    "selected_item_number": indexPath.row,
                    "screen_name": "fulltimecollege"
                ])
                 */
                
            }
        }
    }
}

// MARK: - SEARCHBAR DELEGATE(S)
extension FullTimeCollegeWorkingViewController:UISearchBarDelegate {
    
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
            arrTempFilterList = arrDoesNotNeedKoveaSingleSirls
        }  else {
            arrTempFilterList = arrNeedsKoveaSingleGirls
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
