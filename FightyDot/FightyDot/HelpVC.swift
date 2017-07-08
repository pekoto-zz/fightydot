//
//  HelpVC.swift
//  Ananke
//
//  Created by Graham McRobbie on 25/02/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import UIKit
import Firebase

class HelpVC: UIViewController {

    @IBOutlet weak var soundEnabledSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        soundEnabledSwitch.isOn = !UserDefaults.standard.bool(forKey: Constants.Settings.muteSounds)
    }
    
    @IBAction func soundEnabledSwitchChanged(_ sender: UISwitch) {
        let muteSounds = !soundEnabledSwitch.isOn
        UserDefaults.standard.set(muteSounds, forKey: Constants.Settings.muteSounds)
        Analytics.logEvent(Constants.FirebaseEvents.soundToggled, parameters: ["newValue": NSNumber(value: muteSounds)])
    }
}
