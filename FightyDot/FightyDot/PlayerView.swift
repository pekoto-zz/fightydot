//
//  PlayerView.swift
//  Ananke
//
//  Created by Graham McRobbie on 31/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//
//  Encapsulates the UI elements associated with a player
//

import Foundation
import UIKit

class PlayerView {
    
    fileprivate var _nameLbl: UILabel!
    fileprivate var _initialLbl: UILabel!
    fileprivate var _iconImg: UIImageView!
    fileprivate var _counterImgs: [UIImageView]!
    fileprivate var _statusLbl: UILabel!
    fileprivate var _activeImg: UIImageView!
    fileprivate var _pieceImg: UIImage?
    
    fileprivate var _counterImgDic: [PlayerColour: UIImage] = [
        PlayerColour.green: #imageLiteral(resourceName: "green-counter"),
        PlayerColour.red: #imageLiteral(resourceName: "red-counter")
    ]
    
    fileprivate var _iconImgDic: [PlayerColour: UIImage] = [
        PlayerColour.green: #imageLiteral(resourceName: "green-icon"),
        PlayerColour.red: #imageLiteral(resourceName: "red-icon")
    ]
    
    fileprivate var _pieceImgDic: [PlayerColour: UIImage] = [
        PlayerColour.green: #imageLiteral(resourceName: "green-piece"),
        PlayerColour.red: #imageLiteral(resourceName: "red-piece")
    ]
    
    init(nameLbl: UILabel, initialLbl: UILabel, iconImg: UIImageView, counterImgs: [UIImageView], statusLbl: UILabel, activeImg: UIImageView) {
        _nameLbl = nameLbl
        _initialLbl = initialLbl
        _iconImg = iconImg
        _counterImgs = counterImgs
        _statusLbl = statusLbl
        _activeImg = activeImg
    }
}

// MARK: PlayerDelegate

extension PlayerView: PlayerDelegate {
    
    func setupUIFor(player: Player) {
        _nameLbl.text = player.name
        _initialLbl.text = player.playerNumInitial
        _iconImg.image = _iconImgDic[player.colour]
        
        let counterImg = _counterImgDic[player.colour]
        
        for img in _counterImgs {
            img.image = counterImg
        }
        
        if(player.type == .humanLocal) {
            _statusLbl.isHidden = true
        }
        
        _activeImg.isHidden = !player.isCurrentPlayer
        _pieceImg = _pieceImgDic[player.colour]
    }
    
    func update(isCurrentPlayer: Bool) {
        _activeImg.isHidden = !isCurrentPlayer
    }
    
    func updateNumOfVisibleCounters(to newCount: Int) {
        let numOfVisibleCounters = _counterImgs.filter { (img) in !img.isHidden }.count
        if(numOfVisibleCounters != newCount) {
            animateVisibleCounterImgs(from: numOfVisibleCounters, to: newCount)
        }
    }
    
    func update(status: AIPlayerState) {
        _statusLbl.text = status.rawValue
    }
    
    // MARK: - Private functions
    
    private func animateVisibleCounterImgs(from oldPieceCount: Int, to newPieceCount: Int) {
        // Piece placed: decrement pieces in hand
        if(oldPieceCount > newPieceCount) {
            for i in (newPieceCount...oldPieceCount-1).reversed() {
                _counterImgs[i].zoomOut()
            }
        }
        // Pieces reset
        else if (newPieceCount > oldPieceCount) {
            for i in (oldPieceCount...newPieceCount-1) {
                _counterImgs[i].zoomIn()
            }
        }
    }
}
