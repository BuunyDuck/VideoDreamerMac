//
//  MusicDownloadViewController.swift
//  MyOSRadio
//
//  Created by RMD on 8/6/22.
//

import UIKit
import WebKit
import AFNetworking

@objc protocol MusicDownloadViewControllerDelegate {
    func musicDownloadViewControllerDidCancel(_ controller: MusicDownloadViewController)
    func gotoLibraryFromMusicDownloadController(_ controller: MusicDownloadViewController)
    func didDownloadMore(_ controller: MusicDownloadViewController, _ assetURLs: [URL], _ downloadURLs: [[String: String]])
    func didImportSong(_ controller: MusicDownloadViewController, _ assetURLs: [URL], _ downloadURLs: [[String: String]])
    func musicDownloadViewController(_ controller: MusicDownloadViewController, didCreate playlist: Playlist)
    func musicDownloadController(_ controller: MusicDownloadViewController, didUpload files: [Song])
}

@objc class MusicDownloadViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var webContainerView: UIView!

    fileprivate var musicWebView: WKWebView!

    fileprivate var assetURL: URL!

    fileprivate var downloadedSongs: Set<URL> = []
    fileprivate var downloadedURLs: [[String: String]] = []
    fileprivate var downloadQueue: [Download] = []
    fileprivate var isGoogleStore: Bool = false
    fileprivate var isDropbox: Bool = false
    fileprivate var isSpotify: Bool = false
    fileprivate var isShowedAlertView: Bool = false
    fileprivate var downloadURL: URL!
    fileprivate var lastFileName: String = ""
    fileprivate var responseHeaders: [String: Any] = [:]

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }

    var websiteURL: URL!
    var delegate: MusicDownloadViewControllerDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        initView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.musicWebView.frame = self.webContainerView.bounds
    }

    fileprivate func initView() {
        let normalButtonItemAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: MYRIADPRO, size: 16.0)!, .foregroundColor: UIColor.black]
        let highlightButtonItemAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: MYRIADPRO, size: 16.0)!, .foregroundColor: UIColor.darkGray]
        cancelButton.setTitleTextAttributes(normalButtonItemAttributes, for: .normal)
        cancelButton.setTitleTextAttributes(highlightButtonItemAttributes, for: .highlighted)
        
        if self.websiteURL.absoluteString.contains("drive.google.com") {
            self.isGoogleStore = true
        } else if self.websiteURL.absoluteString.contains("www.spotify.com") {
            self.isSpotify = true
        } else if self.websiteURL.absoluteString.contains("www.dropbox.com") {
            self.isDropbox = true
        } else {
            self.isGoogleStore = false
            self.isSpotify = false
        }

        let javaScript = "var vids = document.getElementsByTagName(\"video\"); for(var i = 0; i < vids.length; i++) { vids[i].muted = true; vids[i].controls = false; vids[i].pause(); } var auds = document.getElementsByTagName(\"audio\"); for(var i = 0; i < auds.length; i++) { auds[i].muted = true; auds[i].controls = false; auds[i].pause(); }";
        let script = WKUserScript(source: javaScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = false
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.userContentController.addUserScript(script)
#if targetEnvironment(macCatalyst)
        if #available(macCatalyst 14.0, *) {
            let preferences = WKWebpagePreferences()
            preferences.allowsContentJavaScript = true
            configuration.defaultWebpagePreferences = preferences
        }
