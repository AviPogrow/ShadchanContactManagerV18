//
//  MainResumeVC.swift
//  NasiShadchanHelper
//
//  Created by apple on 16/11/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit
import PDFKit
import Firebase
import MessageUI

class ResumeViewController: UITableViewController {
    
   
    var selectedNasiGirl: NasiGirl!
    
    // Section 1
    @IBOutlet weak var imgVwUserDP: UIImageView!
    @IBOutlet weak var btnShareResumeOnly: UIButton!
    @IBOutlet weak var btnShareResumeAndPhoto: UIButton!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var lblNoResume: UILabel!
    
    
    @IBOutlet weak var waitingForDataLabel: UILabel!
    
    // set up url session for download
    // so we get delegate call backs
    lazy var downloadsSession: URLSession = {
      let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration,
                             delegate: self,
                             delegateQueue: nil)
      }()
    
    
    var localURL: URL!
    var localImageURL: URL!

    var ref: DatabaseReference!
    var sentSegmentChildArr = [[String : String]]()
    
    // function get sent resume list
    // sets this flag
    var isAlreadyInSent:Bool = false
    var isAddedInResearch:Bool = false
    
    var childAutoIDKeyInResearchList : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        checkSentList()
        downloadDocument()
        downloadProfileImage()
        
        btnShareResumeOnly.addRoundedViewCorners(width: 4, colorBorder: Constant.AppColor.colorAppTheme)
    
        
        btnShareResumeAndPhoto.addRoundedViewCorners(width: 4, colorBorder: Constant.AppColor.colorAppTheme)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       
    }
    
    
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
                   self.isAlreadyInSent = true
                   
                   // invoke the function that takes the bool value
                   // and tells the user what list current girl is in
                  // self.setStatusLabelAndSaveToResearchButton()
                   }
                }
            })
         }
    
    // invoked by completion handler when send is success
    //
    func checkStatusBeforeSavingToSent() {
        
        let hudView = HudView.hud(inView: self.navigationController!.view, animated: true)
        //hudView.text = "Checking Profile Status"

         afterDelay(1.9) {
         hudView.hide()
         
         self.navigationController?.popToRootViewController(animated: true)
            
         }
        
        
        if isAddedInResearch == false  && isAlreadyInSent == true {
            
             hudView.text = "Already In Sent List"
            
        } else if isAddedInResearch == false && isAlreadyInSent == false {
           
            hudView.text = "Adding To Sent List"
            saveToSentSegmentAndUpdateHud(hudView: hudView)
            
        } else if isAddedInResearch == true && isAlreadyInSent == false {
            print("we need  to delete from research list and add to sent list")
            
            
            hudView.text = "Moving From Research List To Sent List"
            
          checkResearchListAndStoreAutoIDKey()
            //removeFromResearchList()
            
            saveToSentSegmentAndUpdateHud(hudView: hudView)
        }
    }
    
    
    private func setUpProfilePhoto() {
         //imgVwUserDP.loadImageUsingCacheWithUrlString(selectedNasiGirl.imageDownloadURLString)
        imgVwUserDP.loadImageFromUrl(strUrl: selectedNasiGirl.imageDownloadURLString, imgPlaceHolder: "")
        
       
    }
    
    func shareResumeAndPhoto() {
            
        if localURL != nil && localImageURL != nil {
        btnShareResumeOnly.isEnabled = true
        btnShareResumeAndPhoto.isEnabled = true
        
          
           // 3 sharing items
           // 1 Resume pdf as UIImage
           let documentAsImage = drawPDFfromURL(url: localURL)
        _ = documentAsImage?.jpegData(compressionQuality: 0.50)
           
           // 2 profile image
           let shareImageURL = localImageURL!
           let imageData = try! Data(contentsOf: shareImageURL)
           let imageToShare = UIImage(data: imageData)
           
           // 3 text string
        var textMessageString: String = ""
        
             textMessageString = "This is the resume of " +
                "\(selectedNasiGirl.nameSheIsCalledOrKnownBy) " +
            "\(selectedNasiGirl.lastNameOfGirl)"
        
        let activityVC =  UIActivityViewController(activityItems: [documentAsImage!,imageToShare!,textMessageString], applicationActivities: [])
            
            activityVC.popoverPresentationController?.sourceView = btnShareResumeAndPhoto
                   //activityVC.popoverPresentationController?.barButtonItem = sender
           
           activityVC.excludedActivityTypes = [
               UIActivity.ActivityType.postToWeibo,
               UIActivity.ActivityType.print,
               UIActivity.ActivityType.copyToPasteboard,
               UIActivity.ActivityType.assignToContact,
               UIActivity.ActivityType.saveToCameraRoll,
               UIActivity.ActivityType.addToReadingList,
               UIActivity.ActivityType.postToFlickr,
               UIActivity.ActivityType.postToVimeo,
               UIActivity.ActivityType.postToTencentWeibo,
               UIActivity.ActivityType.airDrop,
               UIActivity.ActivityType.openInIBooks,
               UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
               UIActivity.ActivityType(rawValue: "com.apple.reminders.sharingextension")
           ]
           
           //Completion handler
           activityVC.completionWithItemsHandler = {
               (activityType: UIActivity.ActivityType?, completed:
                      Bool, arrayReturnedItems: [Any]?, error: Error?) in
               print("********completion invoked handler***")
               print("the activity type was\(activityType.debugDescription)completed is \(completed) array returned items is \(arrayReturnedItems.debugDescription) and error is \(error.debugDescription)")
               
               if completed {
                   print("*****User completed activity****")
                
                self.checkStatusBeforeSavingToSent()
                
                   } else {
                   print("user cancelled the activityController")
                   }
                   if let shareError = error {
                       print("error while sharing: \(shareError.localizedDescription)")
                          }
                      }
            
           //'UIPopoverPresentationController (<UIPopoverPresentationController: 0x7fe1dfc65d00>) should have a non-nil sourceView or barButtonItem set before the presentation occurs.'
               
           //activityVC.popoverPresentationController?.sourceView = self.view
          // activityVC.popoverPresentationController?.sourceRect = self.view.bounds
             present(activityVC, animated: true, completion: nil)
        }
       }
    
   
    
    
    
    func shareResumeOnly() {
        
        
        if localURL != nil && localImageURL != nil {
            
        btnShareResumeOnly.isEnabled = true
        btnShareResumeAndPhoto.isEnabled = true
    
       let documentAsImage = drawPDFfromURL(url: localURL)
        
        let textMessageString = "This is the resume of " +
                    "\(selectedNasiGirl.nameSheIsCalledOrKnownBy) " +
                "\(selectedNasiGirl.lastNameOfGirl)"
            
       
        let activityVC = UIActivityViewController(activityItems: [textMessageString, documentAsImage!], applicationActivities: [])
            
      
              
        activityVC.popoverPresentationController?.sourceView = btnShareResumeOnly
        //activityVC.popoverPresentationController?.barButtonItem = sender
        
        activityVC.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.openInIBooks,
            UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
            UIActivity.ActivityType(rawValue: "com.apple.reminders.sharingextension")
        ]
        
        //Completion handler
        activityVC.completionWithItemsHandler = {
            (activityType: UIActivity.ActivityType?, completed:
                   Bool, arrayReturnedItems: [Any]?, error: Error?) in
            print("***completion invoked handler***")
            if completed {
                print("*****User completed activity")
                    
                self.checkStatusBeforeSavingToSent()
                
                
                
                
                } else {
                print("user cancelled the activityController")
                }
                if let shareError = error {
                    print("error while sharing: \(shareError.localizedDescription)")
                       }
                   }
        //'UIPopoverPresentationController (<UIPopoverPresentationController: 0x7fe1dfc65d00>) should have a non-nil sourceView or barButtonItem set before the presentation occurs.'
            
        //activityVC.popoverPresentationController?.sourceView = self.view
        //activityVC.popoverPresentationController?.sourceRect = self.view.bounds
        
        present(activityVC, animated: true, completion: nil)
        }
    }
    
    func drawPDFfromURL(url: URL) -> UIImage? {
           guard let document = CGPDFDocument(url as CFURL) else { return nil }
           guard let page = document.page(at: 1) else { return nil }

           let pageRect = page.getBoxRect(.mediaBox)
           let renderer = UIGraphicsImageRenderer(size: pageRect.size)
           let img = renderer.image { ctx in
               UIColor.white.set()
               ctx.fill(pageRect)

               ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
               ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

               ctx.cgContext.drawPDFPage(page)
           }

           return img
       }
   
    /// Get local file path: download task stores tune here; AV player plays it.
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

}
extension ResumeViewController: URLSessionDownloadDelegate {
  
