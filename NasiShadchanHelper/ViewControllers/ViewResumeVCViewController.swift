//
//  ViewResumeVCViewController.swift
//  NasiShadchanHelper
//
//  Created by username on 1/11/21.
//  Copyright © 2021 user. All rights reserved.
//

import UIKit
import PDFKit

class ViewResumeVCViewController: UIViewController {

    var selectedNasiGirl: NasiGirl!
    
    var localURL: URL!
    var localImageURL: URL!
    
   
  
    @IBOutlet weak var waitingForDataLabel: UILabel!
      @IBOutlet weak var pdfView: PDFView!
    
    // set up url session for download
    // so we get delegate call backs
    lazy var downloadsSession: URLSession = {
      let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration,
                             delegate: self,
                             delegateQueue: nil)
      }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    self.view.showLoadingIndicator()
        
        //saveToResearchButton.isHidden = true
       // saveToResearchButton.isEnabled = false
       // saveToResearchButton.backgroundColor = .white
       // saveToResearchButton.setTitleColor(.lightGray, for: .disabled)
        // saveToResearchButton.setTitle("Already saved in Sent List", for: .disabled)
        

        downloadDocument()
        waitingForDataLabel.isHidden = false 
       
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
       
  
    
    
    @IBAction func dismissViewResumeTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /// Get local file path: download task stores tune here; AV player plays it.
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

}

extension ViewResumeVCViewController: URLSessionDownloadDelegate {
    
    
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
    
  func downloadDocument() {
      
   
      let documentURL = URL(string: selectedNasiGirl.documentDownloadURLString )
      
    let downloadTask = downloadsSession.downloadTask(with: documentURL!)
      
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
          
       }
       
        
           if localURL != nil  {
       DispatchQueue.main.async {
           self.waitingForDataLabel.isHidden = true
            self.setUpPDFView()
           
               }
        }
       
      }
       
    
    
    
    
    
}
