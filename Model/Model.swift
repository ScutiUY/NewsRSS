//
//  Model.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/03/19.
//  Copyright © 2020 Koggy. All rights reserved.
//

import Foundation
import UIKit
class Model {
    var title: String
    var thumbNail: UIImage?
    var detail: String
    var keywords: [String]
    init(title: String, detail: String, keywords: [String]){
        self.title = title
        self.detail = detail
        self.keywords = keywords
    }
    
    static let arr = [
        Model(title: "Fruit", detail: "is fruitis fruitis fruitis fruitis fruitis fruit", keywords: ["banana","melon","cookie"]),
        Model(title: "Food", detail: "is Food and some how many people say 노엘갤래거민어리;ㅁㄴ아ㅓㄹㅁ;니아ㅓㄹㅁㄴㅇㄹ", keywords: ["chocolate","melon","heart"]),
        Model(title: "갬정과 지킬것들 키키키키키캬캬캬캬호호호호샘픎ㅇㄴㄹㅁㄴㅇㄹㅁㅁㅇㄴ", detail: "이거슨 샘플입니다 이거슨 샘플입니다 이거슨 샘플입니다 이거슨 샘플입니다 이거슨 샘플입니다 이거슨 샘플입니다", keywords: ["Free","Peace","Love"])
    ]
    
}
