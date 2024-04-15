//
//  MPSongSummaryView.swift
//  MusicPlayer
//
//  Created by Prashil Alva on 03/12/23.
//

import SwiftUI

struct MPSongSummaryView: View {
    @ObservedObject var playbackController: SongPlaybackController
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            if let imageURL = URL(string: "https://cms.samespace.com/assets/\(playbackController.songSelected.cover)") {
                MPCacheAsyncImageView(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                    case .failure:
                        Image(systemName: "network.slash")
                    @unknown default:
                        EmptyView()
                    }
                }
                .id("https://cms.samespace.com/assets/\(playbackController.songSelected.cover)")
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 5))
            }
            Text(playbackController.songSelected.name)
            Spacer()
            Button {
                playbackController.pauseOrPlaySong()
            } label: {
                Image(systemName: playbackController.isSongPlayed)
                    .font(.system(size: 30))
            }
            .padding(.trailing)
        }
        .animation(.easeInOut(duration: 1.0), value: playbackController.songSelected.id)
        .foregroundColor(.primary)
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: playbackController.songSelected.accent), (colorScheme == .dark ? .black : .white)]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

//struct MPSongSummaryView_Previews: PreviewProvider {
//    static var previews: some View {
//        MPSongSummaryView()
//    }
//}
