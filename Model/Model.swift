//
//  Model.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/03/19.
//  Copyright © 2020 Koggy. All rights reserved.
//

import Foundation
import UIKit

class Model: NSObject{
    
    var title: String
    var link: String
    var thumbNail: UIImage?
    var detail: String?
    var keywords: [String]?

    init(title: String, link: String){
        self.title = title
        self.link = link
    }
   
    static var newsData = [Model]()
}

