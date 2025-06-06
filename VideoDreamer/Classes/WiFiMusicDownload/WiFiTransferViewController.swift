//
//  WiFiTransferViewController.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 8/6/22.
//

import UIKit
import IQKeyboardManager

@objc protocol WiFiTransferViewControllerDelegate {
    func didSelectFolder(_ playlist: Playlist)
    func didCreateFolder(_ playlist: Playlist)
    func didDeleteFolder(_ playlist: Playlist)
    func didUploadFile(_ song: Song)
    func didUploadFiles(_ files: [Song])
    func didRenameFolder(_ playlist: Playlist)
    func didRenameFile(_ song: Song)
}

@objc class WiFiTransferViewController: UIViewController {

    @IBOutlet var addressButton: UIButton!
    @IBOutlet var holdonLabel: UILabel!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordView: UIView!
    @IBOutlet var progressButton: UIButton!
    
    fileprivate var progressViewController: WiFiProgressViewController!
    fileprivate var panView: RMPanView!

    fileprivate var port: UInt = 8088
    fileprivate var password: String = ""
    fileprivate var isServerStarted: Bool = false
    
    fileprivate var droppedFilesCount: UInt = 0
    fileprivate var uploadedFilesCount: UInt = 0
    fileprivate var uploadedFiles: [Song] = []
    fileprivate var activityViewController: UIActivityViewController!
    
    var currentFolderName: String!
    var delegate: WiFiTransferViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = true
        
        startHttpServer()
        addressButton.setTitle(ServerManager.shared().serverAddress(), for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
        
        handleStopHttpServer()
    }
    
