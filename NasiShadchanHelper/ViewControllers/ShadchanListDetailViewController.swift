 //
 //  ShadchanListDetailViewController.swift
 //  NasiShadchanHelper
 //
 //  Created by user on 5/29/20.
 //  Copyright © 2020 user. All rights reserved.
 //
 
 import UIKit
 import KMPlaceholderTextView
 import Firebase
 import Lightbox
 import MessageUI
 
 class ShadchanListDetailViewController: UITableViewController {
    // ----------------------------------
    // MARK: - IB-OUTLET(S)
    //
    // Section 1
   
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var headlineImageView: UIImageView!
    
    
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var notesTextView: KMPlaceholderTextView!
    
 
    
    @IBOutlet weak var vwBgForAddPhoto: UIView!
    @IBOutlet weak var imgVwAddMore: UIImageView!
    @IBOutlet weak var imgPlusIcn: UIImageView!
    @IBOutlet weak var lblAddMore: UILabel!
    @IBOutlet weak var btnCamera: UIButton!
    
    // Section 2
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblMiddleName: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    //Section 3
    @IBOutlet weak var lblDob: UILabel!
    @IBOutlet weak var lblHeightft: UILabel!
    @IBOutlet weak var lblFamilySituation: UILabel!
    @IBOutlet weak var lblYearItOccurred: UILabel!
    @IBOutlet weak var lblGirlsCellNumber: UILabel!
  
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var lblState: UILabel!
    @IBOutlet weak var lblZip: UILabel!
    
    //Section 4
    @IBOutlet weak var lblSeminary: UILabel!
    
    
    
    @IBOutlet weak var currentOccupationLabel: UILabel!
    
    @IBOutlet weak var lookingForTextView: UITextView!
    
    @IBOutlet weak var whatsSheLikeLabel: UILabel!
  
    
    @IBOutlet weak var lblPlan: UILabel!
    @IBOutlet weak var lblLivingInIsrael: UILabel!
    @IBOutlet weak var lblFamilyBg: UILabel!
   
    
    
    
    //Section 5
    @IBOutlet weak var lblLastNameToRed: UILabel!
    @IBOutlet weak var lblFirstNameToRed: UILabel!
    @IBOutlet weak var lblCellNumberToRed: UILabel!
    @IBOutlet weak var lblEmailToRed: UILabel!
    
    //Section 6
    @IBOutlet weak var lblContactLastName: UILabel!
    @IBOutlet weak var lblContactFirstName: UILabel!
    @IBOutlet weak var lblContactCell: UILabel!
    @IBOutlet weak var lblContactEmail: UILabel!
    @IBOutlet weak var lblContactRelationshipToSingle: UILabel!
   
    
    var ref: DatabaseReference!
    var image: UIImage?
    var selectedSingle: NasiGirl!
    
    // New model object sent from
    // Research list VC
    var selectedNasiGirl: NasiGirl!
   
    var isAlreadyInResearchList: Bool = false
    var isAlreadyInSentList: Bool = false
    
    
    var favChildArr = [[String : String]]()
    var childAutoIDKeyInResearchList : String?
    var fromProject = false
    var tableName = ""
    var childKey = ""
    var currentSingleID: String!
    
    // ----------------------------------
 
    @IBOutlet weak var profileProjectStatusLabel: UILabel!
    @IBOutlet weak var saveToResearchButton: UIButton!
    
    
    @IBOutlet weak var zoomScrollView: UIScrollView!
    
    
    // MARK: - View Loading -
     //
     override func viewDidLoad() {
         super.viewDidLoad()
        
        zoomScrollView.minimumZoomScale = 1.0
        zoomScrollView.maximumZoomScale = 4.0
        zoomScrollView.zoomScale = 1.0
        zoomScrollView.delegate = self
        
        
    
    headlineLabel.text = selectedNasiGirl.nameSheIsCalledOrKnownBy + " " + selectedNasiGirl.lastNameOfGirl + " Profile Details"
        
    // get the note for this user-this girl
         self.getFavUserNote()
        
        // self.getPrevImages()
   // Hide keyboard
    let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                        action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
         tableView.addGestureRecognizer(gestureRecognizer)
         
         
         self.setUpProfilePhoto()
         self.setUpFirstSection()
         self.setUpSecondSection()
         self.setUpThirdSection()
         self.setUpForthSection()
         self.setUpFifthSection()
        
         //self.addTapGestureInImg()
         //self.btnCamera.isHidden = true
        headlineImageView.layer.cornerRadius = 8.0
        headlineImageView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setStatusLabelAndSaveToResearchButton()
        
        // check if in sent list - if in list set flag
        // update the button tile and label text
        checkSentList()
               
        // check if already in research list
        // set the flag = update the UI -
        checkResearchListAndStoreAutoIDKey()
    }
    
    
    // check if currentGirl's UID
    // already is in the sent list
    func checkSentList() {
        guard let myId = UserInfo.curentUser?.id else {
             return
         }
        
         // go to the current user's node in
         // sent list
        let  sentRef = Database.database().reference(withPath: "sentsegment")
         let userResearchRef = sentRef.child(myId)
        
         // observe all the children for this user
         userResearchRef.observe(.value, with: { snapshot in
            
           // iterate using the .children property
           for child in snapshot.children {
                               
             let snapshot = child as? DataSnapshot
             let value = snapshot?.value as? [String: AnyObject]
             let girlID = value!["userId"] as! String
            
            // get the currentSingleID instance var and cast to string
            let currentGirlID = "\(self.selectedNasiGirl.key)"
            
            // check if there is a match
            if girlID == currentGirlID {
                
                // set the flag on current profile to true
                self.isAlreadyInSentList = true
                
                // invoke the function that takes the bool value
                // and tells the user what list current girl is in
                self.setStatusLabelAndSaveToResearchButton()
                }
             }
         })
      }
    
    
     func checkResearchListAndStoreAutoIDKey() {
        
        guard let myId = UserInfo.curentUser?.id else {
            return
        }
        let  researchRef = Database.database().reference(withPath: "research")
        
        let userResearchRef = researchRef.child(myId)
        
            userResearchRef.observe(.value, with: { snapshot in
                
             for child in snapshot.children {
                    
                let snapshot = child as? DataSnapshot
                let value = snapshot?.value as? [String: AnyObject]
                
                print("the value of snapshot is\(snapshot) and value is \(snapshot?.value)")
                
                let girlID = value!["userId"] as! String
                let currentGirlID = self.selectedNasiGirl.key
                
                  if girlID == currentGirlID {
                        
                      self.isAlreadyInResearchList = true
                    
                      // if girl is in research list we save
                      // its autoID within the research list
                      self.childAutoIDKeyInResearchList = snapshot!.key
                      self.setStatusLabelAndSaveToResearchButton()
                }
             }
          })
    }
    
    // if no we add it
    @IBAction func saveToResearchTapped(_ sender: Any) {
        
        // only save to research if she is not in sent list and not
        // already in research
        if isAlreadyInResearchList == false && isAlreadyInSentList == false {
            saveProfileToResearchList()
        }
     }
    
    // manages the status label and save button's
    // appearance
    // if save is not allowed it hides the button
    func setStatusLabelAndSaveToResearchButton() {
        
        if isAlreadyInResearchList == true && isAlreadyInSentList == false {
           
            profileProjectStatusLabel.text = "Already saved In Research List"
            profileProjectStatusLabel.isHidden = false
            profileProjectStatusLabel.textColor = .lightGray
            
            saveToResearchButton.isHidden = true
            saveToResearchButton.isEnabled = false
            saveToResearchButton.backgroundColor = .white
            saveToResearchButton.setTitleColor(.lightGray, for: .disabled)
            saveToResearchButton.setTitle("Already saved In Research List", for: .disabled)
        }
        
        if isAlreadyInSentList == true && isAlreadyInResearchList == false {
            
            profileProjectStatusLabel.isHidden = false
            profileProjectStatusLabel.text = "Already saved in Sent List"
            profileProjectStatusLabel.textColor = .lightGray
            
            saveToResearchButton.isHidden = true
            saveToResearchButton.isEnabled = false
            saveToResearchButton.backgroundColor = .white
            saveToResearchButton.setTitleColor(.lightGray, for: .disabled)
             saveToResearchButton.setTitle("Already saved in Sent List", for: .disabled)
        }
        
        if isAlreadyInResearchList == false && isAlreadyInSentList == false {
           
            profileProjectStatusLabel.text = "Not saved to any list yet"
            saveToResearchButton.isEnabled = true
            saveToResearchButton.backgroundColor = .white
            
        }
    }

    func saveProfileToResearchList() {
        
        if isAlreadyInResearchList {
            return
        }
        
        ref = Database.database().reference()
        guard let myId = UserInfo.curentUser?.id else {
            return
        }
        
        let dict = ["userId" : selectedNasiGirl.key]
        
        ref.child("research").child(myId).childByAutoId().setValue(dict) {
            (error, ref) in
            
          if error != nil {
                //print(error?.localizedDescription ?? “”)
           } else {
            
           self.isAlreadyInResearchList = true
           self.setStatusLabelAndSaveToResearchButton()
           }
        }
    }
        
        
        

    // ----------------------------------
    // MARK: - Status Bar Style -
    //
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    /*
    // ----------------------------------
    // MARK: - PRIVATE METHOD(S) -
    //
    func showActionSheet() {
        let alert = UIAlertController(title: "Nasi", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Would you like to save to my projects", style: .default , handler:{ (UIAlertAction)in
            //self.saveToResearch()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
            self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    */

    //TODO: Initialize Data
    private func setUpProfilePhoto() {
        let selectedSingle = selectedNasiGirl
        
        
        headlineImageView.loadImageFromUrl(strUrl: selectedNasiGirl.imageDownloadURLString, imgPlaceHolder: "")
       //headlineImageView.loadImageUsingCacheWithUrlString(selectedNasiGirl.imageDownloadURLString)
        
        lblFullName?.text =  "\(selectedSingle?.firstNameOfGirl ?? "")" + " "  + "\(selectedSingle?.lastNameOfGirl ?? "")" //top 1 name
        
        
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        notesTextView.layer.borderWidth = 1.0
        notesTextView.layer.cornerRadius = 5.0
        
        notesTextView.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
        //vwBgForAddPhoto.addRoundedViewCorners(width: 12, colorBorder: .lightGray)
        
        //let gestureRecognizer = UITapGestureRecognizer(target: self,
         //                                              action: #selector(openGalleryPicker))
       // gestureRecognizer.cancelsTouchesInView = false
        //vwBgForAddPhoto.addGestureRecognizer(gestureRecognizer)
    }
    
    //TODO: SetUp Data For Girls name Section
    private func setUpFirstSection() {
        let selectedSingle = selectedNasiGirl
        lblFirstName?.text = selectedSingle?.firstNameOfGirl ?? ""
        lblMiddleName.text = selectedSingle?.middleNameOfGirl ?? ""
        lblLastName.text = selectedSingle?.lastNameOfGirl ?? ""
        
        
        lblName.text = selectedSingle!.nameSheIsCalledOrKnownBy  + " " + selectedSingle!.lastNameOfGirl
        
        
    }
    
    //TODO: SetUp Data For Girls details Section
    private func setUpSecondSection() {
        let  selectedSingle = selectedNasiGirl
        
        //lblDob?.text = "\(selectedSingle.dateOfBirth ?? 0.0)"
        lblFamilySituation.text = selectedSingle?.girlFamilySituation ?? ""
        //lblYearItOccurred.text = selectedSingle.yearsOfLearning ?? ""
        lblGirlsCellNumber.text = selectedSingle?.girlsCellNumber ?? ""
        
        lblCity.text = selectedSingle?.cityOfResidence ?? ""
        lblState.text = selectedSingle?.stateOfResidence ?? ""
        lblZip.text = selectedSingle?.zipCode ?? ""
        
        let heightInFt = selectedSingle?.heightInFeet ?? ""
        let heightInInches = selectedSingle?.heightInInches ?? ""
        let height = "\(heightInFt)\'" + "\(heightInInches)\""
        lblHeightft.text = height
        
    }
    
    //TODO: SetUp Data For Shidduch details Section
    private func setUpThirdSection() {
        let  selectedSingle = selectedNasiGirl
        lblSeminary?.text = "\(selectedSingle?.seminaryName ?? "")"
        lookingForTextView?.text = "\(selectedSingle?.briefDescriptionOfWhatGirlIsLookingFor ?? "")"
        
        whatsSheLikeLabel.text =
       "\(selectedSingle?.briefDescriptionOfWhatGirlIsLike ?? "")"
        lblPlan?.text = "\(selectedSingle?.plan ?? "")"
        lblDob.text = "\(selectedSingle!.age)"
        lblLivingInIsrael?.text = "\(selectedSingle?.livingInIsrael ?? "")"
        lblFamilyBg?.text = "\(selectedSingle?.girlFamilyBackground ?? "")"
        //whatIsSheDoingLabel.text = "\(selectedSingle?.briefDescriptionOfWhatGirlIsDoing ?? "")"
    }
    
    //TODO: SetUp Data For To redd a shidduch Section
    private func setUpForthSection() {
        
        let  selectedSingle = selectedNasiGirl
        lblLastNameToRed?.text = "\(selectedSingle?.lastNameOfPersonToContactToReddShidduch ?? "")"
        lblFirstNameToRed?.text = "\(selectedSingle?.firstNameOfPersonToContactToReddShidduch ?? "")"
        lblCellNumberToRed.text = selectedSingle?.cellNumberOfContactToReddShidduch ?? ""
        lblEmailToRed.text = selectedSingle?.emailOfContactToReddShidduch
    }
    
    //TODO: SetUp Data For To discuss a shidduch Section
    private func setUpFifthSection() {
        let  selectedSingle = selectedNasiGirl
        
        lblContactLastName?.text = "\(selectedSingle?.lastNameOfAContactWhoKnowsGirl ?? "")"
        lblContactFirstName?.text = "\(selectedSingle?.firstNameOfAContactWhoKnowsGirl ?? "")"
        lblContactCell.text = selectedSingle?.cellNumberOfContactWhoKNowsGirl ?? ""
        lblContactEmail.text = selectedSingle?.emailOfContactWhoKnowsGirl ?? ""
        lblContactRelationshipToSingle.text = selectedSingle?.relationshipOfThisContactToGirl ?? ""
    }
    
    /*
    private func addTapGestureInImg() {
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(openImageView))
        //imgVwAddMore.isUserInteractionEnabled = true
        //imgVwAddMore.addGestureRecognizer(gestureRecognizer)
    }
  */
    
    /*
    @objc func openImageView(tapGestureRecognizer: UITapGestureRecognizer) {
        self.openMediaViewer(selectedIndex: 0)
    }
    
    
    @objc func openGalleryPicker(_ gestureRecognizer: UIGestureRecognizer) {
        self.showPhotoMenu()
    }
    
    */
    
    @objc func doneButtonClicked(_ sender: Any) {
        
         
        
        //if notesTextView.text.isEmpty {
         //   self.showAlert(title: Constant.ValidationMessages.oopsTitle, msg: Constant.ValidationMessages.msgNotesEmpty)
         //   }
            
         //else {
            
        
            self.view.showLoadingIndicator()
            // make sure you have userID, girlsID, and text for note
            
            let myId = UserInfo.curentUser?.id
        
            // get the UUID for the current Girl
            // by her key property
            let selectedSingle = selectedNasiGirl
            
            let gId = selectedSingle!.key
            let note = notesTextView.text
                
            // dictionary for note
            let dict = ["note":note]
            
            ref = Database.database().reference()
            
        // go to notes list - then to current user - then to current
        // girl's UUID
        // set girls UUID as the node and set dictionary of notes under
        ref.child("favUserNotes").child(myId!).child(gId).setValue(dict) {
                
                (error, dbRef) in
                
                if error != nil {
                    print( error?.localizedDescription ?? "")
                    
                    self.view.hideLoadingIndicator()
                
                } else {
                    
                    //print("success")
                    //print(dbRef.key ?? "dbKey")
                    
                    self.view.hideLoadingIndicator()
                    //self.saveProfileToResearchList()
                    
                }
            }
        }
        
    
    
    func getFavUserNote() {
    
      let myId = UserInfo.curentUser?.id
        let selectedSingle = selectedNasiGirl
        
        
        print("the state of selectedNasiGirl is \(selectedNasiGirl.debugDescription)\(selectedNasiGirl.briefDescriptionOfWhatGirlIsLike)and her key is\(selectedNasiGirl.key)and ref is\(selectedNasiGirl.ref)")
        
        
        
        
        
                  
        let gID = selectedSingle!.key
        
      //let gID = selectedNasiGirl.key
          
        ref = Database.database().reference()
        
        // go to the list of user notes
        // 1. go to user id
        // go to girl id
        // get all the
        ref.child("favUserNotes").child(myId!).child(gID).observe(.childAdded) { (snapShot) in
            if let noteStr = snapShot.value as? String {
                //print("notes txt :- \(noteStr)")
                self.notesTextView.text = noteStr
               // self.isAlreadyAddedNotes = true
                
            }else{
                
                print("invalid data")
            }
            print("user notes :-")
        }
    }
    
    /*
    
    func getPrevImages() {
        guard
            let myId = UserInfo.curentUser?.id,
            let gID = currentSingleID
            else {
                print("data nil")
                return
        }
        ref = Database.database().reference()
        ref.child("favUserPhotos").child(myId).child(gID).observe(.childAdded) { (snapShot) in
            if let snap = snapShot.value as? String {
                print("imgUrl :- \(snap)")
                //self.imgVwAddMore.isHidden = false
                //self.imgPlusIcn.isHidden = true
               // self.lblAddMore.isHidden = true
               //self.btnCamera.isHidden = false
               // self.imgVwAddMore.loadImageFromUrl(strUrl: String(format: "%@",snap), imgPlaceHolder: "placeholder")
            }else{
                print("invalid data")
            }
            print("user notes :-")
        }
        
        ref.child("favUserPhotos").child(myId).child(gID).observe(.childChanged) { (snapShot) in
            if let snap = snapShot.value as? String {
                print("imgUrl :- \(snap)")
            }else{
                print("invalid data")
            }
            print("user notes :-")
        }
        
    }
  */
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        
        let point = gestureRecognizer.location(in: tableView)
        
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && indexPath!.section == 2
            && indexPath!.row == 0 {
            return
        }
        notesTextView.resignFirstResponder()
    }
    
   
    
    // MARK: - Navigation
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           
         if segue.identifier == "ShowResumeVC" {
             
            let controller = segue.destination as? ResumeViewController 
            controller!.selectedNasiGirl =  selectedNasiGirl
            controller?.isAlreadyInSent = isAlreadyInSentList
            controller?.isAddedInResearch = isAlreadyInResearchList
            
         } else if segue.identifier == "ShowViewResumeVC" {
            let controller = segue.destination as? ViewResumeVCViewController
            controller!.selectedNasiGirl =  selectedNasiGirl
        }
       }
    
