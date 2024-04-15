//
//  MPMusicControllerView.swift
//  MusicPlayer
//
//  Created by Prashil Alva on 23/11/23.
//

import SwiftUI

struct MPMusicControllerView: View {
    @State private var currentTime: Double = 0
    @ObservedObject var playbackController: SongPlaybackController
    @State private var isSliding = false
    @State var currentIndex: Int = 0
    @Environment(\.colorScheme) var colorScheme
    @State var currentlySelectedSongCollection: [Song] = SongController.forYouSongs
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: playbackController.songSelected.accent), (colorScheme == .dark ? .black : .white)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .scaleEffect(1.5)
            VStack {
                
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.system(size: 30))
                })
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 30, trailing: 0))
                
                TabView(selection: $currentIndex) {
                    Spacer().tag(-1)
                    ForEach(0..<currentlySelectedSongCollection.count, id: \.self) { index in
                        ZStack(alignment: .topLeading) {
                            if let imageURL = URL(string: "https://cms.samespace.com/assets/\(currentlySelectedSongCollection[index].cover)") {
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
                                .id("https://cms.samespace.com/assets/\(currentlySelectedSongCollection[index].cover)")
                                .frame(width: 300)
                                .clipShape(Rectangle())
                                .padding(.top)
                                .cornerRadius(10)
                                .shadow(color: .black, radius: 10)
                                .animation(.easeInOut, value: currentIndex)
                            }
                        }
                    }
                    Spacer().tag(currentlySelectedSongCollection.count)
                }
                .frame(height: 300)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .onChange(of: currentIndex) { [oldValue = currentIndex] newValue in
                    if oldValue > newValue {
                        // Means User has done a backward swipe action
                        playbackController.directionOfSongs = .backward
                    }
                    if currentIndex == -1 {
                        currentIndex = (currentlySelectedSongCollection.count - 1)
                    } else if currentIndex == currentlySelectedSongCollection.count {
                        currentIndex = 0
                    }
                    playbackController.songSelected = currentlySelectedSongCollection[currentIndex]
                    playbackController.playAudio()
                }
                
                Spacer()
                Text(playbackController.songSelected.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text(playbackController.songSelected.artist)
                    .foregroundColor(.secondary)
                Spacer()
                Slider(
                    value: $currentTime,
                    in: 0...(playbackController.endTime),
                    onEditingChanged: { editing in
                        isSliding = editing
                        if !editing {
                            playbackController.seekAudio(to: currentTime)
                        }
                    }
                )
                .onReceive(playbackController.$startTime) { time in
                    currentTime = time
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !isSliding {
                                let sliderWidth = UIScreen.main.bounds.width - 32
                                let percentage = Double(value.location.x / sliderWidth)
                                let timeToSeek = percentage * (playbackController.endTime)
                                playbackController.seekAudio(to: timeToSeek)
                            }
                        }
                )
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                .accentColor(.primary)
                HStack {
                    Text(playbackController.formattedTimeString(from: playbackController.startTime))
                        .padding(.leading)
                    Spacer()
                    Text(playbackController.formattedTimeString(from: playbackController.endTime))
                        .padding(.trailing)
                }
                .foregroundColor(.secondary)
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        playbackController.directionOfSongs = .backward
                        currentIndex = currentIndex - 1
                    }) {
                        Image(systemName: "backward.end.fill")
                            .font(.system(size: 25))
                    }
                    Spacer()
                    Button(action: {
                        playbackController.pauseOrPlaySong()
                    }) {
                        Image(systemName: playbackController.isSongPlayed)
                            .font(.system(size: 60))
                    }
                    Spacer()
                    Button(action: {
                        currentIndex = currentIndex + 1
                    }) {
                        Image(systemName: "forward.end.fill")
                            .font(.system(size: 25))
                    }
                    Spacer()
                }
                .foregroundColor(.primary)
                .padding(.bottom)
            }
        }
        .onChange(of: playbackController.songSelected.id, perform: { newValue in
            currentIndex = SongController.getIndexOf(song: playbackController.songSelected, isForYouSong: playbackController.isForYouSongSelected)
        })
        .animation(.easeInOut(duration: 1), value: playbackController.songSelected.id)
        .onReceive(playbackController.$isForYouSongSelected) { newValue in
            currentlySelectedSongCollection = newValue ? SongController.forYouSongs : SongController.topSongs
        }
        .alert(isPresented: $playbackController.isSongPlayingFailed) {
            Alert(title: Text("MusicPlayer"), message: Text("Unable to Play the Song. Please check your network and try again."))
        }
    }
    
}

//struct MPMusicControllerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MPMusicControllerView()
//    }
//}