#else
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        configuration.preferences = preferences
#endif

        self.musicWebView = WKWebView(frame: self.webContainerView.bounds, configuration: configuration)
        if self.isSpotify {
            UserDefaults.standard.register(defaults: ["UserAgent": "Chrome Safari"])
            self.musicWebView.customUserAgent = "Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5"
        }
        self.webContainerView.addSubview(self.musicWebView)

        self.musicWebView.navigationDelegate = self
        self.musicWebView.isOpaque = false

        if self.websiteURL == nil {
            let url = URL(string: "https://drive.google.com/drive/u/0/my-drive")!
            let request = URLRequest(url: url)
            self.musicWebView.load(request)
        }else {
            let request = URLRequest(url: self.websiteURL)
            self.musicWebView.load(request)
        }
    }

    fileprivate func downloadZipFileURL(_ requestedURL: URL) {
        SHKActivityIndicator.current().displayActivity("Loading...", isLock: true)
        FileNetworkManager.shared().retrieveFileSize(requestedURL) { size in
            DispatchQueue.main.async {
                SHKActivityIndicator.current().hide()
                if size != 0 {
                    var fileSize: String = ""
                    if size < 1024 {
                        fileSize = String(format: "%.0f Bytes", size)
                    } else if (size < 1024 * 1024) {
                        fileSize = String(format: "%.2f KB", size / 1000)
                    } else {
                        fileSize = String(format: "%.2f MB", size / (1000 * 1000))
                    }
                    let message = "File is \(fileSize) and will take some time to download. Add contents of this zip to?"
                    let alertController = YJLCustomAlertController()
                    alertController.setTitle(APP_ALERT_TITLE, message:message)
                    let chooseAction = UIAlertAction(title: "Choose Playlist", style: .default) { action in
                        self.downloadURL = requestedURL
                        //var storyboard = UIStoryboard(name: "Main", bundle: nil)
                        //if UIDevice.current.userInterfaceIdiom == .pad {
                        //    storyboard = UIStoryboard(name: "Main_iPad", bundle: nil)
                        //}
                        //let selectSongsViewController = storyboard.instantiateViewController(withIdentifier: "SelectSongsViewController") as! SelectSongsViewController
                        //selectSongsViewController.delegate = self
                        //self.present(selectSongsViewController, animated: true, completion: nil)
                    }
                    let newAction = UIAlertAction(title: "Make New Playlist", style: .default) { action in
                        SHKActivityIndicator.current().displayActivity("Downloading...", isLock: true)
                        self.downloadZipFile(zipFileURL: requestedURL, originPlaylist: nil) { progress in
                            //SVProgressHUD.showProgress(Float(progress), status: String(format: "Downloading %@\n%.0f %%", requestedURL.lastPathComponent, progress * 100))
                        } completion: { success, playlist, songs in
                            SHKActivityIndicator.current().hide()
                            if success, let playlist = playlist {
                                UserDefaults.standard.set(true, forKey: requestedURL.absoluteString)
                                self.delegate?.musicDownloadViewController(self, didCreate: playlist)
                                //NotificationCenter.default.post(name: .selectSongsChanged, object: playlist, userInfo: nil)
                            }
                        }
                    }

                    let cancelAction = UIAlertAction(title: "Cancel", style: .default) { action in

                    }

                    alertController.alertController.addAction(chooseAction)
                    alertController.alertController.addAction(newAction)
                    alertController.alertController.addAction(cancelAction)
                    self.present(alertController.alertController, animated: true, completion: nil)
                }
            }
        }
    }

    fileprivate func downloadZipFile(zipFileURL: URL, originPlaylist: Playlist?, progress: @escaping ((CGFloat) -> Void), completion: @escaping ((Bool, Playlist?, [Song]?) -> Void)) {
        let configuration = URLSessionConfiguration.default
        let manager = AFURLSessionManager(sessionConfiguration: configuration)

        let request = URLRequest(url: zipFileURL)
        let filename = zipFileURL.lastPathComponent
        let zipPath = NSTemporaryDirectory().appending(filename)
        var tempURL: URL? = nil
        let zipURL = URL(fileURLWithPath: zipPath)
        let downloadTask = manager.downloadTask(with: request) { downloadProgress in
            progress((CGFloat(downloadProgress.completedUnitCount) / CGFloat(downloadProgress.totalUnitCount)))
        } destination: { url, response in
            tempURL = url
            return zipURL
        } completionHandler: { response, filePath, error in
            if let filePath = filePath {
                print("File downloaded to: \(filePath)")
            }

            DispatchQueue.main.async {
                SHKActivityIndicator.current().displayActivity("Please Hang On!\nWe are building your custom playlist!", isLock: true)
            }

            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(false, nil, nil)
                }
            } else {
                DispatchQueue.global(qos: .background).async {
                    var folderTitle = zipFileURL.lastPathComponent
                    let selectSongsPath = PlaylistManager.shared.selectSongsDirectory
                    SSZipArchive.unzipFile(atPath: zipPath, toDestination: selectSongsPath.appending(folderTitle))
                    try? FileManager.default.removeItem(at: tempURL!)
                    try? FileManager.default.removeItem(at: zipURL)

                    let folderExtension = URL(string: folderTitle)!.pathExtension
                    if folderExtension == "zip" {
                        var fpath = selectSongsPath.appending(folderTitle)
                        let path = selectSongsPath.appending(URL(string: folderTitle)!.deletingPathExtension().absoluteString)
                        try? FileManager.default.moveItem(atPath: fpath, toPath: path)
                        folderTitle = URL(string: folderTitle)!.deletingPathExtension().absoluteString

                        fpath = path.appending("/\(folderTitle)")
                        if FileManager.default.fileExists(atPath: fpath) {
                            let tpath = selectSongsPath.appending("/__\(folderTitle)__")
                            fpath = tpath.appending("/\(folderTitle)")
                            try? FileManager.default.moveItem(atPath: path, toPath: tpath)
                            try? FileManager.default.moveItem(atPath: fpath, toPath: path)
                            try? FileManager.default.removeItem(atPath: tpath)
                        }
                    }

                    var folderURL = URL(fileURLWithPath: selectSongsPath.appending(folderTitle))
                    let playlist: Playlist
                    if let originPlaylist = originPlaylist {
                        playlist = originPlaylist
                    } else {
                        playlist = Playlist(id: UUID().uuidString, title: folderTitle)
                    }

                    //let infoURL = URL(fileURLWithPath: PlaylistManager.shared.selectSongsDirectory).appendingPathComponent(folderTitle).appendingPathComponent("filesInfo.plist")
                    //var filesInfo: [[String: Any]] = []
                    //do {
                        //let data = try Data(contentsOf: infoURL)
                        //let propertyList = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil)
                        //if let propertyList = propertyList as? [[String: Any]] {
                            //filesInfo = propertyList
                        //}
                    //} catch {
                        //print(error.localizedDescription)
                    //}
                    var fileContents: [URL] = []
                    var isExistFolder: Bool = true
                    do {
                        var contents = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: [.nameKey], options: .skipsSubdirectoryDescendants)
                        if contents.count == 0 {
                            folderTitle = URL(string: folderTitle)!.deletingPathExtension().path
                            folderURL = URL(fileURLWithPath: selectSongsPath).appendingPathComponent(folderTitle)
                            contents = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: [.nameKey], options: .skipsSubdirectoryDescendants)
                        }

                        if contents.count == 0 {
                            isExistFolder = false
                            folderTitle = URL(string: folderTitle)!.deletingPathExtension().path
                            folderURL = URL(fileURLWithPath: selectSongsPath)
                            contents = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: [.nameKey], options: .skipsSubdirectoryDescendants)
                        }

                        fileContents = contents
                    } catch {
                        //print(error.localizedDescription)
                    }

                    var files: [String] = []
                    for fileURL in fileContents {
                        let fileExtension = fileURL.pathExtension
                        if fileExtension == "mp3" || fileExtension == "wav" {
                            var fileName: String = ""
                            do {
                                let values = try fileURL.resourceValues(forKeys: [.nameKey])
                                fileName = values.name!
                                files.append(fileName)
                            } catch {
                                print(error.localizedDescription)
                            }

                            if let playlist = originPlaylist {
                                let destURL = URL(fileURLWithPath: playlist.fullPath).appendingPathComponent(fileName)
                                try? FileManager.default.copyItem(at: fileURL, to: destURL)
                            }

                            if isExistFolder == false {
                                try? FileManager.default.copyItem(at: fileURL, to: URL(fileURLWithPath: selectSongsPath).appendingPathComponent(folderTitle).appendingPathComponent(fileName))
                            }
                        }
                    }

                    folderURL = URL(fileURLWithPath: selectSongsPath).appendingPathComponent(folderTitle)
                    var songs: [Song] = []
                    for fileName in files {
                        var fileURL = folderURL.appendingPathComponent(fileName)
                        if let playlist = originPlaylist {
                            fileURL = URL(fileURLWithPath: playlist.fullPath).appendingPathComponent(fileName)
                        }
                        let fileTitle = (fileName as NSString).deletingPathExtension
                        let fileExtension = fileURL.pathExtension
                        print("\(fileExtension) === \(fileTitle)")
                        var song = playlist.song(with: fileTitle)
                        if song == nil {
                            song = Song(id: UUID().uuidString, filename: fileName, foldername: playlist.title, playlistId: playlist.id, isBundle: false)
                        }
                        playlist.add(song: song!)
                        songs.append(song!)
                    }

                    /*do {
                        let data = try PropertyListSerialization.data(fromPropertyList: filesInfo, format: .openStep, options: .bitWidth)
                        try data.write(to: infoURL)
                    } catch {
                        print(error.localizedDescription)
                    }*/

                    if let _ = originPlaylist {
                        try? FileManager.default.removeItem(at: folderURL)
                    }
                    if isExistFolder == false {
                        folderURL = URL(fileURLWithPath: selectSongsPath)
                        for fileName in files {
                            let fileURL = folderURL.appendingPathComponent(fileName)
                            try? FileManager.default.removeItem(at: fileURL)
                        }
                    }

                    if originPlaylist == nil {
                        PlaylistManager.shared.add(playlist: playlist)
                    }

                    DispatchQueue.main.async {
                        PlaylistManager.shared.savePlaylists()
                        completion(true, playlist, songs);
                    }
                }
            }
        }

        downloadTask.resume()
    }

    fileprivate func downloadSongContents(_ request: URLRequest, filename: String, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?, decisionHandler: ((WKNavigationActionPolicy) -> Void)?) {
        let requestedURL = request.url!
        if PlaylistManager.shared.isDownloadedSong(url: requestedURL.absoluteString, filename: filename) {
            decisionHandler?(.cancel)
            DispatchQueue.main.async {
                if self.isShowedAlertView {
                    let download = Download(request: request, filename: filename)
                    self.downloadQueue.append(download)
                } else {
                    self.downloadSongs(request: request, filename: filename)
                }
            }
        } else {
            decisionHandler?(.allow);
            self.downloadSongs(request: request) { data, response, error in

            }
        }
    }

    fileprivate func downloadSongs(request: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {

        DispatchQueue.main.async {
            SHKActivityIndicator.current().displayActivity("Loading...", isLock: true)
        }

        var urlRequest = (request as NSURLRequest).mutableCopy() as! URLRequest
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                urlRequest.setValue(cookie.value, forHTTPHeaderField: cookie.name)
            }
        }

        if self.isGoogleStore || self.isDropbox {
            for (key, value) in responseHeaders {
                urlRequest.setValue(value as? String, forHTTPHeaderField: key)
            }
        }

        var isShowedAlert = false
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in

            if let response = response {
                let headers = (response as! HTTPURLResponse).allHeaderFields
                var contentType = headers["Content-Type"] as! String
                var filename = response.suggestedFilename
                let fileExtension = URL(fileURLWithPath: filename ?? "").pathExtension
                if contentType == "application/binary" {
                    let fileType = FileNetworkManager.shared().contentType(request.url!)
                    if fileType != "" {
                        contentType = fileType
                    } else if fileExtension == "mp3" || fileExtension == "wav" {
                        contentType = "audio/mp3"
                    }
                } else if let filename = filename, contentType == "text/plain; charset=UTF-8" {
                    contentType = FileNetworkManager.shared().contentType(URL(string: filename)!)
                }

                if let data = data, (contentType == "audio/mpeg" || contentType == "audio/mp3" || contentType == "audio/wav" || contentType == "audio/wave") { // Music
                    let toFolderName = "Music Library"
                    let toFolderDir = (NSHomeDirectory() as NSString).appendingPathComponent("Library")
                    let toFolderPath = (toFolderDir as NSString).appendingPathComponent(toFolderName)

                    let localFileManager = FileManager.default

                    try? localFileManager.createDirectory(atPath: toFolderPath, withIntermediateDirectories: true, attributes: nil)

                    if filename == nil {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyyMMddhhmms"
                        let dateForFilename = dateFormatter.string(from: Date())
                        filename = dateForFilename.appending(".mp3")
                    }

                    let filePath = (toFolderPath as NSString).appendingPathComponent(filename!)
                    try? data.write(to: URL(fileURLWithPath: filePath))

                    let fileURL = URL(fileURLWithPath: filePath)
                    self.downloadedSongs.insert(fileURL)
                    let dict: [String: String] = [fileURL.absoluteString: request.url!.absoluteString];
                    self.downloadedURLs.append(dict)
                    self.assetURL = fileURL

                    DispatchQueue.main.async {
                        if self.downloadQueue.count == 0 {
                            let alertController = YJLCustomAlertController()
                            alertController.setTitle(APP_ALERT_TITLE, message: "Music has been downloaded successfully")

                            let moreAction = UIAlertAction(title: "Download More", style: .default) { action in
                                self.delegate?.didDownloadMore(self, Array(self.downloadedSongs), self.downloadedURLs)
                                self.downloadedSongs.removeAll()
                                self.downloadedURLs.removeAll()
                                if self.isGoogleStore {
                                    self.musicWebView.goBack()
                                }
                            }
                            let importAction = UIAlertAction(title: "Import Song", style: .default) { action in
                                DispatchQueue.main.async {
                                    SHKActivityIndicator.current().hide()
                                }

                                if self.assetURL != nil {
                                    self.delegate?.didImportSong(self, Array(self.downloadedSongs), self.downloadedURLs)
                                } else  {
                                    let alertController = YJLCustomAlertController()
                                    alertController.setTitle(APP_ALERT_TITLE, message: "You can`t use this music. Please use this music after download music from the iTunes Store.")
                                    let okAction = UIAlertAction(title: "OK", style: .default) { action in

                                    }
                                    alertController.alertController.addAction(okAction)
                                    self.present(alertController.alertController, animated: true, completion: nil)
                                }
                            }

                            alertController.alertController.addAction(moreAction)
                            alertController.alertController.addAction(importAction)

                            if !isShowedAlert {
                                isShowedAlert = true
                                self.present(alertController.alertController, animated: true, completion: nil)
                            }
                        } else {
                            self.checkDownloadQueue()
                        }
                        SHKActivityIndicator.current().hide()
                    }
                } else {
                    DispatchQueue.main.async {
                        SHKActivityIndicator.current().hide()
                    }
                }

                completionHandler?(data, response, error)
            }
        }

        dataTask.resume()
    }

    fileprivate func checkDownloadQueue() {
        if let download = self.downloadQueue.first {
            downloadSongs(request: download.request, filename: download.filename)
            downloadQueue.removeFirst()
        }
    }

    fileprivate func downloadSongs(request: URLRequest, filename: String?) {
        var message = "That song exists already!"
        if let filename = filename, filename != "" {
            message = "That song \"\(filename)\" exists already!"
        }

        let alertController = YJLCustomAlertController()
        alertController.setTitle(APP_ALERT_TITLE, message: message)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.isShowedAlertView = false
            self.checkDownloadQueue()
        }
        let downloadAction = UIAlertAction(title: "Download again", style: .default) { action in
            self.isShowedAlertView = false
            self.downloadSongs(request: request) { data, response, error in

            }
        }

        alertController.alertController.addAction(cancelAction)
        alertController.alertController.addAction(downloadAction)

        self.isShowedAlertView = true
        self.present(alertController.alertController, animated: true, completion: nil)
    }

    fileprivate func checkDownloadableContent(_ request: URLRequest, completionHandler: ((Bool, String) -> Void)?, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {
        var urlRequest = (request as NSURLRequest).mutableCopy() as! URLRequest
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                urlRequest.setValue(cookie.value, forHTTPHeaderField: cookie.name)
            }
        }
        for (key, value) in responseHeaders {
            urlRequest.setValue(value as? String, forHTTPHeaderField: key)
        }

        urlRequest.httpMethod = "OPTIONS"
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let response = response {
                if let response = response as? HTTPURLResponse {
                    let headers = response.allHeaderFields
                    if var contentType = headers["Content-Type"] as? String {
                        var filename = response.suggestedFilename
                        filename = filename?.replacingOccurrences(of: "+", with: " ")
                        if contentType == "application/binary" {
                            contentType = FileNetworkManager.shared().contentType(request.url!)
                        } else if let filename = filename, contentType.lowercased() == "text/plain; charset=utf-8" {
                            let url = URL(string: filename.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
                            contentType = FileNetworkManager.shared().contentType(url!)
                        } else if filename == "file", (self.lastFileName.contains(".mp3") || self.lastFileName.contains(".wav")) {
                            filename = self.lastFileName
                            contentType = "audio/mp3"
                        }

                        self.lastFileName = filename ?? ""
                        if let _ = data, (contentType == "audio/mpeg" || contentType == "audio/mp3" || contentType == "audio/wav" || contentType == "audio/wave" || contentType == "application/binary") { // Music
                            if filename == nil {
                                filename = ""
                            }
                            decisionHandler(.cancel);
                            completionHandler?(true, filename!)
                        } else {
                            decisionHandler(.allow);
                            completionHandler?(false, "")
                        }
                    } else {
                        decisionHandler(.allow);
                        completionHandler?(false, "")
                    }
                } else {
                    decisionHandler(.allow);
                    completionHandler?(false, "")
                }
            } else {
                decisionHandler(.allow)
            }
        }

        dataTask.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - IBAction
    @IBAction func actionCancel(_ sender: Any) {
        delegate?.musicDownloadViewControllerDidCancel(self)
    }

    @IBAction func actionReload(_ sender: Any) {
        self.musicWebView.reload()
    }
}

