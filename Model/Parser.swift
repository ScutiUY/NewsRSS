//
//  Parser.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/03/23.
//  Copyright © 2020 Koggy. All rights reserved.
//

import Foundation
import UIKit
import Untagger
class Parser: NSObject {
    static let parsingNoti = Notification.Name("finished parsing")
    private var currentElement: String = ""
    private var datalist: [[String:String]] = []
    private var detaildata: [String: String] = [:]
    static var blank: Bool = false
    
    func parseFeed (url: URL) {
        let request = URLRequest(url: url)
        let urlSession = URLSession.shared
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
            let html = self.incodingHTML(data)
            guard let html2String = html else { return }
            
            if html2String.getArrayAfterRegex(text: "og:description\".+").isEmpty {
                if !html2String.getArrayAfterRegex(text: "name=\"description\".+").isEmpty{
                    detail = html2String.getArrayAfterRegex(text: "name=\"description\".+")[0]
                    detail = self.getDescription(detail)
                    self.strCheck(str: detail, model: model)
                    model.detail = detail
                    
                }
            } else if !html2String.getArrayAfterRegex(text: "og:description\".+").isEmpty {
                detail = html2String.getArrayAfterRegex(text: "og:description\".+")[0]
                detail = self.getDescription(detail)
                self.strCheck(str: detail, model: model)
                model.detail = detail
                
            }
            
            if !html2String.getArrayAfterRegex(text: "og:image\".+").isEmpty {
                imageURL = self.getImage(html2String.getArrayAfterRegex(text: "og:image\".+")[0])
                let ur = URL(string: imageURL)
                guard let urq = ur else { return }
                let imageData = try? Data(contentsOf: urq)
                image = UIImage(data: imageData!)
                DispatchQueue.main.async {
                    model.thumbNail = image
                    NotificationCenter.default.post(name: Parser.parsingNoti, object: nil)
                }
            }
            
            
            if html2String.contains("<div class=\"article-text\">") {
                let arrs = html2String.components(separatedBy: "<div class=\"article-text\">")
                           let pasingStr = "<div class=\"article-text\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div id=\"article_body\"") {
                let arrs = html2String.components(separatedBy: "<div id=\"article_body\"")
                           let pasingStr = "<div id=\"article_body\"" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div class=\"article_main\">") {
                let arrs = html2String.components(separatedBy: "<div class=\"article_main\">")
                           let pasingStr = "<div class=\"article_main\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div id=\"news_body_id\"") {
                let arrs = html2String.components(separatedBy: "<div id=\"news_body_id\"")
                           let pasingStr = "<div id=\"news_body_id\"" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div class=\"article_wrap\" id=\"newsContent\">") {
                let arrs = html2String.components(separatedBy: "<div class=\"article_wrap\" id=\"newsContent\">")
                           let pasingStr = "<div class=\"article_wrap\" id=\"newsContent\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div id=\"article\">") {
                let arrs = html2String.components(separatedBy: "<div id=\"article\">")
                           let pasingStr = "<div id=\"article\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div class=\"article-text\">") {
                let arrs = html2String.components(separatedBy: "<div id=\"article\">")
                           let pasingStr = "<div id=\"article\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div class=\"article-story\" id=\"article_story\" itemprop=\"articleBody\">") {
                let arrs = html2String.components(separatedBy: "<div class=\"article-story\" id=\"article_story\" itemprop=\"articleBody\">")
                           let pasingStr = "<div class=\"article-story\" id=\"article_story\" itemprop=\"articleBody\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div id=\"article_body\" itemprop=\"articleBody\">") {
                let arrs = html2String.components(separatedBy: "<div id=\"article_body\" itemprop=\"articleBody\">")
                           let pasingStr = "<div id=\"article_body\" itemprop=\"articleBody\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div id=\"news_body_id\" class=\"news_body ff_set_malgun fz_set_middle\" itemprop=\"articleBody\">") {
                let arrs = html2String.components(separatedBy: "<div id=\"news_body_id\" class=\"news_body ff_set_malgun fz_set_middle\" itemprop=\"articleBody\">")
                           let pasingStr = "<div id=\"news_body_id\" class=\"news_body ff_set_malgun fz_set_middle\" itemprop=\"articleBody\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div id=\"pnlContent\" itemprop=\"articleBody\">") {
                let arrs = html2String.components(separatedBy: "<div id=\"pnlContent\" itemprop=\"articleBody\">")
                           let pasingStr = "<div id=\"pnlContent\" itemprop=\"articleBody\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div id=\"article_body\" itemprop=\"articleBody\" class=\"article_body mg fs4\">") {
                let arrs = html2String.components(separatedBy: "<div id=\"article_body\" itemprop=\"articleBody\" class=\"article_body mg fs4\">")
                           let pasingStr = "<div id=\"article_body\" itemprop=\"articleBody\" class=\"article_body mg fs4\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div class=\"article\" id=\"article_body_content\">") {
                let arrs = html2String.components(separatedBy: "<div class=\"article\" id=\"article_body_content\">")
                           let pasingStr = "<div class=\"article\" id=\"article_body_content\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div id=\"news_body_id\" class=\"news_body ff_set_malgun fz_set_middle\" itemprop=\"articleBody\">") {
                let arrs = html2String.components(separatedBy: "<div id=\"news_body_id\" class=\"news_body ff_set_malgun fz_set_middle\" itemprop=\"articleBody\">")
                           let pasingStr = "<div id=\"news_body_id\" class=\"news_body ff_set_malgun fz_set_middle\" itemprop=\"articleBody\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div class=\"article_cont_area\">") {
                let arrs = html2String.components(separatedBy: "<div class=\"article_cont_area\">")
                           let pasingStr = "<div class=\"article_cont_area\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div id=\"article_body\" itemprop=\"articleBody\" class=\"article_body mg fs4\">") {
                let arrs = html2String.components(separatedBy: "<div id=\"article_body\" itemprop=\"articleBody\" class=\"article_body mg fs4\">")
                           let pasingStr = "<div id=\"article_body\" itemprop=\"articleBody\" class=\"article_body mg fs4\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div class=\"content-box\" id=\"divNewsContent\">") {
                let arrs = html2String.components(separatedBy: "<div class=\"content-box\" id=\"divNewsContent\">")
                           let pasingStr = "<div class=\"content-box\" id=\"divNewsContent\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div id=\"news_body_id\" class=\"news_body ff_set_malgun fz_set_middle\" itemprop=\"articleBody\">") {
                let arrs = html2String.components(separatedBy: "<div id=\"news_body_id\" class=\"news_body ff_set_malgun fz_set_middle\" itemprop=\"articleBody\">")
                           let pasingStr = "<div id=\"news_body_id\" class=\"news_body ff_set_malgun fz_set_middle\" itemprop=\"articleBody\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div class=\"cnt_view news_body_area\">") {
                let arrs = html2String.components(separatedBy: "<div class=\"cnt_view news_body_area\">")
                           let pasingStr = "<div class=\"cnt_view news_body_area\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div class=\"text_area\">") {
                let arrs = html2String.components(separatedBy: "<div class=\"text_area\">")
                           let pasingStr = "<div class=\"text_area\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div class=\"article_txt\"") {
                let arrs = html2String.components(separatedBy: "<div class=\"article_txt\"")
                           let pasingStr = "<div class=\"article_txt\"" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div class=\"news_txt\"") {
                let arrs = html2String.components(separatedBy: "<div class=\"news_txt\"")
                           let pasingStr = "<div class=\"news_txt\"" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else if html2String.contains("<div id=\"pnlContent\" itemprop=\"articleBody\">") {
                let arrs = html2String.components(separatedBy: "<div id=\"pnlContent\" itemprop=\"articleBody\">")
                           let pasingStr = "<div id=\"pnlContent\" itemprop=\"articleBody\">" + arrs[1]
                DispatchQueue.main.async {
                    model.content = pasingStr
                }
            } else {
                UntaggerManager.sharedInstance.getText(url: reURL) { (title, body, source, error) in
                    if error == nil {
                        guard let unwrapedBody = body else { return }
                        DispatchQueue.main.async {
                            model.content = unwrapedBody
                        }
                    }
                    if let error = error {
                        print("Error: \(error.message)")
                    }
                }
            }
            
            
            
            
            
            
        }
        task.resume()
    }
    
