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
    @IBOutlet weak var difficultyPickerView: UIPickerView!
    
    fileprivate let _difficulties = ["Easy", "Normal", "Hard", "Hardest"]
    fileprivate var _selectedDifficultyIndex = 1
    
    override func viewWillAppear(_ animated: Bool) {
        soundEnabledSwitch.isOn = !UserDefaults.standard.bool(forKey: Constants.Settings.muteSounds)
        loadDifficultyLevel()
    }
    
    @IBAction func soundEnabledSwitchChanged(_ sender: UISwitch) {
        let muteSounds = !soundEnabledSwitch.isOn
        UserDefaults.standard.set(muteSounds, forKey: Constants.Settings.muteSounds)
        Analytics.logEvent(Constants.FirebaseEvents.soundToggled, parameters: ["newValue": NSNumber(value: muteSounds)])
    }
    
    @IBAction func applyDifficultyBtnTapped(_ sender: Any) {
        saveDifficultyLevel()
        showAlert(title: "Difficulty updated!", message: "The difficulty has been set to \(_difficulties[_selectedDifficultyIndex]). It will be updated when you start a new game.\n\nGood luck!", confirmBtnTitle: "Okay", completion: nil)
    }
    
    // MARK: - Private functions
    
    private func loadDifficultyLevel() {
        _selectedDifficultyIndex = getDifficultyIndex()
        difficultyPickerView.selectRow(_selectedDifficultyIndex, inComponent: 0, animated: false)
    }
    
    private func getDifficultyIndex() -> Int {
        let difficulty = UserDefaults.standard.object(forKey: Constants.Settings.difficulty)
        
        if(difficulty == nil) {
            return Difficulty.Normal.rawValue - 1
        } else {
            return difficulty as! Int - 1
        }
    }
    
    private func saveDifficultyLevel() {
        UserDefaults.standard.set(_selectedDifficultyIndex+1, forKey: Constants.Settings.difficulty)
        UserDefaults.standard.synchronize()
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        _selectedDifficultyIndex = row
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
