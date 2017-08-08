//
//  GameVC.swift
//  FightyDot
//
//  Created by Graham McRobbie on 18/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//

import UIKit
import Firebase

class GameVC: UIViewController {

    @IBOutlet var nodeImgViews: Array<NodeImageView>!
    @IBOutlet var millViews: Array<MillView>!
    
    @IBOutlet var p1NameLbl: UILabel!
    @IBOutlet var p1InitialLbl: UILabel!
    @IBOutlet var p1CounterImgs: Array<UIImageView>!
    @IBOutlet var p1ActiveImg: UIImageView!
    @IBOutlet var p1IconImg: UIImageView!
    @IBOutlet var p1StatusLbl: UILabel!
    
    @IBOutlet var p2NameLbl: UILabel!
    @IBOutlet var p2InitialLbl: UILabel!
    @IBOutlet var p2CounterImgs: Array<UIImageView>!
    @IBOutlet var p2ActiveImg: UIImageView!
    @IBOutlet var p2IconImg: UIImageView!
    @IBOutlet var p2StatusLbl: UILabel!
    
    @IBOutlet var helpLbl: UILabel!
    @IBOutlet var tipLbl: UITextView!
    
    // Allows game type to be set via storyboard
    // (Swift does not currently allow Enums to be @IBInspectable)
    @IBInspectable var gameTypeStoryboardAdapter:Int {
        get {
            return _gameType.rawValue
        }
        set(gameTypeIndex) {
            _gameType = GameType(rawValue: gameTypeIndex) ?? .PlayerVsPlayer
        }
    }
    
    fileprivate var _gameType: GameType = .PlayerVsPlayer
    fileprivate var _engine: Engine!
    fileprivate var _p1View: PlayerView!
    fileprivate var _p2View: PlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureRecognizerTo(nodeImgs: nodeImgViews)
        addDragGestureRecognizerTo(nodeImgs: nodeImgViews)
        
        _p1View = PlayerView(nameLbl: p1NameLbl, initialLbl: p1InitialLbl, iconImg: p1IconImg, counterImgs: p1CounterImgs, statusLbl: p1StatusLbl, activeImg: p1ActiveImg)
        _p2View = PlayerView(nameLbl: p2NameLbl, initialLbl: p2InitialLbl, iconImg: p2IconImg, counterImgs: p2CounterImgs, statusLbl: p2StatusLbl, activeImg: p2ActiveImg)
        
