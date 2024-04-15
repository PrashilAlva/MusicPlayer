//
//  SongPlaybackController.swift
//  MusicPlayer
//
//  Created by Prashil Alva on 23/11/23.
//

import Foundation
import AVFoundation
import AVKit
import SwiftUI

enum Direction {
    case forward
    case backward
}

class SongPlaybackController: NSObject, ObservableObject {
    
    @Published var player: AVPlayer?
    @Published var isSongPlayed = "pause.circle.fill"
    @Published var startTime: Double = 0
    @Published var endTime: Double = 0
    @Published var playbackTimeObserver: Any?
    @Published var isForYouSongSelected = true
    @Published var songSelected: Song = Song()
    @Published var hasSongStartedPlaying = true
    @Published var directionOfSongs: Direction = .forward
    @Published var isSongPlayingFailed = false
    
    func playAudio() {
        hasSongStartedPlaying = false
        if let url = URL(string: songSelected.url.replacingOccurrences(of: " ", with: "")) {
            
            // To Handle Playing the Song in Device
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
            } catch(let error) {
                print(error.localizedDescription)
            }
            
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            
            // Observe the status property of the player item
            playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new, .initial], context: nil)
            
            // Observe when the player reaches the end of the item
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            // Set up a timer to periodically check the current playback time
            let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            playbackTimeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
                self?.setCurrentDuration(time: time)
            }
        }
    }
    
    func playNextSong() {
        var songIndex = 0
        if directionOfSongs == .forward {
            songIndex = SongController.getIndexOf(song: songSelected, isForYouSong: isForYouSongSelected) + 1
            if songIndex >= (isForYouSongSelected ? SongController.forYouSongs.count : SongController.topSongs.count) {
                songIndex = 0
            }
        } else {
            songIndex = SongController.getIndexOf(song: songSelected, isForYouSong: isForYouSongSelected) - 1
            if songIndex == -1 {
                songIndex = (isForYouSongSelected ? SongController.forYouSongs.count : SongController.topSongs.count) - 1
            }
        }
        songSelected = isForYouSongSelected ? SongController.forYouSongs[songIndex] : SongController.topSongs[songIndex]
        playAudio()
    }
    
    @objc func playerDidFinishPlaying() {
        playNextSong()
    }
    
    func setCurrentDuration(time: CMTime) {
        startTime = CMTimeGetSeconds(time)
    }
    
    func setSongDuration() {
        guard let endTimeObtained = player?.currentItem?.duration else {
            return
        }
        endTime = CMTimeGetSeconds(endTimeObtained)
    }
    
    func formattedTimeString(from seconds: Double) -> String {
        if hasSongStartedPlaying {
            let roundedSeconds = Int(round(seconds))
            let minutes = roundedSeconds / 60
            let seconds = roundedSeconds % 60
            return String(format: "%02d:%02d", minutes, seconds)
        } else {
            return "-:--"
        }
    }
    
    func stopAudio() {
        player?.pause()
    }
    
    func resumeAudio() {
        player?.play()
    }
    
    func pauseOrPlaySong() {
        if isSongPlayed == "pause.circle.fill" {
            stopAudio()
            isSongPlayed = "play.circle.fill"
        } else {
            isSongPlayed = "pause.circle.fill"
            resumeAudio()
        }
    }
    
    func seekAudio(to time: Double) {
        let timeToSeek = CMTime(seconds: time, preferredTimescale: 1)
        player?.seek(to: timeToSeek)
    }
    
}

extension SongPlaybackController {
    // Observing changes in AVPlayerItem status
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            if let statusValue = change?[.newKey] as? Int,
               let status = AVPlayerItem.Status(rawValue: statusValue){
                if status == .readyToPlay {
                    // Player is ready, start playing
                    hasSongStartedPlaying = true
                    directionOfSongs = .forward
                    player?.play()
                    isSongPlayed = "pause.circle.fill"
                    setSongDuration()
                } else if status == .failed {
                    isSongPlayingFailed = true
                }
            } else {
                isSongPlayingFailed = true
            }
        }
    }
}
