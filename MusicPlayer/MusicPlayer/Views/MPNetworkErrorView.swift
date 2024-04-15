//
//  MPNetworkErrorView.swift
//  MusicPlayer
//
//  Created by Prashil Alva on 03/12/23.
//

import SwiftUI

struct MPNetworkErrorView: View {
    @Binding var isReloadRequested: Bool
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Image(systemName: "network.slash")
                    .font(.largeTitle)
                    .padding(.bottom)
                Text("Uh-Oh")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom)
                Text("This Could be Issue from Our End or your Internet Connection. As a Quick Troubleshooting, Please Check your Internet Connection and Try Again. If this doesn't work, Dont Worry! We will fix this as soon as Possible.")
            }
            .foregroundColor(.secondary)
            Button("Try Again") {
                self.isReloadRequested = true
            }
            .padding(.top)
            Spacer()
        }
        .padding()
    }
}

//struct MPNetworkErrorView_Previews: PreviewProvider {
//    static var previews: some View {
//        MPNetworkErrorView()
//    }
//}
