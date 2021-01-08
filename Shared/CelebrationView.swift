//
//  CelebrationView.swift
//  fireworks
//
//  Created by Milen Halachev on 6.01.21.
//

import SwiftUI

//shows fireworks on dark mode and confetti on light mode
struct CelebrationView: View {
    
    @Binding var started: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        switch self.colorScheme {
            
            case .light:
                ConfettiView(started: $started)
            case .dark:
                FireworksView(started: $started)
            @unknown default:
                EmptyView()
        }
    }
}

struct CelebrationView_Previews: PreviewProvider {
    static var previews: some View {
        CelebrationView(started: .constant(true))
    }
}
