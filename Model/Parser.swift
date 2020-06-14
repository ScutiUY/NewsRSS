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
    static var count = 0 {
        didSet {
            if count == Model.newsData.count {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Parser.parsingNoti, object: nil)
                }
            }
        }
    }
    static let parsingNoti = Notification.Name("finished parsing")
    private var currentElement: String = ""
    private var datalist: [[String:String]] = []
    private var detaildata: [String: String] = [:]
    static var blank: Bool = false
    
    
    func parseFeed (url: URL) {
        print("link파싱 시작")
        let request = URLRequest(url: url)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            guard var data2String = String(data: data, encoding: .utf8) else { return }
            data2String = data2String.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "").replacingOccurrences(of: "\r", with: "").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "&lt;", with: "").replacingOccurrences(of: "&gt;", with: "")
            print(data2String)
            let parser = XMLParser(data: data2String.data(using: .utf8)!)
            parser.delegate = self
            parser.parse()
            
        }
        task.resume()
    }
    
    func linkParse (model: Model) {
        var detail: String = ""
        var imageURL = ""
        var image: UIImage?
        let url = URL(string: model.link)
        var treeArr = [Tree]()
        var rootNode = Tree("root")
        guard let reURL = url else {
            print("link 오류")
            return }
        let request = URLRequest(url: reURL)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let html = self.incodingHTML(data)
            guard let html2String = html else { return }
            
            var newStr = html2String.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "").replacingOccurrences(of: "\r", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            newStr = newStr.replacingOccurrences(of: ">", with: ">\n")
            let arr = newStr.components(separatedBy: "\n")
            arr.forEach{treeArr.append(Tree($0))}
            
            rootNode.initalizeDOM(rootNode: rootNode, treeArr: treeArr)
            var contentStr = ""
            var dic: [Tree:Int] = rootNode.BFS(currentNode: rootNode)
            var newContent: Tree
            
            if dic.max{$0.value < $1.value} != nil {
                var newContent = dic.max{$0.value < $1.value}!.key
                rootNode.DFS(currentNode: newContent, &contentStr)
                model.content = contentStr
            } else if dic.max{$0.value < $1.value} == nil {
                var newContent = rootNode
                rootNode.DFS(currentNode: newContent, &contentStr)
                model.content = contentStr
            }
            
            
            if html2String.getArrayAfterRegex(text: "og:description\".+").isEmpty {
                if !html2String.getArrayAfterRegex(text: "name=\"description\".+").isEmpty{
                    detail = html2String.getArrayAfterRegex(text: "name=\"description\".+")[0]
                    detail = self.getDescription(detail)
                    model.detail = detail
                }
            } else if !html2String.getArrayAfterRegex(text: "og:description\".+").isEmpty {
                detail = html2String.getArrayAfterRegex(text: "og:description\".+")[0]
                detail = self.getDescription(detail)
                model.detail = detail
                
            }
            
            if !html2String.getArrayAfterRegex(text: "og:image\".+").isEmpty {
                imageURL = self.getImage(html2String.getArrayAfterRegex(text: "og:image\".+")[0])
                let ur = URL(string: imageURL)
                guard let urq = ur else { return }
                guard let imageData = try? Data(contentsOf: urq) else { return }
                image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    model.thumbNail = image
                    
                    NotificationCenter.default.post(name: Parser.parsingNoti, object: nil)
                }
            }
            
        }
        Parser.self.count+=1

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
        
}

extension Parser: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        Parser.blank = true
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if Parser.blank == true && currentElement == "title" || currentElement == "link"{
            detaildata[currentElement] = string
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
