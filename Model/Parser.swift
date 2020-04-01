//
//  Parser.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/03/23.
//  Copyright © 2020 Koggy. All rights reserved.
//

import Foundation
import UIKit
class Parser: NSObject {
    static let parsingNoti = Notification.Name("finished parsing")
    private var currentElement: String = ""
    private var datalist: [[String:String]] = []
    private var detaildata: [String: String] = [:]
    private var blank: Bool = false
    
    func parseFeed (url: URL) {
        let request = URLRequest(url: url)
        let urlSession = URLSession.shared
        DispatchQueue.global(qos: .userInitiated).async {
            let task = urlSession.dataTask(with: request) { (data, response, error) in
                guard let data = data else { return }
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Parser.parsingNoti, object: nil)
                }

            }
            task.resume()
        }
    }
    
    func linkParse (model: Model) {
        var detail: String = ""
        var imageURL = ""
        var image: UIImage?
        let url = URL(string: model.link)
        guard let reURL = url else {
            print("link 오류")
            return }
        let request = URLRequest(url: reURL)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let html = String(decoding: data, as: UTF8.self)
            if !html.getArrayAfterRegex(text: "<meta property=\"og:description\".+").isEmpty {
                detail = html.getArrayAfterRegex(text: "<meta property=\"og:description\".+")[0]
                detail = self.getDescription(arr: detail)
                
                DispatchQueue.main.async {
                    model.detail = detail
                    NotificationCenter.default.post(name: Parser.parsingNoti, object: nil)
                }
            }
        }
        task.resume()
    }
    
    func getDescription(arr: String) -> String {
        var reArr = ""
        reArr = arr.replacingOccurrences(of: "<meta", with: "").replacingOccurrences(of: "property=\"og:description\"", with: "").replacingOccurrences(of: "content=\"", with: "").replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&quot;", with: "\"").replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&#34;", with: "\"").replacingOccurrences(of: "\" />", with: "").trimmingCharacters(in: .whitespaces)
        return reArr
    }
    func getImage(arr: String) {
        
    }
}

extension Parser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        blank = true
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if blank == true && currentElement == "title" || currentElement == "link"{
            detaildata[currentElement] = string.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "").replacingOccurrences(of: "\r", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "link"{
            datalist += [detaildata]
            if detaildata["title"] != "주요 뉴스 - Google 뉴스"{
                let newModel = Model(title: detaildata["title"]!, link: detaildata["link"]!)
                Model.newsData.append(newModel)
                linkParse(model: newModel)
            }
        }
        blank = false
    }
}



