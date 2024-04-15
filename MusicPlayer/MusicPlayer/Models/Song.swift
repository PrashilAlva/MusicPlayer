//
//  Song.swift
//  MusicPlayer
//
//  Created by Prashil Alva on 22/11/23.
//

import Foundation

struct Songs: Codable {
    var data: [Song]
}

struct Song: Codable, Identifiable, Hashable {
    var id: Int
    var name: String
    var artist: String
    var accent: String
    var cover: String
    var top_track: Bool
    var url: String
    
    init(id: Int, name: String, artist: String, accent: String, cover: String, top_track: Bool, url: String) {
        self.id = id
        self.name = name
        self.artist = artist
        self.accent = accent
        self.cover = cover
        self.top_track = top_track
        self.url = url
    }
    
    init() {
        self.id = -1
        self.name = ""
        self.artist = ""
        self.accent = ""
        self.cover = ""
        self.top_track = false
        self.url = ""
    }
}
