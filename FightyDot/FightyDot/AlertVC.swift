//
//  AlertVC.swift
//  Ananke
//
//  Created by Graham McRobbie on 01/02/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//

import UIKit

class AlertVC: UIViewController {

    @IBOutlet weak var alertView: RoundedShadowView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var messageTxt: UITextView!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var header: String?
    var message: String?
    var confirmBtnTitle: String?
    var completion: (() -> ())?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLbl.text = header
        messageTxt.text = message
        
        if let confirmBtnTxt = confirmBtnTitle {
            confirmBtn.setTitle(confirmBtnTxt, for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        fadeInBackground()
        alertView.zoomIn()
    }
    
    // MARK: - Actions
    
    @IBAction func playAgainTapped(_ sender: Any) {
        alertView.fall {
            self.dismiss(animated: false) {
                self.completion?()
            }
        }
    }
    
    @IBAction func dimissTapped(_ sender: Any) {
        alertView.fall {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    // MARK: - Private functions
    
    private func fadeInBackground() {
        dismissBtn.fadeIn(toAlpha: Constants.View.alertOverlayAlpha)
    }
}
