//
//  FireworksView.swift
//  fireworks
//
//  Created by Milen Halachev on 6.01.21.
//

import SwiftUI
import AVFoundation

struct FireworksView: UIViewRepresentable {
    
    @Binding var started: Bool
    
    func makeUIView(context: Context) -> FireworksUIView {

        return FireworksUIView()
    }
    
    func updateUIView(_ uiView: FireworksUIView, context: Context) {
       
        self.started ? uiView.start() : uiView.stop()
        
        if self.started {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(3500))) {

                $started.wrappedValue = false
            }
        }
    }
}

//Because AVAudioPlayer can play only 1 sound at a time
class FireworksPlayer: NSObject, AVAudioPlayerDelegate {
    
    var players: [AVAudioPlayer] = []
    var timers: [Timer] = []
    
    func scheduleExplosionEvery(timeInterval: TimeInterval, delay: TimeInterval) {
        
        let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [weak self] (_) in
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(Int(delay * 1000)))) {
                
                self?.playExplosion()
            }
        })
        
        self.timers.append(timer)
    }
    
    func playExplosion() {
        
        guard let player = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "fireworks-explosion", withExtension: "mp3")!) else {
            
            return
        }
        
        self.players.append(player)
        player.delegate = self
        player.play()
    }
    
    func stop() {

        self.timers.forEach { $0.invalidate() }
        self.timers = []
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        self.players.removeAll(where: { $0 === player })
    }
}

class FireworksUIView: UIView {
    
    var numberOfFireworks = 5
    var emitterLayer: CAEmitterLayer?
    let player = FireworksPlayer()
    
    
    var isStarted: Bool {
        
        return self.emitterLayer?.lifetime == 1
    }
    
    override func layoutSublayers(of layer: CALayer) {
        
        super.layoutSublayers(of: layer)
        
        self.layoutEmitterLayer()
    }
    
    func layoutEmitterLayer() {
     
        self.emitterLayer?.frame = self.layer.bounds
        self.emitterLayer?.emitterPosition = self.center
    }
    
    func start() {
        
        guard !self.isStarted else {
            
            return
        }
        
        let emitterLayer = CAEmitterLayer()
        emitterLayer.beginTime = CACurrentMediaTime()
        emitterLayer.emitterCells = (0..<self.numberOfFireworks).map { index -> CAEmitterCell in
            
            let birthRate: Float = (Float(index + 1) / Float(self.numberOfFireworks)) + 0.5
            let lifetime: Float = .random(in: 0.75...1.25)
         
            let locationCell = CAEmitterCell()
//            locationCell.contents = UIImage(named: "spark")?.cgImage //uncomment and set `scale` to 1 for debuggin purposes in order to track the fireworks trail.
            locationCell.scale = 0.0
            locationCell.birthRate = birthRate
            locationCell.lifetime = lifetime
            locationCell.color = UIColor.white.cgColor
            locationCell.redRange = 1
            locationCell.greenRange = 1
            locationCell.blueRange = 1
            locationCell.velocity = 200
            locationCell.velocityRange = 50
            locationCell.emissionLongitude = CGFloat.random(in: Range(uncheckedBounds: (lower: -.pi, upper: .pi)))
            locationCell.emissionRange = .pi

            let fireworkCell = CAEmitterCell()
            fireworkCell.contents = UIImage(named: "spark")?.cgImage
            fireworkCell.name = "Firework"
            fireworkCell.birthRate = 40000.0
            fireworkCell.lifetime = 2
            fireworkCell.beginTime = CFTimeInterval(0.9 * lifetime)
            fireworkCell.duration = CFTimeInterval(0.1 * lifetime)
            fireworkCell.velocity = .random(in: 50...160)
            fireworkCell.emissionRange = 360.0 * (.pi / 180.0)
            fireworkCell.spin = 114.6 * (.pi / 180.0)
            fireworkCell.scale = 0.1
            fireworkCell.scaleSpeed = 0.057//0.09
            fireworkCell.alphaSpeed = -0.6//-0.7
            fireworkCell.color = UIColor.white.cgColor

            locationCell.emitterCells = [fireworkCell]
            
            let explosionTimerInterval: TimeInterval = TimeInterval(1 / locationCell.birthRate)
            let explosionDelay: TimeInterval = TimeInterval(0.9 * locationCell.lifetime)
            self.player.scheduleExplosionEvery(timeInterval: explosionTimerInterval, delay: explosionDelay)
            
            return locationCell
        }
        
        self.emitterLayer?.removeFromSuperlayer()
        self.emitterLayer = emitterLayer
        self.layer.addSublayer(emitterLayer)
        self.layoutEmitterLayer()
    }
    
    func stop() {
        
        self.emitterLayer?.birthRate = 0
        self.emitterLayer?.lifetime = 0
        
        self.player.stop()
    }
}


struct FireworksView_Previews: PreviewProvider {
    static var previews: some View {
        FireworksView(started: .constant(true))
    }
}