    func downloadDocument() {
        view.showLoadingIndicator()
     
        let documentURL = URL(string: selectedNasiGirl.documentDownloadURLString )
        
      let downloadTask = downloadsSession.downloadTask(with: documentURL!)
        
      downloadTask.resume()
    
    }
    
    func downloadProfileImage() {

        let profileImageURL = URL(string: selectedNasiGirl.imageDownloadURLString )
        
        
      let downloadTask = downloadsSession.downloadTask(with: profileImageURL!)
     
      downloadTask.resume()
     
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL) {
      
      let originalURL = downloadTask.originalRequest!.url!
      let downloadType = downloadTask.originalRequest!.url!.pathExtension
    
      print("the download type is \(downloadType)")
      
        if downloadType == "pdf" {
         localURL = copyFromTempURLToLocalURL(remoteURL: originalURL, location: location)
          
      } else {
        localImageURL = copyFromTempURLToLocalURL(remoteURL: originalURL, location: location)
    }
    
     
        if localURL != nil && localImageURL != nil {
    DispatchQueue.main.async {
        self.waitingForDataLabel.isHidden = true
        self.setUpPDFView()
        self.setupProfileImageFromLocalURL()
            }
     }
    
   }
    
    func setUpPDFView() {
           
           var document: PDFDocument!
           
           if  let pathURL = localURL {
           document = PDFDocument(url: pathURL)
           }
           
           if let document = document {
               pdfView.displayMode = .singlePageContinuous
               pdfView.autoScales = true
               pdfView.displayDirection = .vertical
               pdfView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
               pdfView.document = document
           }
          self.view.hideLoadingIndicator()
       }
    
