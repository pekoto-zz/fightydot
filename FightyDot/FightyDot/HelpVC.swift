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
    
    fileprivate let _difficulties = ["Easy", "Normal", "Hard", "Harder"]

    
    override func viewWillAppear(_ animated: Bool) {
        soundEnabledSwitch.isOn = !UserDefaults.standard.bool(forKey: Constants.Settings.muteSounds)
    }
    
    @IBAction func soundEnabledSwitchChanged(_ sender: UISwitch) {
        let muteSounds = !soundEnabledSwitch.isOn
        UserDefaults.standard.set(muteSounds, forKey: Constants.Settings.muteSounds)
        Analytics.logEvent(Constants.FirebaseEvents.soundToggled, parameters: ["newValue": NSNumber(value: muteSounds)])
    }
}

extension HelpVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return _difficulties[row]
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return _difficulties.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: Constants.FontNames.regular, size: 16)
                label.text = _difficulties[row]
        
        return label
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