// MARK: - WKNavigationDelegate
extension MusicDownloadViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let requestedURL = navigationAction.request.url!
        if requestedURL.absoluteString == "about:blank" {
            decisionHandler(.allow)
            return
        }

        let lastPath = requestedURL.lastPathComponent
        if lastPath == "videoplayback" { /* || [requestedURL.absoluteString isEqualToString:@"about:blank"]*/
            decisionHandler(.cancel)
            return
        }

        if requestedURL.absoluteString == "https://open.spotify.com/album/" ||
            requestedURL.absoluteString == "https://apps.apple.com/app/" ||
            requestedURL.absoluteString == "https://adservice.google.com/" {
            decisionHandler(.allow)
            return
        }

        if requestedURL.absoluteString.contains("https://www.montanasky.net/myossongs/MyOsCollections-Zips/"), requestedURL.absoluteString != "https://www.montanasky.net/myossongs/MyOsCollections-Zips/index.php" {
            decisionHandler(.cancel)
            if UserDefaults.standard.bool(forKey: requestedURL.absoluteString) {
                var device: String = "iPhone"
                if UIDevice.current.userInterfaceIdiom == .pad {
                    device = "iPad"
                }

                let alertController = YJLCustomAlertController()
                alertController.setTitle(APP_ALERT_TITLE, message:"This file has already been downloaded to this \(device). Do you want to download again?")
                let okAction = UIAlertAction(title: "Yes", style: .default) { action in
                    self.downloadZipFileURL(requestedURL)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in

                }
                alertController.alertController.addAction(okAction)
                alertController.alertController.addAction(cancelAction)
                self.present(alertController.alertController, animated: true, completion: nil)
            } else {
                downloadZipFileURL(requestedURL)
            }
            return
        }

        if self.isGoogleStore {
            checkDownloadableContent(navigationAction.request, completionHandler: { isDownloadable, filename in
                if isDownloadable {
                    self.downloadSongContents(navigationAction.request, filename: filename, completionHandler: { data, response, error in

                    }, decisionHandler: nil)
                }
            }, decisionHandler: decisionHandler)
            //downloadSongContents(navigationAction.request, filename: "", completionHandler: { data, response, error in
            //}, decisionHandler: decisionHandler)
        } else {
            checkDownloadableContent(navigationAction.request, completionHandler: { isDownloadable, filename in
                if isDownloadable {
                    self.downloadSongContents(navigationAction.request, filename: filename, completionHandler: { data, response, error in

                    }, decisionHandler: nil)
                }
            }, decisionHandler: decisionHandler)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse, let headerFields = response.allHeaderFields as? [String: Any] {
            responseHeaders = headerFields
        }
        print(navigationResponse.response)
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SHKActivityIndicator.current().hide()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        SHKActivityIndicator.current().hide()
    }
}