    func setupProfileImageFromLocalURL() {
         
           if localImageURL != nil {
           
           //let localImageURL = URL(string: localURLAsString)
           let imageData = try! Data(contentsOf: localImageURL!)
           
           let imageFromURl = UIImage(data: imageData)
           imgVwUserDP.image = imageFromURl
           }
       }
    
    
    func copyFromTempURLToLocalURL(remoteURL: URL, location: URL) -> URL {
      
        // 1 get the original url we used to download
        // the document from fire base storage
       //let sourceURL = URL(string: selectedSingle.documentDownloadURLString ?? "")!
        
        let sourceURL = remoteURL
       // 2 create a file path pointing to the local
       // document directory
       let destinationURL = localFilePath(for: sourceURL)
       print(destinationURL)
       
       // 3 get the default file manager
       let fileManager = FileManager.default
       
        // clear out the destination url in case something
        // is there
        try? fileManager.removeItem(at: destinationURL)

       do {
         try fileManager.copyItem(at: location, to: destinationURL)
         //download?.track.downloaded = true
       } catch let error {
         print("Could not copy file to disk: \(error.localizedDescription)")
       }

        return destinationURL
        
    }
    
    func localFilePath(for url: URL) -> URL {
         return documentsPath.appendingPathComponent(url.lastPathComponent)
       }


}



// ----------------------------------
// MARK: - BUTTION ACTION(S) -
//
extension ResumeViewController {
    @IBAction func btnShareResumeTapped(_ sender: Any) {
       self.shareResumeOnly()
        
    }
    
   
    
    @IBAction func btnShareResumePhotoTapped(_ sender: Any) {
        self.shareResumeAndPhoto()
        
        
      
    }
    
    func saveToSentSegmentAndUpdateHud(hudView: HudView) {
        if isAlreadyInSent {
            return
        }
        ref = Database.database().reference()
        guard let myId = UserInfo.curentUser?.id else {
            return
        }
        
        let timeStamp = Date()
        let timeStampString = "\(timeStamp)"
        let dict = ["userId" : selectedNasiGirl.key]
        ref.child("sentsegment").child(myId).childByAutoId().setValue(dict) {
            (error, ref) in
            
            if error != nil {
                //print(error?.localizedDescription ?? “”)
                
            } else {
                hudView.text = "Save Successful!"
                
            }
        }
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
                
                
                
                // get the id from the current snapshot child
                // using the key userId
                // and get the ID of the current girl in
                // the detail view
                let girlID = value!["userId"] as! String
                let currentGirlID = self.selectedNasiGirl.key
                
                print("the value of currentSingleId is \(currentGirlID) and girlId is \(girlID)")
                
                    if girlID == currentGirlID {
                        
                      // this snapshot has the autoIDKey of the
                      // profile in the research list specificly
                      self.childAutoIDKeyInResearchList = snapshot!.key
                        self.removeFromResearchList()
                        
                        //let refToRemoveFromResearch = snapshot?.ref
                       // refToRemoveFromResearch?.removeValue()
                      //self.setStatusLabelAndSaveToResearchButton()
                }
             }
          })
    }
    
    
    func removeFromResearchList() {
        
      guard let myId = UserInfo.curentUser?.id else {return}
          let researchRef = Database.database().reference(withPath: "research")
        
        let researchAutoIDKey = childAutoIDKeyInResearchList
        
        researchRef.child(myId).child(researchAutoIDKey!).removeValue {
             (error, dbRef) in
            
            if error != nil {
                
                print(error?.localizedDescription ?? "error")
                       
            } else {
                print("the dbRef isi \(dbRef.description())")
                
            }
        }
    }
}
        
    
   
   
   
