//
//  SongController.swift
//  MusicPlayer
//
//  Created by Prashil Alva on 22/11/23.
//

import Foundation

struct SongController {
    
    static var forYouSongs: [Song] = []
    static var topSongs: [Song] = []
    
    static func getSongs() async throws {
        guard let songsAPI = URL(string: "https://cms.samespace.com/items/songs") else {
            throw MPError.InvalidURL
        }
        do {
            let regex = try Regex("^(https://)[a-z0-9-. ]*/[ a-z0-9.-]*(mp3)")
            let (data, response) = try await URLSession.shared.data(from: songsAPI)
            guard let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                print("Error in Response")
                throw MPError.NWFetchIssue
            }
            let songsData = try JSONDecoder().decode(Songs.self, from: data)
            songsData.data.forEach({ song in
                if let _ = try? regex.wholeMatch(in: song.url) {
                    song.top_track ? topSongs.append(song) : forYouSongs.append(song)
                }
            })
        } catch {
            throw MPError.NWFetchIssue
        }
    }
    
    static func getIndexOf(song: Song, isForYouSong: Bool) -> Int {
        let arrayToBeUsed = isForYouSong ? forYouSongs : topSongs
        for i in 0..<arrayToBeUsed.count {
            if song.id == arrayToBeUsed[i].id {
                return i
            }
        }
        return -1
    }
    
}
