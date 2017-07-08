//
//  MainTabBarVC.swift
//  Ananke
//
//  Created by Graham McRobbie on 08/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//

import UIKit

class MainTabBarVC: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: Constants.FontNames.regular, size:10)!], for: .normal)
    }
    
}
