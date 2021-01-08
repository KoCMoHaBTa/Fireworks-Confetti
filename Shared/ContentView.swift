//
//  ContentView.swift
//  Shared
//
//  Created by Milen Halachev on 6.01.21.
//

import SwiftUI

struct ContentView: View {
    
    @State var showCelebration = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ZStack {
            
            Color(.systemBackground)
            
            CelebrationView(started: $showCelebration)
            
            Text("Hello, world!")
                .padding()
        }
        .ignoresSafeArea()
        .onTapGesture {
            
            self.showCelebration.toggle()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
