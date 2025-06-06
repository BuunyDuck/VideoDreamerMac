//
//  Playlist.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 7/28/22.
//

import UIKit

class Playlist: NSObject {
    var id: String = ""
    var title: String = ""
    var selectedIndex: Int = -1
    var songs: [Song] = []
    var isLibrary: Bool = false
    
    // None property
    var songsCount: Int = 0
    var data: [String: Any] = [:]
    var isLoading: Bool = false
    var isLoaded: Bool {
        return songs.count == songsCount
    }
    var didLoad: (() -> Void)? = nil
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case selectedIndex
        case songs
        case isLibrary
    }
    
    var json: [String: Any] {
        if isLoaded == false {
            return data
        } else {
            return [CodingKeys.id.rawValue: id,
                    CodingKeys.title.rawValue: title,
                    CodingKeys.selectedIndex.rawValue: selectedIndex,
                    CodingKeys.songs.rawValue: songs.map { $0.json },
                    CodingKeys.isLibrary.rawValue: isLibrary,
            ]
        }
    }
    
    var fullPath: String {
        return PlaylistManager.shared.selectSongsDirectory + "\(title)/"
    }
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
    
    init(json: [String: Any]) {
        self.id = json[CodingKeys.id.rawValue] as! String
        self.title = json[CodingKeys.title.rawValue] as! String
        self.selectedIndex = json[CodingKeys.selectedIndex.rawValue] as! Int
        let songs = json[CodingKeys.songs.rawValue] as! [[String: Any]]
        self.songsCount = songs.count
        self.isLibrary = json[CodingKeys.isLibrary.rawValue] as! Bool
        if self.isLibrary {
            self.songs = songs.map { Song(json: $0) }
        }
        //self.songs = songs.map { Song(json: $0) }
        self.data = json
    }
    
    func loadSongs() {
        if isLoaded {
            return
        }
        
        if isLoading {
            return
        }
        
        isLoading = true
        if let songs = data[CodingKeys.songs.rawValue] as? [[String: Any]] {
            self.songs = songs.map { Song(json: $0) }
        }
        isLoading = false
        didLoad?()
    }
    
    func song(with title: String) -> Song? {
        return songs.first { song in
            return song.title == title
        }
    }
    
    func song(filename: String) -> Song? {
        return songs.first { song in
            return song.filename == filename
        }
    }
    
    func changeTitle(_ title: String) {
        let path = fullPath
        self.title = title
        try? FileManager.default.moveItem(atPath: path, toPath: fullPath)
        PlaylistManager.shared.savePlaylists()
    }
    
    func add(song: Song) {
        songs.append(song)
        songsCount += 1
    }
    
    func remove(song: Song) {
        if let index = songs.firstIndex(where: { song2 in
            return song.id == song2.id
        }) {
            songs.remove(at: index)
        }
        PlaylistManager.shared.savePlaylists()
    }
    
    func delete() {
        try? FileManager.default.removeItem(atPath: fullPath)
    }
}
