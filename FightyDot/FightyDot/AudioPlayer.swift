//
//  AudioPlayer.swift
//  FightyDot
//
//  Created by Graham McRobbie on 22/02/2017.
//  Copyright © 2017 Graham McRobbie. All rights reserved.
//
//  Singleton audio player for sound effects.
//

import Foundation

import AVFoundation

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    private static let sharedPlayer: AudioPlayer = { return AudioPlayer() }()
    private var container = [String : AVAudioPlayer]()
    
    override init() {
        super.init()
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
    }
    
    static func playFile(named name: String, type: String) throws {
        var player: AVAudioPlayer?
        let key = name+type
        
        player = sharedPlayer.container[key]
            
        if(player == nil) {
            let resource = Bundle.main.path(forResource: name, ofType:type)
            
            guard let fileToPlay = resource else {
                return
            }
                    
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileToPlay), fileTypeHint: AVFileType.wav.rawValue)
            sharedPlayer.container[key] = player
        }
        
        guard let thePlayer = player else {
            return
        }
        
        if (!thePlayer.isPlaying) {
            thePlayer.delegate = sharedPlayer
            thePlayer.play()
        }
    }
}
