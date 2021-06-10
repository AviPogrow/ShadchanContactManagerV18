//
//  MyTabBarController.swift
//  NasiShadchanHelper
//
//  Created by username on 1/7/21.
//  Copyright © 2021 user. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
         self.delegate = self

        // Do any additional setup after loading the view.
    }
    
    
    //MARK:- UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("delegate method invoked")
        
        print("the viewController is \(viewController.description)and its stack  is\(viewController.children)  selectedINdex is\(tabBarController.selectedIndex)")
        
        
       // if (viewController is UINavigationController) {
       //     let navcontrollers = viewController as? UINavigationController
        //    navcontrollers?.popViewController(animated: true)
       // }
        
     }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
