//
//  WiFiProgressViewController.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 8/8/22.
//

import UIKit
import AVFoundation

@objc protocol WiFiProgressViewControllerDelegate {
    func didPressHideButton(_ controller: WiFiProgressViewController)
}

@objc class WiFiProgressViewController: UIViewController {

    @IBOutlet weak var filesTableView: UITableView!
    
    fileprivate var downloadFiles: [[String: Any]] = []
    fileprivate var downloadingFile: [String: Any]!
    fileprivate var downloadingIndex: Int = 0
    
    var folderPath: String!
    var delegate: WiFiProgressViewControllerDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            filesTableView.register(UINib(nibName: "WiFiDownloadViewCell", bundle: nil), forCellReuseIdentifier: "WiFiDownloadViewCell")
        } else {
            filesTableView.register(UINib(nibName: "WiFiDownloadViewCell_iPad", bundle: nil), forCellReuseIdentifier: "WiFiDownloadViewCell")
        }
        
        self.view.backgroundColor = .black
    }
    
    func addDownloadFiles(_ files: [[String: Any]]) {
        downloadFiles.append(contentsOf: files)
        reloadData()
    }
    
    func updateDownloadFile(_ file: [String: Any]) {
        if downloadingFile != nil, downloadingIndex != NSNotFound, (downloadingFile["name"] as! String) == (file["name"] as! String) {
            if downloadingFile["progress"] as! Double == 1.0 {
                return
            }
            var dictionary = downloadingFile!
            dictionary["progress"] = file["progress"]
            if dictionary["progress"] as! Double >= 0.85 {
                dictionary["progress"] = 1.0
            }
            downloadFiles[downloadingIndex] = dictionary
            downloadingFile = dictionary
            let indexPath = IndexPath(row: downloadingIndex, section: 0)
            filesTableView.scrollToRow(at: indexPath, at: .top, animated: true)
            if let cell = filesTableView.cellForRow(at: indexPath) as? WiFiDownloadViewCell {
                cell.file = dictionary
            }
        } else {
            let index = findDownloadFile(file)
            if index != NSNotFound {
                downloadFiles[index] = file
                downloadingFile = file
                downloadingIndex = index
                let indexPath = IndexPath(row: index, section: 0)
                filesTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                if let cell = filesTableView.cellForRow(at: indexPath) as? WiFiDownloadViewCell {
                    cell.file = file
                }
            }
        }
    }
    
    func reloadData() {
        filesTableView.reloadData()
    }

    fileprivate func findDownloadFile(_ file: [String: Any]) -> Int {
        if let index = downloadFiles.firstIndex(where: { file2 in
            return file["name"] as! String == file2["name"] as! String
        }) {
            return index
        }

        let existFiles = downloadFiles.filter { object in
            return (file["name"] as! String) == (object["name"] as! String)
        }
        
        if existFiles.count > 0 {
            return downloadFiles.firstIndex { object in
                return (object["name"] as! String) == (existFiles.first!["name"] as! String)
            }!
        }

        return NSNotFound
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - IBActionn
    @IBAction func hideButtonPressed(_ sender: UIButton) {
        delegate?.didPressHideButton(self)
    }
}

extension WiFiProgressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WiFiDownloadViewCell", for: indexPath) as! WiFiDownloadViewCell
        cell.index = indexPath.row
        cell.file = downloadFiles[indexPath.row]
        cell.selectionStyle = .none
        
        let audioURL = URL(fileURLWithPath: self.folderPath).appendingPathComponent(cell.file["name"] as! String)
        let asset = AVURLAsset(url: audioURL)
        let metadatas = asset.metadata
        var thumbnail: UIImage? = nil
        for item in metadatas {
            if item.commonKey != nil, item.commonKey!.rawValue == "artwork" {
                thumbnail = UIImage(data: item.value as! Data)
                break
            }
        }
        
        if thumbnail != nil {
            cell.thumbnail = thumbnail
        } else {
            cell.thumbnail = UIImage(named: "audio_img")
        }
        
        return cell;
    }
}

extension WiFiProgressViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 60.0
        } else {
            return 80.0
        }
    }
}
