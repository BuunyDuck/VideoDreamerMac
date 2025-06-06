//
//  Download.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 8/11/22.
//

import UIKit

class Download: NSObject {
    var request: URLRequest!
    var filename: String = ""
    
    init(request: URLRequest, filename: String) {
        self.request = request
        self.filename = filename
    }
}
