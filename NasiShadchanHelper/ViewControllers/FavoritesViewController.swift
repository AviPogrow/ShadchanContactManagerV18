//
//  FavoritesViewController.swift
//  NasiShadchanHelper
//
//  Created by user on 5/3/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import Firebase

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // ----------------------------------
    // MARK: - IB-OUTLET(S)
    //
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var vwNoDataFound: UIView!
    @IBOutlet weak var segmentCntrl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    struct TableView {
        struct CellIdentifiers {
            static let savedSingleCell = "SavedSingleCell"
        }
    }
    
    // MARK: - Properties
    fileprivate let singleCellIdentifier = "SingleCellID"
    
    
    // array of dictionaries
    var favChildArr = [[String : String]]()
    
    // array of dictionaries where each entri
    // is a profile
    var sentSegmentChildArr = [[String : String]]()
    
    // array of nasi girl objects
    // for sent
    var arrSentSegmentFavGirlsList = [NasiGirlsList]()
    
    // array of strings holding the childAutoID
    var aryChildKey = [String]()
    
    // arrayo of strings holding values of sent profiles
    var aryChildKeyForSent = [String]()
    
    var arrFavGirlsList = [NasiGirlsList]()
    
    // will hold the final list for presentation
    var arrMainGirlsList = [NasiGirlsList]()
    
    
    var arrTempFilterList = [NasiGirlsList]()
    
    var searchActive:Bool = false
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpSegmentControlApperance()
        
        navigationItem.title = "My Saved Nasi Singles"
        
        NotificationCenter.default.addObserver(self, selector: #selector(favouriteRemovedByUser(notificationReceived:)), name: Constant.EventNotifications.notifRemoveFromFav, object: nil)
        
        let cellNib = UINib(nibName: TableView.CellIdentifiers.savedSingleCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableView.CellIdentifiers.savedSingleCell)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.layer.borderWidth = 1;
        searchBar.layer.borderColor = UIColor.white.cgColor
        
        //self.vwNoDataFound.isHidden = true
        //self.updateFav()
        //self.getResearchList()
       // self.getSentResumeList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK:- Selectors
    @objc func favouriteRemovedByUser(notificationReceived : Notification) {
        
        // get the received object as a dictionary
        if let object = notificationReceived.object as? [String: Any] {
            
            // index into the dictionary using updateStatus
            if let updateStatus = object["updateStatus"] as? String {
                
                // if update status is research list
                if updateStatus == "researchList" {
                    print("here is research list")
                    
                    
                    // clear out the whole array of childAutoID keys
                    // clear out arr of favorite girls
                    // clear out fav child arrr
                    aryChildKey.removeAll()
                    arrFavGirlsList.removeAll()
                    favChildArr.removeAll()
                    
                    // set select index to 0
                    self.segmentCntrl.selectedSegmentIndex = 0
                    
                    // get the research list
                    self.getResearchList()
                    
                // if the notification is a sentList object
                // we present the sent list array
                } else if updateStatus == "sentList" {
                    print("here is sent list")
                    
                    // clear the array of keys
                    // holding the values of the sent list
                    aryChildKeyForSent.removeAll()
                    
                    // clear the array of sent girls
                    arrSentSegmentFavGirlsList.removeAll()
                    
                    // clear the sent array
                    sentSegmentChildArr.removeAll()
                    
                    // set the selectedSegment to 1
                    self.segmentCntrl.selectedSegmentIndex = 1
                    
                    // get the sent resume list
                    self.getSentResumeList()
                }
            }
        } else { // go to first index and load the research list
            
            // self.updateFav()
            arrFavGirlsList.removeAll()
            favChildArr.removeAll()
            
            self.segmentCntrl.selectedSegmentIndex = 0
            
            //
            self.getResearchList()
        }
    }
    
    func setUpSegmentControlApperance() {
        segmentCntrl.selectedSegmentTintColor = Constant.AppColor.colorAppTheme
        let titleTextAttributesSelected = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                           NSAttributedString.Key.font: Constant.AppFontHelper.defaultRegularFontWithSize(size: 14)]
        segmentCntrl.setTitleTextAttributes(titleTextAttributesSelected, for:.selected)
        
        let titleTextAttributesDefault = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                          NSAttributedString.Key.font: Constant.AppFontHelper.defaultRegularFontWithSize(size: 14)]
        segmentCntrl.setTitleTextAttributes(titleTextAttributesDefault, for:.normal)
        
        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0
    }
    
    @IBAction func segmentCntrlTapped(_ sender: UISegmentedControl) {
        self.reloadSegmentCntrl(selectedIndex: sender.selectedSegmentIndex)
    }
    
    
    // based on the selected segment get the right array
    // and reload the tableView
    func reloadSegmentCntrl(selectedIndex:Int) {
        
        // if the research segment is selected
        if selectedIndex == 0 {
            Analytics.logEvent("favourite_screen_segmentControl_act", parameters: [
                "item_name": "Full Time Yeshiva",
            ])
            
            // set the arrFavGirlsList using
            // arrMainGirlsList
            arrFavGirlsList = self.arrMainGirlsList
            
            
          // but if the sent segment is selected we still
          // use the arrFavGirlsList but we set it
          // using arrSentSegment
        } else if selectedIndex == 1 {
            Analytics.logEvent("favourite_screen_segmentControl_act", parameters: [
                "item_name": "Full Time College/Working",
            ])
            
            arrFavGirlsList = self.arrSentSegmentFavGirlsList
        }
        
        // now that we have figured out which list to assign
        // arrFavGirlsList
        // we store it in a temp list
        arrTempFilterList = arrFavGirlsList
        
        
        if arrFavGirlsList.count > 0 {
            self.tableView.reloadData()
            self.tableView.isHidden = false
            self.vwNoDataFound.isHidden = true
            
        } else {
            self.tableView.isHidden = true
            self.vwNoDataFound.isHidden = false
        }
        
    }
    
    
    // go to the research node
    // get all the child nodes
    // get the autoID for each node and build
    // dictionaries which have the
    // childAutoID as a value under child_key
    // and append these dictionaries to
    // the array fav child array
    // then call filterFavData
    // to clean up this array of dictionaries
    func getResearchList() {
        
        ref = Database.database().reference()
        
        guard let myId = UserInfo.curentUser?.id else {
            return
        }
    
        // listen for any child added to research/currentUser
        ref.child("research").child(myId).observe(.childAdded) { (snapShots) in
            self.view.hideLoadingIndicator()
            
            // clear out favChildArray
            self.favChildArr.removeAll()
            
            // get the value property of the snapshots
            // which is itself a dictionary
            // the key is the childAutoID
            let snap = snapShots.value as? [String : Any]
            
            
            if (snapShots.value is NSNull ) {
                print("– – – Data was not found – – –")
                
            } else {
                
                // the value is a dictionary holding the key and value
                // of a girls UUID
                var snap = snapShots.value as? [String : String]
                
                // the key is the autoID so extract the autoID
                // and store it under child_key
                // so we have a dictionary with
                // the girls UUID
                // and the childAutoID
                snap?["child_key"] = snapShots.key as? String
                
                // unwrap the dictionary
                if let dict = snap {
                    
                    // arrFavGirlsList.removeAll()
                    
                    // add the dictionary to favChildArray
                    // which is an array of dictionaries
                    self.favChildArr.append(dict)
                    
                    self.filterFavData()
                } else {
                    print("not a valid data")
                }
            }
        }
        
        self.filterFavData()
    }
    
    func getSentResumeList() {
        // self.view.showLoadingIndicator()
        ref = Database.database().reference()
        guard let myId = UserInfo.curentUser?.id else {
            return
        }
        print("here is id", myId) //"myFav"
        ref.child("sentsegment").child(myId).observe(.childAdded) { (snapShots) in
            self.view.hideLoadingIndicator()
            self.sentSegmentChildArr.removeAll()
            
            let snap = snapShots.value as? [String : Any]
            
            print(snap)
            if (snapShots.value is NSNull ) {
                print("– – – Data was not found – – –")
            } else {
                
                var snap = snapShots.value as? [String : String]
                
                snap?["child_key"] = snapShots.key as? String
                
                if let dict = snap {
                    print(dict)
                    // arrFavGirlsList.removeAll()
                    self.sentSegmentChildArr.append(dict)
                    self.filterSentResumeData()
                } else {
                    print("not a valid data")
                }
            }
        }
        
        self.filterSentResumeData()
    }
    
    func filterSentResumeData() {
        if sentSegmentChildArr.count > 0 {
            print("here is fav child", sentSegmentChildArr)
            print("here is fav child count", sentSegmentChildArr.count)
            for (index,list) in Variables.sharedVariables.arrList.enumerated() {
                let currentId = list.currentGirlUID
                for (innerIndex,list) in sentSegmentChildArr.enumerated() {
                    let userId = list["userId"]
                    let childKey = list["child_key"]
                    print("here is user id", userId ?? "")
                    print("here is child key", childKey ?? "")
                    if currentId == userId {
                        print("append")
                        arrSentSegmentFavGirlsList.append(Variables.sharedVariables.arrList[index])
                        aryChildKeyForSent.append(childKey!)
                    }
                }
            }
            
            arrSentSegmentFavGirlsList = arrSentSegmentFavGirlsList.reversed()
            aryChildKeyForSent = aryChildKeyForSent.reversed()
            
            if segmentCntrl.selectedSegmentIndex == 1 {
                self.reloadSegmentCntrl(selectedIndex: 1)
            }
        } else {
            self.tableView.isHidden = true
            self.vwNoDataFound.isHidden = false
            print("here is no fav child")
        }
    }
    
    
    func updateFav(){
        
        ref = Database.database().reference()
        
        guard let myId = UserInfo.curentUser?.id else {
            return
        }
        
        // observe the research list and if a child is removed
        // from firebase we need to locate it and
        // remvoe it from the local array
        ref.child("research").child(myId).observe(.childRemoved) { (snapShots) in
            self.view.hideLoadingIndicator()
            
            //            self.favChildArr.removeAll()
            
            let snap = snapShots.value as? [String : Any]
            
            print(snap)
            
            if (snapShots.value is NSNull ) {
              //  print("– – – Data was not found – – –")
            
            } else {
                
                //
                var snap = snapShots.value as? [String : String]
                
                snap?["child_key"] = snapShots.key as? String
                
                if let dict = snap {
                    print(dict)
                    
                    // finc the dictionary in favChildArray
                    // and remove it from the array
                    if self.favChildArr.contains(dict) {
                        
                        guard let idx = self.favChildArr.firstIndex(of: dict) else{
                            print("nnn--")
                            return
                        }
                        self.favChildArr.remove(at: idx)
                    }
                    
                    // clear out the main arrays
                    self.arrFavGirlsList.removeAll()
                    self.arrMainGirlsList.removeAll()
                    
                    // self.favChildArr.append(dict)
                    self.filterFavData()
                } else {
                    print("not a valid data")
                }
            }
        }
    }
    
    
    //
    func filterFavData() {
    
      // iterate over the master list of girls array
      // get each girls UUID and look if we it matches
      // any of our research girls UUID
      // if there is a match
      // add that girl's profile to an array NasiListGirls
      for (index,list) in Variables.sharedVariables.arrList.enumerated() {
        
        // get the UUID of current element
        let currentId = list.currentGirlUID
            
         // iterate over the array of dictionaries
        // get the girls UUID
        // does it match?
         for (innerIndex, list) in favChildArr.enumerated() {
                    
                    let userId = list["userId"]
                    let childKey = list["child_key"]
                    
                    
                    if currentId == userId {
                        print("append")
                        
                    // if it matches index into the nasi girls main list
                    // and append the element to our array
                    // and add the childAutoID key to an array of keys
                    arrFavGirlsList.append(Variables.sharedVariables.arrList[index])
                        
                        // add the childAutoID key to the
                        // array of childAutoID keys
                        aryChildKey.append(childKey!)
                    }
                
            
    
            // reverse the array's order
            arrFavGirlsList = arrFavGirlsList.reversed()
            
            // an array of child keys to index into the
            // nested json using the childAutoID
            aryChildKey = aryChildKey.reversed()
            
            arrMainGirlsList = arrFavGirlsList
        
            self.reloadSegmentCntrl(selectedIndex: 0)
       
        }
            
            self.tableView.isHidden = true
            self.vwNoDataFound.isHidden = false
            print("here is no fav child")
        }
    }
    
    // MARK: - Table View Delegates
    
    
    // we use arrFavGirlsList to drive the tableView
    // and we use other arrays to to set the array
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFavGirlsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: singleCellIdentifier, for: indexPath) as! SingleTableViewCell
        
        // model
        var model: NasiGirlsList!
        
        model = arrFavGirlsList[indexPath.row]
        cell.nameLabel?.text =  "\(model.firstNameOfGirl ?? "")" + " "  + "\(model.lastNameOfGirl ?? "")" //top 1 name
        
        let heightInFt = model.heightInFeet ?? ""
        let heightInInches = model.heightInInches ?? ""
        
        let height = "\(heightInFt)\'" + "\(heightInInches)\""
        
    
        cell.categoryLabel.textColor = .lightGray
        cell.categoryLabel.text = "\(model.category ?? "") - " + (model.yearsOfLearning ?? "")
        
        
        if (model.imageDownloadURLString ?? "").isEmpty {
            print("this is empty....", model.imageDownloadURLString ?? "")
            cell.profileImageView?.image = UIImage.init(named: "placeholder")
        } else {
            //  img.kf.indicatorType = .activity
            cell.profileImageView.loadImageFromUrl(strUrl: String(format: "%@",model.imageDownloadURLString!), imgPlaceHolder: "placeholder")
            print("this is not empty....", model.imageDownloadURLString ?? "")
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        
        /*
         let vcFavDetail = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteDetailVC") as! FavoriteDetailVC
         self.navigationController?.pushViewController(vcFavDetail, animated: true)
         */
        /*
         let vcSingleDetail = self.storyboard?.instantiateViewController(withIdentifier: "SingleDetailViewController") as! SingleDetailViewController
         vcSingleDetail.selectedSingle = arrFavGirlsList[indexPath.row]
         vcSingleDetail.isFromFav = true
         vcSingleDetail.delegate = self
         self.navigationController?.pushViewController(vcSingleDetail, animated: true)
         */
        
    }
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowDetail" {
            let detailViewController = segue.destination as! ShadchanListDetailViewController
            let indexPath = sender as! IndexPath
            
            detailViewController.fromProject = true
            
            
            // based on the selectedSegment
            // we pass on if the list was from research or sent
            // also the childAutoID key of selected profile
            // and the actual profile
            if self.segmentCntrl.selectedSegmentIndex == 0 {
                
                detailViewController.tableName = "research"
               detailViewController.childKey = self.aryChildKey[indexPath.row]
                             
             } else {
                
                detailViewController.tableName = "sentsegment"
                detailViewController.childKey = self.aryChildKeyForSent[indexPath.row]

                }
            
            // pass the selected single to the detailVC
            detailViewController.selectedSingle = arrFavGirlsList[indexPath.row]
            
            Analytics.logEvent("view_favouriteDetail", parameters: [
                "selected_item_name": arrFavGirlsList[indexPath.row].firstNameOfGirl ?? "",
                "selected_item_number": indexPath.row,
                "screen_name": "FavoritesViewController"
            ])
            
        }
    }
    // MARK: -Status Bar Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            var message = ""
            if self.segmentCntrl.selectedSegmentIndex == 0 {
                message =  Constant.ValidationMessages.msgConfirmationToDelete
            }else {
                message =  Constant.ValidationMessages.msgConfirmationToDeleteSent

            }
            
            let alertControler = UIAlertController.init(title:"", message:message, preferredStyle:.alert)
            alertControler.addAction(UIAlertAction.init(title:"Yes", style:.default, handler: { (action) in
              
                
                // remove the current element at the indexPath.row
                // from the arrFavGirlsList which is the array
                // driving the tableView
                // then invoke the swipeDelete function that
                // removes it either from research list or sent list
                if self.arrFavGirlsList.count > 0 {
                    self.arrFavGirlsList.remove(at: indexPath.row)
                    
                    if self.segmentCntrl.selectedSegmentIndex == 0 {
                        
                        self.swipeDeleteRemoveFromList(self.aryChildKey[indexPath.row], tableName: "research", currentIndexPath: indexPath)
                    } else {
                        
                        self.swipeDeleteRemoveFromList(self.aryChildKeyForSent[indexPath.row], tableName: "sentsegment", currentIndexPath: indexPath)
                    }
                    // self.tableView.reloadData()
                }
            }))
            alertControler.addAction(UIAlertAction.init(title:"No", style:.destructive, handler: { (action) in
                print("no")
            }))
            self.present(alertControler,animated:true, completion:nil)
        }
    }
    
    // removes the profile from either the research list or the
    // sent list
    // then posts a notfication that profile was removed
    func swipeDeleteRemoveFromList(_ childKey:String, tableName:String, currentIndexPath: IndexPath) {
        
        print("here is", tableName)
        
        ref = Database.database().reference()
        
        let myId = UserInfo.curentUser?.id
        
        // use tableName to get the right node in the firebase tree
        // either the research or the sent
        // then user's id
        // then the childAutoID key
        // then remove the value
        ref.child(tableName).child(myId!).child(childKey).removeValue { (error, dbRef) in
            
            self.view.hideLoadingIndicator()
            
            if error != nil{
                print(error?.localizedDescription)
                
            } else {
                
                print(dbRef.key)
                
                
                // post a notification that declares a profile was
                // removed from the favorites screen
                // and either it was removed from the
                // research list or from the sent list
                if tableName == "research" {
                    NotificationCenter.default.post(name: Constant.EventNotifications.notifRemoveFromFav, object: ["updateStatus":"researchList"])
                } else {
                    NotificationCenter.default.post(name: Constant.EventNotifications.notifRemoveFromFav, object: ["updateStatus":"sentList"])
                }
            }
        }
    }
}

