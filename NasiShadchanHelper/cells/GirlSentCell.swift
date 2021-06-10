//
//  GirlSentCell.swift
//  NasiShadchanHelper
//
//  Created by username on 12/17/20.
//  Copyright © 2020 user. All rights reserved.
//

import UIKit

class GirlSentCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ageCityLabel: UILabel!
     @IBOutlet weak var heightSeminaryLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    profileImageView.layer.cornerRadius = 8
                profileImageView.layer.masksToBounds = true
                profileImageView.contentMode = .scaleAspectFit
    }
    
    func configureCellFor(currentGirl: NasiGirl) {
        
        
       
        
        profileImageView.loadImageFromUrl(strUrl: currentGirl.imageDownloadURLString, imgPlaceHolder: "")
        
        
        //profileImageView.image = currentGirl.imageDownloadURLString
        
        
        let customFont = UIFont(name: "SBLHebrew", size: 18)
        //nameLabel.font = customFont
        nameLabel.textAlignment = .left
        
        nameLabel.text = currentGirl.nameSheIsCalledOrKnownBy + " " + currentGirl.lastNameOfGirl
        
        //ageCityLabel.font = customFont
        ageCityLabel.text = "\(currentGirl.age)" + " - " + "\(currentGirl.cityOfResidence)"
        
        //heightSeminaryLabel.font = customFont
        heightSeminaryLabel.text = currentGirl.heightInFeet + " Ft" + " " + currentGirl.heightInInches + " Inch" + " - " + currentGirl.seminaryName
        
        //categoryLabel.font = customFont
        categoryLabel.text = currentGirl.category
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

          // Initialization code
              let selection = UIView(frame: CGRect.zero)
              selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
              selectedBackgroundView = selection
              // Rounded corners for images
              //profileImageView.layer.cornerRadius = profileImageView.bounds.size.width / 2
              //profileImageView.clipsToBounds = true
    }

}