        _engine = Engine(gameType: _gameType, engineView: self)

        
        playSound(fileName: Constants.Sfx.startGame)
    }
    
    // MARK: - Actions
    
    // Used when placing or taking pieces
    func nodeTapped(sender: UITapGestureRecognizer) {
        guard let nodeId = sender.view?.tag else {
            return
        }

        // Engine calls should only fail if the game/storyboard has been configured incorrectly
        try! _engine.handleNodeTapFor(nodeWithId: nodeId)
    }
    
    // Used when moving or flying pieces
    func nodeDragged(sender: UIPanGestureRecognizer!) {
        guard let nodeImgView = sender.view as? NodeImageView else {
            return
        }
        
        guard let currentNodeId = sender.view?.tag else {
            return
        }
                
        if (sender.state == UIGestureRecognizerState.began) {
            removeAnimatedShadowFromDraggableViews()
            
            let validMoveSpots = try! getMovableViewsFor(nodeWithId: currentNodeId)
            nodeImgView.startDragging(to: validMoveSpots)
            
            helpLbl.text = Constants.Help.movePiece_Selected
            playSound(fileName: Constants.Sfx.dragStart)
        }
        
        if (sender.state == UIGestureRecognizerState.changed) {
            nodeImgView.updatePosition(to: sender.location(in: self.view))
            nodeImgView.updateIntersects()
        }

        if ((sender.state == UIGestureRecognizerState.ended) || (sender.state == UIGestureRecognizerState.cancelled))  {
            var validMoveMade = false
            
            if(nodeImgView.intersectsWithMoveSpot()) {
                guard let newNodeId = nodeImgView.getLastIntersectingMoveSpot()?.tag else {
                    return
                }
                try! _engine.handleNodeDragged(from: currentNodeId, to: newNodeId)
                validMoveMade = true
            }
            
            nodeImgView.endDrag()
            
            if(!validMoveMade) {
                playSound(fileName: Constants.Sfx.dragCancel)
                nodeImgView.resetOriginalImg()
                helpLbl.text = Constants.Help.movePiece_Select
                addAnimatedShadowToDraggableViews()
            }
        }
    }
    
    @IBAction func resetTapped(_ sender: Any) {
        removeAnimatedShadowFromNodes()
        _engine.reset()
    }
    
    // MARK: - Private functions
    
    private func addTapGestureRecognizerTo(nodeImgs: [NodeImageView]) {
        for nodeImg in nodeImgs {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(nodeTapped(sender:)))
            nodeImg.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    private func addDragGestureRecognizerTo(nodeImgs: [NodeImageView]) {
        for nodeImg in nodeImgs {
            let dragGestureRecognizer = UIPanGestureRecognizer(target: self, action:#selector(nodeDragged(sender:)))
            nodeImg.addGestureRecognizer(dragGestureRecognizer)
        }
    }
    
    private func addAnimatedShadowToDraggableViews() {
        for nodeImg in nodeImgViews {
            guard let dragGestureRecognizer = nodeImg.gestureRecognizers?[Constants.View.dragGestureRecognizerIndex] else {
                continue
            }
            
            if (dragGestureRecognizer.isEnabled) {
                nodeImg.addAnimatedShadow()
            }
        }
    }
    
    private func removeAnimatedShadowFromDraggableViews() {
        for nodeImg in nodeImgViews {
            guard let dragGestureRecognizer = nodeImg.gestureRecognizers?[Constants.View.dragGestureRecognizerIndex] else {
                continue
            }
            
            if (dragGestureRecognizer.isEnabled) {
                nodeImg.removeAnimatedShadow()
            }
        }
    }
    
    private func removeAnimatedShadowFromNodes() {
        for nodeImg in nodeImgViews {
            nodeImg.removeAnimatedShadow()
        }
    }
    
    // Get the views this node can be moved to when moving/flying
    private func getMovableViewsFor(nodeWithId id: Int) throws -> [NodeImageView] {
        let movableNodeIds = try _engine.getMovablePositionsFor(nodeWithId: id)
            
        var movableNodeImgs: [NodeImageView] = [NodeImageView]()
            
        for nodeId in movableNodeIds {
            guard let nodeImgView = getNodeImgViewFor(nodeWithId: nodeId) else {
                continue
            }
            
            movableNodeImgs.append(nodeImgView)
        }

        return movableNodeImgs
    }
    
    fileprivate func getNodeImgViewFor(nodeWithId id: Int) -> NodeImageView? {
        return nodeImgViews.filter { (nodeImg) in nodeImg.tag == id }.first
    }
}

// MARK: EngineDelegate

extension GameVC: EngineDelegate {
    
    var p1View: PlayerView {
        get {
            return _p1View
        }
    }
    
    var p2View: PlayerView {
        get {
            return _p2View
        }
    }
    
    func animate(node: Node, to newColour: PieceColour) {
        let nodeImgView = getNodeImgViewFor(nodeWithId: node.id)
        let newImage = Constants.PieceDics.nodeImgs[newColour]
        
        if(nodeImgView?.image != newImage) {
            nodeImgView?.popTo(img: newImage!)
        }
    }
    
    func animate(mill: Mill, to newColour: PieceColour) {
        guard let newUIColour = Constants.PieceDics.pieceColours[mill.colour] else {
            return
        }
        
        let (firstConnector, secondConnector) = getMillsImgsFor(millWithId: mill.id)
        
        if(firstConnector?.backgroundColor != newUIColour || secondConnector?.backgroundColor != newUIColour) {
            firstConnector?.animate(to: newUIColour, completion: nil)
            secondConnector?.animate(to: newUIColour, completion: {
                self.popNodesIn(mill: mill)
            })
        }
    }
    
    func enableTapDisableDragFor(node: Node) {
        let nodeImgView = getNodeImgViewFor(nodeWithId: node.id)
        nodeImgView?.enableTapDisableDrag()
    }
    
    func enableDragDisableTapFor(node: Node) {
        let nodeImgView = getNodeImgViewFor(nodeWithId: node.id)
        nodeImgView?.enableDragDisableTap()
    }
    
    func disableInteractionFor(node: Node) {
        let nodeImgView = getNodeImgViewFor(nodeWithId: node.id)
        nodeImgView?.disable()
    }
    
    func reset(mill: Mill) {
        let (firstConnector, secondConnector) = getMillsImgsFor(millWithId: mill.id)
        
        firstConnector?.reset()
        secondConnector?.reset()
    }

    func gameWon(by player: Player) {
        Analytics.logEvent(Constants.FirebaseEvents.gameComplete, parameters: ["gameType": NSNumber(value: _gameType.rawValue)])
        playSound(fileName: Constants.Sfx.gameOver)
        showAlert(title: "\(player.name) \(Constants.AlertMessages.won)", message: Constants.AlertMessages.playAgain) {
            self._engine.reset()
        }
    }
    
    func playSound(fileName: String, type: String = ".wav") {
        
        let soundDisabled = UserDefaults.standard.bool(forKey: Constants.Settings.muteSounds)
        
        if(soundDisabled) {
            return
        }
        
        try! AudioPlayer.playFile(named: fileName, type: type)
    }
    
    func updateTips(state: GameState) {
        switch state {
        case .AITurn:
            helpLbl.text = Constants.Help.aiTurn
        case .PlacingPieces:
            helpLbl.text = Constants.Help.placePiece
            tipLbl.text = Constants.Tips.makeMove
        case .TakingPiece:
            helpLbl.text = Constants.Help.takePiece
            tipLbl.text = Constants.Tips.canTakePiece
        case .MovingPieces:
            helpLbl.text = Constants.Help.movePiece_Select
            tipLbl.text = Constants.Tips.makeMove
        case .MovingPieces_PieceSelected:
            helpLbl.text = Constants.Help.movePiece_Selected
            tipLbl.text = Constants.Tips.makeMove
        case .FlyingPieces:
            helpLbl.text = Constants.Help.movePiece_Select
            tipLbl.text = Constants.Tips.canFly
        case .FlyingPieces_PieceSelected:
            helpLbl.text = Constants.Help.movePiece_Selected_CanFly
            tipLbl.text = Constants.Tips.canFly
        case .GameOver:
            helpLbl.text = Constants.Help.gameWon
            tipLbl.text = Constants.Tips.restart
        }
    }
    
    // MARK: - Private functions
    
    // Mills have 2 connectors, represented by 2 views, that connect the 3 nodes.
    // This function returns the two views associated with a single mill.
    private func getMillsImgsFor(millWithId id: Int) -> (MillView?, MillView?) {
        let firstConnector = millViews.filter { (millConnectorImg) in millConnectorImg.tag == id * 2 }.first
        let secondConnector = millViews.filter { (millConnectorImg) in millConnectorImg.tag == (id * 2) + 1 }.first
        
        return (firstConnector, secondConnector)
    }
    
    // An extra "pop" animation for emphasis
    private func popNodesIn(mill: Mill) -> () {
        for node in mill.nodes {
            let nodeImg = getNodeImgViewFor(nodeWithId: node.value.id)
            nodeImg?.pop()
        }
    }
    

}