extension FavoritesViewController : reloadDataDelegate{
    func reloadData(isTrue: Bool) {
        if isTrue{
            self.navigationController?.popViewController(animated: true)
            updateFav()
        }
    }
    
}
// MARK: - SEARCHBAR DELEGATE(S)
extension FavoritesViewController:UISearchBarDelegate {
    
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
        self.reloadSegmentCntrl(selectedIndex: segmentCntrl.selectedSegmentIndex)
        
        let searchFinalText = searchText.uppercased()
        
        if searchFinalText.count != 0 {
            
            arrFavGirlsList.removeAll()
            
            if arrTempFilterList.count != 0 {
                
                for a in 0...arrTempFilterList.count-1{
                    if ((arrTempFilterList[a].lastNameOfGirl?.uppercased())?.contains(searchFinalText))!{
                        arrFavGirlsList.append(arrTempFilterList[a])
                    }
                }
                self.displayFilteredEmotionsInTable()
            } else {
                arrFavGirlsList.removeAll()
                arrFavGirlsList = arrTempFilterList
                self.displayFilteredEmotionsInTable()
            }
        } else {
            arrFavGirlsList.removeAll()
            arrFavGirlsList = arrTempFilterList
            self.displayFilteredEmotionsInTable()
        }
    }
    
    func displayFilteredEmotionsInTable () {
        if arrFavGirlsList.count > 0 {
        } else {
            print("there is no data")
        }
        self.tableView.reloadData()
    }
}