    func incodingHTML(_ data: Data) -> String? {
        var html = String(data: data, encoding: .utf8)
        if html == nil{
            let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))
            html = String(data: data, encoding: encoding)
            if html == nil {
                html = String(decoding: data, as: UTF8.self)
            }
        }
        return html
    }
    func getDescription(_ arr: String) -> String {
        var reArr = ""
        reArr = arr.replacingOccurrences(of: "<meta", with: "").replacingOccurrences(of: "og:description\"", with: "").replacingOccurrences(of: "content=\"", with: "").replacingOccurrences(of: "&nbsp;", with: " ").replacingOccurrences(of: "&quot;", with: "\"").replacingOccurrences(of: "&#39;", with: "'").replacingOccurrences(of: "&#34;", with: "\"").replacingOccurrences(of: "\" />", with: "").replacingOccurrences(of: "name=", with: "").replacingOccurrences(of: "description\"", with: "").trimmingCharacters(in: .whitespaces)
        return reArr
    }
    func getImage(_ arr: String) -> String {
        var reArr = ""
        reArr = arr.replacingOccurrences(of: "og:image\"", with: "").replacingOccurrences(of: "content=\"", with: "").replacingOccurrences(of: "\" />", with: "").replacingOccurrences(of: "\">", with: "").replacingOccurrences(of: "\"/>", with: "").trimmingCharacters(in: .whitespaces)
        return reArr
    }
    func strCheck(str: String, model: Model) {
        var i = 0
        var j = 0
        var key = [[String]]()
        let strArr = str.getArrayAfterRegex(text: "[가-힣]+")
        for i in 0..<strArr.count{
            
            var value = [String]()
            for j in 0..<strArr.count{
                if strArr[i] == strArr[j] {
                    value.append(strArr[i])
                }
            }
            key.append(value)
        }
        key = key.sorted(by: { (first, second) -> Bool in
            return first[0] < second[0]
        }).sorted(by: { (first, second) -> Bool in
            return first.count > second.count
        })
        i=0
        if key.count != 0{
            for _ in 0..<key.count-1{
                if key[i] == key[i+1] {
                    key.remove(at: i)
                } else {
                    i=i+1
                }
            }
            var newArr = [String]()
            newArr.append(key[0][0])
            newArr.append(key[1][0])
            newArr.append(key[2][0])
            DispatchQueue.main.async {
                model.keywords = newArr
                NotificationCenter.default.post(name: Parser.parsingNoti, object: nil)
            }
        }
    }
}
extension Parser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        Parser.blank = true
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if Parser.blank == true && currentElement == "title" || currentElement == "link"{
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
        Parser.blank = false
    }
}



