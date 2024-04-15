//
//  MPHomePageView.swift
//  MusicPlayer
//
//  Created by Prashil Alva on 22/11/23.
//

import SwiftUI

struct MPHomePageView: View {
    @State var isSummarySelected = false
    @StateObject var playbackController = SongPlaybackController()
    @Environment(\.colorScheme) var colorScheme
    @State var isForYouTabSelected = true
    @State var isReloadRequested = false
    @State var currentAppState: AppState = .loading
    
    var body: some View {
        VStack {
            switch currentAppState {
            case .launched:
                VStack {
                    List(isForYouTabSelected ? SongController.forYouSongs : SongController.topSongs) { track in
                        HStack {
                            if let imageURL = URL(string: "https://cms.samespace.com/assets/\(track.cover)") {
                                MPCacheAsyncImageView(url: imageURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        HStack {
                                            image
                                                .resizable()
                                        }
                                    case .failure:
                                        Image(systemName: "network.slash")
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .id("https://cms.samespace.com/assets/\(track.cover)")
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .padding(.trailing)
                            }
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
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                MPSongSummaryView(playbackController: playbackController)
                                    .onTapGesture {
                                        isSummarySelected = true
                                    }
                                    .popover(isPresented: $isSummarySelected) {
                                        MPMusicControllerView(playbackController: playbackController, currentIndex: SongController.getIndexOf(song: playbackController.songSelected, isForYouSong: playbackController.isForYouSongSelected))
                                            .presentationCompactAdaptation(.fullScreenCover)
                                    }
                            } else {
                                MPSongSummaryView(playbackController: playbackController)
                                    .onTapGesture {
                                        isSummarySelected = true
                                    }
                                    .popover(isPresented: $isSummarySelected) {
                                        MPMusicControllerView(playbackController: playbackController, currentIndex: SongController.getIndexOf(song: playbackController.songSelected, isForYouSong: playbackController.isForYouSongSelected))
                                            .presentationCompactAdaptation(.fullScreenCover)
                                            .frame(idealWidth: .infinity, idealHeight: .infinity)
                                    }
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
                .alert(isPresented: $playbackController.isSongPlayingFailed) {
                    Alert(title: Text("MusicPlayer"), message: Text("Unable to Play the Song. Please check your network and try again."))
                }
            case .loading:
                ProgressView()
            case .notReachable:
                MPNetworkErrorView(isReloadRequested: $isReloadRequested)
            }
        }
        .task {
            do {
                try await SongController.getSongs()
                currentAppState = .launched
            } catch {
                currentAppState = .notReachable
            }
        }
        .onChange(of: isReloadRequested) { newValue in
            if newValue {
                isReloadRequested = false
                currentAppState = .loading
                Task {
                    do {
                        try await SongController.getSongs()
                        currentAppState = .launched
                    } catch {
                        currentAppState = .notReachable
                    }
                }
            }
        }
    }
}

//struct MPHomePageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MPHomePageView()
//    }
//}