func show(image: UIImage) {
        imgVwAddMore.image = image
        imgVwAddMore.isHidden = false
        imgPlusIcn.isHidden = true
        lblAddMore.isHidden = true
        tableView.reloadData()
    }
    
    /*
    @IBAction func remveAction(_ sender: Any) {
        print("removed")
        var message = ""

        if tableName == "research" {
                     message =  Constant.ValidationMessages.msgConfirmationToDelete
                 }else {
                     message =  Constant.ValidationMessages.msgConfirmationToDeleteSent

                 }
        
        let alertControler = UIAlertController.init(title:"", message: message, preferredStyle:.alert)
        alertControler.addAction(UIAlertAction.init(title:"Yes", style:.default, handler: { (action) in
            print("yes")
            self.removeFromProject()
        }))
                
        alertControler.addAction(UIAlertAction.init(title:"No", style:.destructive, handler: { (action) in
                     print("no")
               
        }))
                
        self.present(alertControler,animated:true, completion:nil)
        
    }
    */
  
    /*
    fileprivate func removeFromProject() {
        
       // print("here is my child key", strChildKey!)
       // print("here is custom child key", childKey)

        
        ref = Database.database().reference()
        let myId = UserInfo.curentUser?.id
        
        ref.child(tableName).child(myId!).child(childKey).removeValue { (error, dbRef) in // childKey
            self.view.hideLoadingIndicator()
            if error != nil{
                print(error?.localizedDescription)
            } else {
                print(dbRef.key)
               if self.tableName == "research" {
                
                    NotificationCenter.default.post(name: Constant.EventNotifications.notifRemoveFromFav, object: ["updateStatus":"researchList"])
                self.showAlert(title: Constant.ValidationMessages.successTitle, msg: Constant.ValidationMessages.msgSuccessToDelete) {
                                   self.navigationController?.popViewController(animated: true)
                               }
                } else {
                
                    NotificationCenter.default.post(name: Constant.EventNotifications.notifRemoveFromFav, object: ["updateStatus":"sentList"])
                self.showAlert(title: Constant.ValidationMessages.successTitle, msg: Constant.ValidationMessages.msgSuccessToDeleteFromSent) {
                                   self.navigationController?.popViewController(animated: true)
                               }
                }
            }
        }
    }
  */
    
    
    @IBAction func viewResumeTapped(_ sender: Any) {
        
        print("need to present resume")
    }
    
    
    
  }