    fileprivate func initView() {
        loadCurrentFolderName()
        
        passwordTextField.attributedPlaceholder = NSMutableAttributedString(string: "PASSWORD", attributes: [.font: passwordTextField.font!, .foregroundColor: UIColor.lightGray])
        passwordTextField.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(handleKeyboardToolbarDone))
        passwordTextField.autocorrectionType = .no
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBackgroundNotification(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleForegroundNotification(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        checkPassword()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    fileprivate func loadCurrentFolderName() {
        if let folderName = UserDefaults.standard.string(forKey: "currentFolderName") {
            self.currentFolderName = folderName
        } else {
            self.currentFolderName = PlaylistManager.shared.defaultFolderName
        }
        let folderPath = PlaylistManager.shared.selectSongsDirectory + currentFolderName
        if FileManager.default.fileExists(atPath: folderPath) == false {
            try? FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    fileprivate func checkPassword() {
        if let password = UserDefaults.standard.string(forKey: APP_WIFI_HTTP_PASSWORD) {
            self.password = password
        } else {
            self.password = ServerManager.shared().generateRandomPassword()
        }
        passwordTextField.text = password;
    }

    fileprivate func startHttpServer() {
        if isServerStarted == true {
            return
        }

        var message = ""
        let success = ServerManager.shared().startDownloadServer(port, password: password, folder: "/\(currentFolderName!)/")
        if success {
            message = "This device and PC must use the same WiFi network.\n\nPlease keep this page open while you transfer music."
        } else {
            message = "Filed to start the web server. Please try again."
        }
        if ServerManager.shared().serverAddress() == "" {
            message = "We can't really use IPv6 anyway as it doesn't work great with HTTP URLs in practice"
            isServerStarted = false
        } else {
            isServerStarted = true
        }
        holdonLabel.text = message
        ServerManager.shared().delegate = self
    }

    fileprivate func stopHttpServer() {
        if isServerStarted == false {
            return
        }
        
        isServerStarted = false
        ServerManager.shared().stopDownloadServer()
    }

    @objc fileprivate func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        passwordTextField.isUserInteractionEnabled = false
    }

    @objc fileprivate func handleKeyboardToolbarDone() {
        if passwordTextField.text!.count == 0 {
            UserDefaults.standard.removeObject(forKey: APP_WIFI_HTTP_PASSWORD)
            passwordTextField.text = password
        } else {
            password = passwordTextField.text!
            UserDefaults.standard.set(passwordTextField.text, forKey: APP_WIFI_HTTP_PASSWORD)
        }
        passwordTextField.isUserInteractionEnabled = false
        stopHttpServer()
        startHttpServer()
    }

    @objc fileprivate func handleBackgroundNotification(_ notification: Notification) {
        if let topViewController = UIApplication.shared.topViewController(), topViewController == self {
            perform(#selector(handleStopHttpServer), with: nil, afterDelay: 60.0)
        }
    }

    @objc fileprivate func handleForegroundNotification(_ notification: Notification) {
        if let topViewController = UIApplication.shared.topViewController(), topViewController == self {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            startHttpServer()
        }
    }

    @objc fileprivate func handleStopHttpServer() {
        DispatchQueue.main.async {
            self.stopHttpServer()
            if self.uploadedFiles.count > 0 {
                self.droppedFilesCount = self.uploadedFilesCount
                self.delegate?.didUploadFiles(self.uploadedFiles)
                self.uploadedFiles.removeAll()
            }
        }
    }
    
    fileprivate func playlistName(for zipName: String) -> String {
        let fileExtension = URL(fileURLWithPath: zipName).pathExtension
        let name: String = zipName.replacingOccurrences(of: ".\(fileExtension)", with: "")
        var title: String = name
        var index: Int = 2
        while PlaylistManager.shared.playlist(with: title) != nil {
            title = "\(name) \(index)"
            index += 1
        }
        return title
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
    @IBAction func actionBack(_ sender: Any) {
        stopHttpServer()
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func actionOTA(_ sender: Any) {
        stopHttpServer()
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func actionDownload(_ sender: Any) {
        actionBack(sender)
    }

    @IBAction func actionHttpAddress(_ sender: UIButton) {
        self.view.endEditing(true)
        let serverAddress = ServerManager.shared().serverAddress()
        if serverAddress == "" {
            return
        }
        passwordTextField.isUserInteractionEnabled = false
        self.activityViewController = UIActivityViewController(activityItems: [serverAddress], applicationActivities: [])
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.activityViewController.modalPresentationStyle = .popover
            self.activityViewController.popoverPresentationController?.sourceView = self.view
            self.activityViewController.popoverPresentationController?.sourceRect = sender.frame
        } else {
            self.activityViewController.modalPresentationStyle = .fullScreen
        }
        
        present(self.activityViewController, animated: true, completion: nil)
    }

    @IBAction func actionChangePassword(_ sender: Any) {
        passwordTextField.isUserInteractionEnabled = true
        passwordTextField.becomeFirstResponder()
        passwordTextField.selectAll(nil)
    }

    @IBAction func actionProgresses(_ sender: UIButton?) {
        if progressViewController == nil {
            let nibName: String = UIDevice.current.userInterfaceIdiom == .phone ? "WiFiProgressViewController" : "WiFiProgressViewController_iPad"
            progressViewController = WiFiProgressViewController(nibName: nibName, bundle: nil)
            progressViewController.folderPath = "\(PlaylistManager.shared.selectSongsDirectory)\(currentFolderName!)"
        }
        
        if panView == nil {
            panView = RMPanView(view: progressViewController.view)
            panView.maxHeight = self.view.frame.size.height - self.view.safeAreaInsets.top
            progressViewController.delegate = self
            addChild(progressViewController)
        }
        
        if panView.visible == true {
            return
        }
        
        panView.show(in: self.view, offset: 0)
        progressViewController.reloadData()
    }
}

// MARK: - UITextFieldDelegate
extension WiFiTransferViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            UserDefaults.standard.removeObject(forKey: APP_WIFI_HTTP_PASSWORD)
            textField.text = password
        } else {
            password = textField.text!
            UserDefaults.standard.set(textField.text, forKey: APP_WIFI_HTTP_PASSWORD)
        }
        textField.isUserInteractionEnabled = false
        stopHttpServer()
        startHttpServer()
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate
extension WiFiTransferViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIControl {
            return false
        }
        
        return true
    }
}

// MARK: - ServerManagerDelegate
extension WiFiTransferViewController: ServerManagerDelegate {
    func didSelectFolder(_ name: String) {
        if name == "/" || name == "" {
            return
        }
        currentFolderName = name
        //delegate?.didSelectFolder(self.currentPlaylist)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: APP_WIFI_SELECT_FOLDER), object: nil)
    }
    
    func didCreateFolder(_ name: String) {
        //let playlist = Playlist(id: UUID().uuidString, title: name)
        //PlaylistManager.shared.add(playlist: playlist)
        //PlaylistManager.shared.savePlaylists()
        //delegate?.didCreateFolder(playlist)
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: APP_SELECTSONGS_UPDATED), object: playlist)
    }
    
    func didRemoveFolder(_ name: String) {
        //if let playlist = PlaylistManager.shared.playlist(with: name) {
        //    PlaylistManager.shared.remove(playlist: playlist)
        //    delegate?.didDeleteFolder(playlist)
        //}
    }
    
    func didMoveItem(_ fromPath: String, toPath: String) {
        /*let range = (fromPath as NSString).range(of: PlaylistManager.shared.selectSongsDirectory)
        if range.location == NSNotFound {
            return
        }
        
        let folderPath = (fromPath as NSString).substring(from: range.location + range.length)
        var folders = folderPath.components(separatedBy: "/")
        var playlist: Playlist!
        var isFolder: Bool = true
        var oldFileName = ""
        for i in 0 ..< folders.count {
            let folderName = folders[i]
            if let folder = PlaylistManager.shared.playlist(with: folderName) {
                playlist = folder
            } else {
                isFolder = false
                oldFileName = folderName
            }
        }

        if isFolder {
            folders = toPath.components(separatedBy: "/")
            let folderName = folders.last!
            if PlaylistManager.shared.playlist(with: folderName) == nil {
                playlist.changeTitle(folderName)
                self.delegate?.didRenameFolder(playlist)
            } else {
                let alertController = UIAlertController(title: APP_ALERT_TITLE, message: "The new folder name exists already.", preferredStyle: .alert);
                let okAction = UIAlertAction(title: "OK", style: .default) { action in
                    
                }
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        } else {
            folders = toPath.components(separatedBy: "/")
            let fileName = folders.last!
            let song = PlaylistManager.shared.song(filename: oldFileName)!
            playlist = PlaylistManager.shared.playlist(with: song.foldername)
            if playlist.song(filename: fileName) == nil {
                song.changeTitle(fileName)
                self.delegate?.didRenameFile(song)
            } else {
                let alertController = UIAlertController(title: APP_ALERT_TITLE, message: "The new file name exists already.", preferredStyle: .alert);
                let okAction = UIAlertAction(title: "OK", style: .default) { action in
                    
                }
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)
            }
        }*/
    }
    
    func didRemoveFile(_ filename: String, parent name: String) {
        //if let song = currentPlaylist.song(filename: filename) {
        //    currentPlaylist.remove(song: song)
        //}
    }
    
    func didUploadFile(_ fileURL: URL, playlist name: String) -> Bool {
        let fileExtension = fileURL.pathExtension
        if !ServerManager.shared().allowedFileExtensions().contains(fileExtension) {
            return false
        }
        if fileExtension == "zip" {
            var playlist: Playlist!
            if let pllist = PlaylistManager.shared.playlist(with: name) {
                playlist = pllist
            } else {
                let playlistName = playlistName(for: name)
                playlist = Playlist(id: UUID().uuidString, title: playlistName)
                try? FileManager.default.createDirectory(atPath: playlist.fullPath, withIntermediateDirectories: true, attributes: nil)
                PlaylistManager.shared.add(playlist: playlist)
                PlaylistManager.shared.savePlaylists()
                delegate?.didCreateFolder(playlist)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: APP_SELECTSONGS_UPDATED), object: playlist)
            }
            
            DispatchQueue.main.async {
                SHKActivityIndicator.current().displayActivity("Please Hang On!\nWe are building your playlist!", isLock: true)
            }

            DispatchQueue.global(qos: .background).sync {
                var folderTitle = fileURL.lastPathComponent
                let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderTitle)
                try? FileManager.default.createDirectory(at: tempURL, withIntermediateDirectories: true, attributes: nil)
                SSZipArchive.unzipFile(atPath: fileURL.path, toDestination: tempURL.path)
                try? FileManager.default.removeItem(at: fileURL)
                
                var unzipURL: URL = tempURL
                var fileContents: [URL] = []
                do {
                    var contents = try FileManager.default.contentsOfDirectory(at: unzipURL, includingPropertiesForKeys: [.nameKey], options: .skipsSubdirectoryDescendants)
                    if contents.count == 0 {
                        folderTitle = URL(string: folderTitle)!.deletingPathExtension().path
                        unzipURL = unzipURL.appendingPathComponent(folderTitle)
                        contents = try FileManager.default.contentsOfDirectory(at: unzipURL, includingPropertiesForKeys: [.nameKey], options: .skipsSubdirectoryDescendants)
                    } else {
                        let values = try contents[0].resourceValues(forKeys: [.isDirectoryKey])
                        if values.isDirectory == true {
                            folderTitle = URL(string: folderTitle)!.deletingPathExtension().path
                            unzipURL = unzipURL.appendingPathComponent(folderTitle)
                            contents = try FileManager.default.contentsOfDirectory(at: unzipURL, includingPropertiesForKeys: [.nameKey], options: .skipsSubdirectoryDescendants)
                        }
                    }
                    fileContents = contents
                } catch {
                    //print(error.localizedDescription)
                }

                let folderURL = URL(fileURLWithPath: playlist.fullPath)
                var songs: [Song] = []
                for file in fileContents {
                    let fileName = file.lastPathComponent
                    let fileTitle = (fileName as NSString).deletingPathExtension
                    if playlist.song(with: fileTitle) == nil {
                        try? FileManager.default.copyItem(at: file, to: folderURL.appendingPathComponent(fileName))
                        let song = Song(id: UUID().uuidString, filename: fileName, foldername: playlist.title, playlistId: playlist.id, isBundle: false)
                        playlist.add(song: song)
                        songs.append(song)
                    }
                }
                try? FileManager.default.removeItem(at: tempURL)

                DispatchQueue.main.async {
                    SHKActivityIndicator.current().hide()
                    PlaylistManager.shared.savePlaylists()
                    self.delegate?.didUploadFiles(songs)
                }
            }
            return true
        } else {
            if let playlist = PlaylistManager.shared.playlist(with: name) {
                let song = Song(id: UUID().uuidString, filename: fileURL.lastPathComponent, foldername: name, playlistId: playlist.id, isBundle: false)
                playlist.add(song: song)
                PlaylistManager.shared.savePlaylists()
                delegate?.didUploadFile(song)
            }
            return false
        }
    }
    
    func didDropFiles(_ files: [Any]) {
        actionProgresses(nil)
        
        progressViewController.addDownloadFiles(files as! [[String: Any]])
        self.droppedFilesCount += UInt(files.count)
        
        if self.activityViewController != nil {
            self.activityViewController.dismiss(animated: true) {
                self.activityViewController = nil
            }
        }
    }
    
    func didUploadFile(_ file: [AnyHashable : Any], progress: Float) {
        if progressViewController == nil {
            return
        }
        
        progressViewController.updateDownloadFile(file as! [String: Any])
    }
    
    func serverManager(_ serverManager: ServerManager, didRenameFolder name: String) {
        
    }
    
    func serverManager(_ serverManager: ServerManager, didRenameFile fileURL: URL, playlist name: String) {
        
    }
}

extension WiFiTransferViewController: WiFiProgressViewControllerDelegate {
    func didPressHideButton(_ controller: WiFiProgressViewController) {
        panView.hide()
    }
}
