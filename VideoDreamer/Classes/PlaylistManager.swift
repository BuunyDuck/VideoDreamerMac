//
//  PlaylistManager.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 7/27/22.
//

import UIKit
import MediaPlayer
import StoreKit

@objc class PlaylistManager: NSObject {
    @objc static let shared = PlaylistManager()
    
    private(set) var isLoaded: Bool = false
    
    var playlists: [Playlist] = []
    
    var didLoadPlaylists: (() -> Void)? = nil
    
    var json: [[String: Any]] {
        var json: [[String: Any]] = []
        for playlist in playlists {
            json.append(playlist.json)
        }
        
        return json
    }
    
    @objc var selectSongsDirectory: String {
        return NSHomeDirectory().appending("/Library/Music Library/")
    }
    
    @objc var defaultFolderName: String {
        return "Library"
    }
    
    func initSelectSongs() {
        if UserDefaults.standard.bool(forKey: APP_SELECTSONGS_INITIALIZED) == false {
            UserDefaults.standard.set(true, forKey: APP_SELECTSONGS_INITIALIZED)
            var root: [[String: Any]] = []
            let url = Bundle.main.resourceURL!.appendingPathComponent("SelectSongs.plist")
            do {
                let data = try Data(contentsOf: url)
                let propertyList = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
                if let propertyList = propertyList as? [[String: Any]] {
                    root = propertyList
                }
            } catch {
                print(error.localizedDescription)
            }
            
            let fileManager = FileManager.default
            let directory = selectSongsDirectory
            try? fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
            var directoryURL = URL(fileURLWithPath: directory)
            try? fileManager.copyItem(at: url, to: directoryURL.appendingPathComponent("SelectSongs.plist"))
            for item in root {
                let folderName = item["FolderName"] as! String
                let playlistName = item["MPMediaPlaylistPropertyName"] as! String
                directoryURL = URL(fileURLWithPath: directory).appendingPathComponent(playlistName)
                try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                let playlist = Playlist(id: "\(item["MPMediaPlaylistPropertyPersistentID"] as! UInt64)", title: "\(item["MPMediaPlaylistPropertyName"] as! String)")
                playlist.title = playlistName
                let folderURL =  Bundle.main.resourceURL!.appendingPathComponent(folderName)
                let files = try! FileManager.default.contentsOfDirectory(atPath: folderURL.path)
                for filename in files {
                    if !filename.contains(".plist") {
                        let assetURL = Bundle.main.resourceURL!.appendingPathComponent(folderName).appendingPathComponent(filename)
                        let fileURL = directoryURL.appendingPathComponent(filename)
                        do {
                            try fileManager.copyItem(at: assetURL, to: fileURL)
                        } catch {
                            print(error.localizedDescription)
                        }
                        
                        let song = Song(id: UUID().uuidString, filename: filename, foldername: playlistName, playlistId: playlist.id, isBundle: false)
                        playlist.add(song: song)
                    }
                }
                
                add(playlist: playlist)
                savePlaylists()
            }
        }
    }

    func loadPlaylists() {
        playlists.removeAll()
        if let playlists = UserDefaults.standard.object(forKey: kAllPlaylists) as? [[String: Any]] {
            for playlist in playlists {
                self.playlists.append(Playlist(json: playlist))
            }
        }
    }
    
    func loadPlaylistSongs() {
        for playlist in playlists {
            playlist.loadSongs()
        }
    }
    
    func requestAuthorization(_ completion: @escaping ((Bool) -> Void)) {
        MPMediaLibrary.requestAuthorization { status in
            if status == .authorized {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func add(playlist: Playlist) {
        playlists.append(playlist)
    }
    
    func remove(playlist: Playlist) {
        if let index = playlists.firstIndex(where: { playlist2 in
            return playlist.id == playlist2.id
        }) {
            playlists.remove(at: index)
        }
        savePlaylists()
    }
    
    func savePlaylists() {
        print("savePlaylists")
        UserDefaults.standard.set(json, forKey: kAllPlaylists)
    }
    
    func playlistName(of id: String) -> String {
        if let playlist = playlists.first(where: { playlist in
            return playlist.id == id
        }) {
            return playlist.title
        }
        
        return ""
    }
    
    func playlistNames() -> [String] {
        var names = playlists.map { "\($0.title) (\($0.songsCount) songs)" }
        names.append("--------- None ---------")
        return names
    }
    
    func playlistIDs() -> [String] {
        var ids = playlists.map { $0.id }
        ids.append("None")
        return ids
    }
    
    func playlist(of id: String) -> Playlist? {
        return playlists.first { playlist in
            return playlist.id == id
        }
    }
    
    func playlist(with title: String) -> Playlist? {
        return playlists.first { playlist in
            return playlist.title == title
        }
    }
    
    func defaultPlaylist() -> Playlist {
        return playlists.first { playlist in
            return playlist.isLibrary == false
        }!
    }
    
    func song(with title: String) -> Song? {
        for playlist in playlists {
            if let song = playlist.song(with: title) {
                return song
            }
        }
        
        return nil
    }
    
    func song(filename: String) -> Song? {
        for playlist in playlists {
            if let song = playlist.song(filename: filename) {
                return song
            }
        }
        
        return nil
    }
    
    func isDownloadedSong(url: String, filename: String) -> Bool {
        for playlist in playlists {
            if let _ = playlist.songs.firstIndex(where: { song in
                return song.filename == filename || song.downloadedURL == url
            }) {
                return true
            }
        }
        
        return false
    }
}