// ----------------------------------
 // MARK: - Button Action() -
 //
 extension ShadchanListDetailViewController {

    @IBAction func btnCameraTapped(_ sender: Any) {
        self.showPhotoMenu()
    }
    
 }
 
 // ----------------------------------
 // MARK: - TableView Delegate(S) -
 //
 extension ShadchanListDetailViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("the selected indexpath is \(indexPath)")
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 && indexPath.row == 3 {
        Utility.makeACall(selectedNasiGirl.girlsCellNumber)
        }
    
        if indexPath.section == 4 && indexPath.row == 2 {
        Utility.makeACall(selectedNasiGirl.cellNumberOfContactToReddShidduch)
     }
        
    if indexPath.section == 4 && indexPath.row == 3 {
        if MFMailComposeViewController.canSendMail() {
        sendEmail(selectedNasiGirl.emailOfContactToReddShidduch)
        }
    }
            //        } else {
                //        self.showAlert(title: Constant.ValidationMessages.oopsTitle, msg: Constant.ValidationMessages.mailUnableToSend) {
                   //     }
                 //   }
                
           //}
  if indexPath.section == 5 && indexPath.row == 2 {
    Utility.makeACall(selectedNasiGirl.cellNumberOfContactWhoKNowsGirl)
    
    
    
   }
    if indexPath.section == 5 && indexPath.row == 3 {
                
    if MFMailComposeViewController.canSendMail() {
        sendEmail(selectedNasiGirl.emailOfContactWhoKnowsGirl)
        }
        }
    
      // else {
       //     self.showAlert(title: Constant.ValidationMessages.oopsTitle, msg: Constant.ValidationMessages.mailUnableToSend) {
                }}
                    
                
           // }
       // }
   // }
    
    /*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 || indexPath.section == 2  || indexPath.section == 3 || indexPath.section == 4  || indexPath.section == 5 {
            return UITableView.automaticDimension
        } else if indexPath.section == 8 {
            return 60
        } else if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 225
            } else if indexPath.row == 1 {
                return 60
            } else if indexPath.row == 2 {
                return 160
            } else if indexPath.row == 3 {
                return 170
            } else if indexPath.row == 4 || indexPath.row == 5 {
                //return 100
                return 0
            }
        }else if indexPath.section == 6 {
            if fromProject {
                return UITableView.automaticDimension
            }else {
                return 0.1
            }
        }
        return UITableView.automaticDimension
    }
  */
 
 extension ShadchanListDetailViewController {
    override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return headlineImageView
    }
 }
 // ----------------------------------
 // MARK: - UIImagePickerControllerDelegate -
 //
 extension ShadchanListDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        if let theImage = image {
            show(image: theImage)
            
            self.uploadImage(theImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraDevice = .front
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            self.showAlert(title: "Warning", msg: "You don't have camera", onDismiss: {
            })
        }
        /*
         let imagePicker = UIImagePickerController()
         imagePicker.sourceType = .camera
         imagePicker.delegate = self
         imagePicker.allowsEditing = true
         present(imagePicker, animated: true, completion: nil)
         */
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func pickPhoto() {
        if true || UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        
        let actPhoto = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.takePhotoWithCamera()
        })
        alert.addAction(actPhoto)
        
        let actLibrary = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
            self.choosePhotoFromLibrary()
        })
        alert.addAction(actLibrary)
        
        present(alert, animated: true, completion: nil)
    }
    
    func uploadImage(_ img : UIImage) {
        uploadMedia(img) { (imgUrl) in
            
            let myId = UserInfo.curentUser?.id
            let gId = self.selectedSingle.key
            let iUrl = imgUrl
             
            let dict = ["imgUrl":iUrl]
            self.ref = Database.database().reference()
            self.ref.child("favUserPhotos").child(myId!).child(gId).setValue(dict) { (error, dbRef) in
                if error != nil {
                    print( error?.localizedDescription ?? "")
                }else{
                    print("success")
                    print(dbRef.key ?? "dbKey")
                }
            }
        }
    }
    
    func uploadMedia(_ image : UIImage, completion: @escaping (_ url: String?) -> Void) {
        let storageRef = Storage.storage().reference()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let str = df.string(from: Date())
        let riversRef = storageRef.child("images/Image_\(str).jpg")
        guard let uploadData = image.jpegData(compressionQuality: 0.25) else{
            print("image can’t be converted to data")
            return
        }
        self.view.showLoadingIndicator()
        let uploadTask = riversRef.putData(uploadData, metadata: nil) { (metadata, error) in
            self.view.hideLoadingIndicator()
            guard metadata != nil else {
                // Uh-oh, an error occurred!
                print(error?.localizedDescription ?? "")
                return
            }
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                print("d1-\(downloadURL)")
                completion("\(downloadURL)")
            }
        }
        _ = uploadTask.observe(.progress) { snapshot in
            // A progress event occurred
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print("progress- \(percentComplete)")
        }
    }
 }
 
 extension ShadchanListDetailViewController {
    func openMediaViewer(selectedIndex: Int) {
        var imageInfo = [LightboxImage]()
        imageInfo.removeAll()
        if imgVwAddMore.image != nil {
            imageInfo.append(LightboxImage(image: imgVwAddMore.image!))
        }
        let controller = LightboxController(images: imageInfo, startIndex: selectedIndex)
        controller.dynamicBackground = true
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
 }
 
 // MARK:- MFMailCompose ViewController Delegate
 extension ShadchanListDetailViewController : MFMailComposeViewControllerDelegate {
    
    // MARK: Open MailComposer
    func sendEmail(_ emailRecipients:String) {
        let vcMailCompose = MFMailComposeViewController()
        vcMailCompose.mailComposeDelegate = self
        vcMailCompose.setToRecipients([emailRecipients])
        let subject =  "\("Resume")" + " "  + "\(selectedNasiGirl.firstNameOfGirl )" + " "  + "\(selectedNasiGirl.lastNameOfGirl )" //top 1 name
        vcMailCompose.setSubject(subject)
        let strMailBody = "Please type your question here:\n\n\n"
        vcMailCompose.setMessageBody(strMailBody, isHTML: false)
        self.present(vcMailCompose, animated: true) {}
    }
    
    // MARK: MailComposer Delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            switch result {
            case .sent:
                self.showAlert(title: Constant.ValidationMessages.successTitle, msg:Constant.ValidationMessages.mailSentSuccessfully, onDismiss: {})
            case .saved:
                self.showAlert(title: Constant.ValidationMessages.successTitle, msg:Constant.ValidationMessages.mailSavedSuccessfully, onDismiss: {})
            case .failed:
                self.showAlert(title: Constant.ValidationMessages.oopsTitle, msg:Constant.ValidationMessages.mailFailed, onDismiss: {})
            default: break
            }
        }
    }
 }
