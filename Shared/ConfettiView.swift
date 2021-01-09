//
//  ConfettiView.swift
//  fireworks
//
//  Created by Milen Halachev on 6.01.21.
//

import SwiftUI
import AVFoundation

//Based on https://github.com/bryce-co/RecreatingiMessageConfetti
struct ConfettiView: UIViewRepresentable {
    
    @Binding var started: Bool
    
    func makeUIView(context: Context) -> ConfettiUIView {

        return ConfettiUIView()
    }
    
    func updateUIView(_ uiView: ConfettiUIView, context: Context) {
        
        self.started ? uiView.start() : uiView.stop()
        
        if self.started {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now().advanced(by: .milliseconds(1500))) {

                $started.wrappedValue = false
            }
        }
    }
}

class ConfettiPlayer: NSObject {
 
    var players: [AVAudioPlayer] = []
    
    func play(file: URL) {
        
    }
    
    func playPop() {
        
    }
    
    func playFalling() {
        
    }
    let popPlayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "confetti-pop", withExtension: "mp3")!)
}

class ConfettiUIView: UIView {
    
    class ConfettiType {
        let color: UIColor
        let shape: ConfettiShape
        let position: ConfettiPosition

        init(color: UIColor, shape: ConfettiShape, position: ConfettiPosition) {
            self.color = color
            self.shape = shape
            self.position = position
        }
        
        lazy var image: UIImage = {
            let imageRect: CGRect = {
                switch shape {
                case .rectangle:
                    return CGRect(x: 0, y: 0, width: 20, height: 13)
                case .circle:
                    return CGRect(x: 0, y: 0, width: 10, height: 10)
                }
            }()

            UIGraphicsBeginImageContext(imageRect.size)
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(color.cgColor)

            switch shape {
            case .rectangle:
                context.fill(imageRect)
            case .circle:
                context.fillEllipse(in: imageRect)
            }

            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }()
    }

    enum ConfettiShape {
        case rectangle
        case circle
    }

    enum ConfettiPosition {
        case foreground
        case background
    }

    var confettiTypes: [ConfettiType] = {
        let confettiColors = [
            (r:149,g:58,b:255), (r:255,g:195,b:41), (r:255,g:101,b:26),
            (r:123,g:92,b:255), (r:76,g:126,b:255), (r:71,g:192,b:255),
            (r:255,g:47,b:39), (r:255,g:91,b:134), (r:233,g:122,b:208)
            ].map { UIColor(red: $0.r / 255.0, green: $0.g / 255.0, blue: $0.b / 255.0, alpha: 1) }

        // For each position x shape x color, construct an image
        return [ConfettiPosition.foreground, ConfettiPosition.background].flatMap { position in
            return [ConfettiShape.rectangle, ConfettiShape.circle].flatMap { shape in
                return confettiColors.map { color in
                    return ConfettiType(color: color, shape: shape, position: position)
                }
            }
        }
    }()
    
    var emitterLayer: CAEmitterLayer?
    let confettiPopEffect = Bundle.main.url(forResource: "confetti-pop", withExtension: "mp3")!
    let confettiFallingEffect = Bundle.main.url(forResource: "confetti-falling", withExtension: "mp3")!
    let player = AudioPlayer()
    
    var isStarted: Bool {
        
        return self.emitterLayer?.birthRate == 1 && self.emitterLayer?.lifetime == 1
    }
    
    override func layoutSublayers(of layer: CALayer) {
        
        super.layoutSublayers(of: layer)
        
        self.layoutEmitterLayer()
    }
    
    func layoutEmitterLayer() {
     
        self.emitterLayer?.frame = self.layer.bounds
        self.emitterLayer?.emitterPosition = .init(x: self.bounds.midX, y: self.bounds.minY-10)
        self.emitterLayer?.emitterSize = .init(width: self.bounds.size.width, height: 10)
    }
 
    func start() {
        
        guard !self.isStarted else {
            
            return
        }
        
        let confettiCells: [CAEmitterCell] = self.confettiTypes.map { confettiType in
            
            let cell = CAEmitterCell()
            cell.beginTime = 0.1
            cell.birthRate = 10
            cell.lifetime = 10
            cell.contents = confettiType.image.cgImage
            cell.emissionRange = CGFloat(Double.pi)
            cell.spin = 4
            cell.spinRange = 8
            cell.velocity = 200
            cell.velocityRange = 50
            cell.yAcceleration = 150
            
            return cell
        }

        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterCells = confettiCells
        emitterLayer.emitterShape = .rectangle
        emitterLayer.beginTime = CACurrentMediaTime()
        
        self.emitterLayer?.removeFromSuperlayer()
        self.emitterLayer = emitterLayer
        self.layer.addSublayer(emitterLayer)
        self.layoutEmitterLayer()
        
        self.player.play(file: self.confettiPopEffect)
        self.player.play(file: self.confettiFallingEffect) { player in
            
            player.setVolume(0, fadeDuration: 7)
        }
    }
    
    func stop() {
        
        self.emitterLayer?.birthRate = 0
        self.emitterLayer?.lifetime = 0
    }
}

struct ConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        ConfettiView(started: .constant(true))
    }
}
