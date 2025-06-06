//
//  Song.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 7/20/22.
//

import UIKit
import AVFoundation

class Song: NSObject {
    var id: String
    var playlistId: String = ""
    var filename: String = ""
    var foldername: String = ""
    var assetURL: String = ""
    var title: String = ""
    var artist: String = ""
    var albumName: String = ""
    var artwork: UIImage?
    var duration: CMTime
    var beginSilence: CGFloat = -1.0
    var endSilence: CGFloat = -1.0
    var isBundle: Bool = false
    var isSelected: Bool = false
    var downloadedURL: String = ""
    
    var url: URL {
        if assetURL != "" {
            return URL(string: assetURL)!
        } else {
            return Song.url(filename, foldername, isBundle)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case playlistId
        case filename
        case foldername
        case assetURL
        case title
        case artist
        case artwork
        case albumName
        case duration
        case beginSilence
        case endSilence
        case isBundle
        case type
        case downloadedURL
    }
    
    var json: [String: Any] {
        return [CodingKeys.id.rawValue: id,
                CodingKeys.playlistId.rawValue: playlistId,
                CodingKeys.filename.rawValue: filename,
                CodingKeys.foldername.rawValue: foldername,
                CodingKeys.assetURL.rawValue: assetURL,
                CodingKeys.title.rawValue: title,
                CodingKeys.artist.rawValue: artist,
                CodingKeys.albumName.rawValue: albumName,
                CodingKeys.beginSilence.rawValue: beginSilence,
                CodingKeys.endSilence.rawValue: endSilence,
                CodingKeys.isBundle.rawValue: isBundle,
                CodingKeys.downloadedURL.rawValue: downloadedURL
        ]
    }
    
    init(id: String? = nil, filename: String, foldername: String, playlistId: String, isBundle: Bool, assetURL: String? = nil) {
        if let id = id {
            self.id = id
        } else {
            self.id = UUID().uuidString
        }
        if let assetURL = assetURL {
            self.assetURL = assetURL
        }
        self.playlistId = playlistId
        self.filename = filename
        self.foldername = foldername
        self.isBundle = isBundle

        let url: URL
        if self.assetURL != "" {
            url = URL(string: self.assetURL)!
        } else {
            url = Song.url(filename, foldername, isBundle)
        }
        let item = AVPlayerItem(url: url)
        self.duration = item.asset.duration

        let metadata = item.asset.commonMetadata
        self.artwork = UIImage(named: "default_cover")

        self.title = (filename as NSString).deletingPathExtension
        
        for metadataItem in metadata {
            switch metadataItem.commonKey?.rawValue ?? "" {
            case "artwork":
                if let imageData = metadataItem.value as? Data {
                    self.artwork = UIImage(data: imageData) ?? UIImage(named: "default_cover")!
                }
            case "artist":
                self.artist = metadataItem.stringValue ?? "Unknown"
            case "albumName":
                self.albumName = metadataItem.stringValue ?? ""
            default: break
            }
        }
        
        if self.title == "" {
            self.title = filename.replacingOccurrences(of: ".mp3", with: "")
        }
    }
    
    // Load song from json that stored in local
    init(json: [String: Any]) {
        self.id = json[CodingKeys.id.rawValue] as! String
        self.playlistId = json[CodingKeys.playlistId.rawValue] as! String
        self.albumName = json[CodingKeys.albumName.rawValue] as! String
        self.filename = json[CodingKeys.filename.rawValue] as! String
        self.foldername = json[CodingKeys.foldername.rawValue] as! String
        self.assetURL = json[CodingKeys.assetURL.rawValue] as! String
        self.title = json[CodingKeys.title.rawValue] as! String
        self.artist = json[CodingKeys.artist.rawValue] as! String
        self.beginSilence = json[CodingKeys.beginSilence.rawValue] as! CGFloat
        self.endSilence = json[CodingKeys.endSilence.rawValue] as! CGFloat
        self.isBundle = json[CodingKeys.isBundle.rawValue] as! Bool
        if let url = json[CodingKeys.downloadedURL.rawValue] as? String {
            self.downloadedURL = url
        }
        
        let url: URL
        if self.assetURL != "" {
            url = URL(string: self.assetURL)!
        } else {
            url = Song.url(filename, foldername, isBundle)
        }
        let item = AVPlayerItem(url: url)
        self.duration = item.asset.duration
        
        let metadata = item.asset.commonMetadata
        self.artwork = UIImage(named: "default_cover")
        
        for metadataItem in metadata {
            switch metadataItem.commonKey?.rawValue ?? "" {
            case "artwork":
                if let imageData = metadataItem.value as? Data {
                    self.artwork = UIImage(data: imageData) ?? UIImage(named: "default_cover")!
                }
                
            default:
                break
            }
        }
    }
    
    func changeTitle(_ title: String) {
        let pathExtension = (filename as NSString).pathExtension
        let url = self.url
        self.title = title
        self.filename = "\(title).\(pathExtension)"
        try? FileManager.default.moveItem(at: url, to: self.url)
        PlaylistManager.shared.savePlaylists()
    }
    
    func delete() {
        try? FileManager.default.removeItem(at: url)
    }
    
    static func url(_ filename: String, _ foldername: String, _ bundle: Bool) -> URL {
        if bundle {
            let direcotry = Bundle.main.resourceURL!.appendingPathComponent(foldername)
            return direcotry.appendingPathComponent(filename)
        } else {
            let directory = URL(fileURLWithPath: PlaylistManager.shared.selectSongsDirectory).appendingPathComponent(foldername)
            return directory.appendingPathComponent(filename)
        }
    }
}
