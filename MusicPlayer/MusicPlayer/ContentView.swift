//
//  ContentView.swift
//  MusicPlayer
//
//  Created by Prashil Alva on 22/11/23.
//

import SwiftUI
import Network

struct ContentView: View {
    @State var canTransitionToHomeScreen = false

    var body: some View {
        VStack {
            if canTransitionToHomeScreen {
                MPHomePageView()
            } else {
                if let appIcon = UIImage(named: "AppIcon") {
                    Image(uiImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 100))
                }
            }
        }
        .onAppear {
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + 2.0) {
                self.canTransitionToHomeScreen = true
            }
        }
    }
    
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
