//
//  AudioPlayer.swift
//  fireworks
//
//  Created by Milen Halachev on 9.01.21.
//

import Foundation
import AVFoundation

/**
 Because AVAudioPlayer can play only 1 sound at a time.
 This class allows:
 - playing multiple audio files at the same time
 - playing the same audio file multiple times at the same time
 - schedule playing of audio files
 */
class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    var players: [AVAudioPlayer] = []
    var timers: [Timer] = []
    
    func play(file: URL, onPlay: ((AVAudioPlayer) -> Void)? = nil) {
        
        guard let player = try? AVAudioPlayer(contentsOf: file) else {
            
            return
        }
        
        self.players.append(player)
        player.delegate = self
        player.play()
        onPlay?(player)
    }
    
    func schedulePlaying(file: URL, every timeInterval: TimeInterval, delay: TimeInterval, onPlay: ((AVAudioPlayer) -> Void)? = nil) {
        
        let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [weak self] _ in
            
            let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { timer in
                
                timer.invalidate()
                self?.timers.removeAll(where: { $0 === timer })
                self?.play(file: file, onPlay: onPlay)
            }
            
            self?.timers.append(timer)
        })
        
        self.timers.append(timer)
    }
    
    func cancelScheduledPlaying() {
        
        self.timers.forEach { $0.invalidate() }
        self.timers = []
    }
    
    func stop() {

        self.cancelScheduledPlaying()
        self.players.forEach { $0.stop() }
        self.players = []
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        self.players.removeAll(where: { $0 === player })
    }
}
