//
//  MPHomePageView.swift
//  MusicPlayer
//
//  Created by Prashil Alva on 22/11/23.
//

import SwiftUI

struct MPHomePageView: View {
    @State var isSongsLoaded = false
    @State var isSummarySelected = false
    @StateObject var playbackController = SongPlaybackController()
    @Environment(\.colorScheme) var colorScheme
    @State var isForYouTabSelected = true
    
    var body: some View {
        VStack {
            if isSongsLoaded {
                VStack {
                    List(isForYouTabSelected ? SongController.forYouSongs : SongController.topSongs) { track in
                        HStack {
                            AsyncImage(url: URL(string: "https://cms.samespace.com/assets/\(track.cover)")) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "music.note")
                            }
                            .id("https://cms.samespace.com/assets/\(track.cover)")
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .padding(.trailing)
                            VStack {
                                HStack {
                                    Text(track.name)
                                        .foregroundColor(playbackController.songSelected.id == track.id ? .pink : .primary)
                                    Spacer()
                                }
                                HStack {
                                    Text(track.artist)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                            Spacer()
                            if playbackController.songSelected.id == track.id {
                                Image(systemName: "music.quarternote.3")
                                    .foregroundColor(.pink)
                            }
                        }
                        .animation(.easeIn(duration: 0.5), value: playbackController.songSelected.id)
                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5))
                        .onTapGesture {
                            playbackController.songSelected = track
                            playbackController.isForYouSongSelected = !track.top_track
                            playbackController.playAudio()
                        }
                    }
                    .listStyle(.plain)
                    .animation(.easeInOut(duration: 1), value: isForYouTabSelected)
                    VStack {
                        if playbackController.songSelected.id > -1 {
                            HStack {
                                AsyncImage(url: URL(string: "https://cms.samespace.com/assets/\(playbackController.songSelected.cover)")) { image in
                                    image.resizable()
                                } placeholder: {
                                    Image(systemName: "music.note")
                                }
                                .id("https://cms.samespace.com/assets/\(playbackController.songSelected.cover)")
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 5))
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
                            .onTapGesture {
                                isSummarySelected = true
                            }
                            .popover(isPresented: $isSummarySelected) {
                                MPMusicControllerView(playbackController: playbackController, currentIndex: SongController.getIndexOf(song: playbackController.songSelected, isForYouSong: playbackController.isForYouSongSelected))
                                    .presentationCompactAdaptation(.fullScreenCover)
                            }
                        }
                        HStack {
                            Spacer()
                            Button {
                                isForYouTabSelected = true
                            } label: {
                                VStack {
                                    Text("For You")
                                        .font(.system(size: 18))
                                        .foregroundColor(isForYouTabSelected ? .primary : .secondary)
                                        .fontWeight(.bold)
                                        .padding(.bottom)
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 10))
                                        .fontWeight(.bold)
                                        .foregroundColor(isForYouTabSelected ? .primary : (colorScheme == .dark ? .black : .white))
                                }
                                .frame(height: 50)
                            }
                            Spacer()
                            Button {
                                isForYouTabSelected = false
                            } label: {
                                VStack {
                                    Text("Top Tracks")
                                        .font(.system(size: 18))
                                        .foregroundColor(isForYouTabSelected ? .secondary : .primary)
                                        .fontWeight(.semibold)
                                        .padding(.bottom)
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 10))
                                        .fontWeight(.semibold)
                                        .foregroundColor(!isForYouTabSelected ? .primary : (colorScheme == .dark ? .black : .white))
                                }
                                .frame(height: 50)
                            }
                            Spacer()
                        }
                        .padding(.top)
                    }
                }
                .accentColor(.primary)
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
        .task {
            await SongController.getSongs()
            isSongsLoaded = true
        }
    }
}

//struct MPHomePageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MPHomePageView()
//    }
//}
