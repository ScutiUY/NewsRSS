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
    static var shared = Parser()
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
        
        let request = URLRequest(url: url)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                fatalError("Invalid urlData")
                return
            }
            guard let data2String = String(data: data, encoding: .utf8) else { return }
            let parser = XMLParser(data: data2String.data(using: .utf8)!)
            parser.delegate = self
            parser.parse()
            
        }
        task.resume()
    }
    
    func linkParse (model: Model) {
        var contentStr = ""
        let url = URL(string: model.link)
        var treeArr = [Tree]()
        let rootNode = Tree("root")
        guard let reURL = url else {
            print("link 오류")
            return }
        let request = URLRequest(url: reURL)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            let html = self.incodingHTML(data)
            guard let html2String = html else {
                fatalError("html 오류")
            }
            print(model.link)
            var removeHeadHtml = html2String.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\t", with: "").getArrayAfterRegex(text: "<body.+</body>")
            let new = removeHeadHtml[0].replacingOccurrences(of: "</script>", with: "</script>\n").replacingOccurrences(of: "<script", with: "\n<script").replacingOccurrences(of: "<style", with: "\n<style").replacingOccurrences(of: "</style>", with: "</style>\n").components(separatedBy: "\n")
            for i in new {
                if i.contains("<script") || i.contains("<style") {
                    removeHeadHtml[0] = removeHeadHtml[0].replacingOccurrences(of: i, with: "")
                }
            }
            let newStr = removeHeadHtml[0].replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "</br>", with: "<br>").replacingOccurrences(of: "<br/>", with: "<br>").replacingOccurrences(of: "<br />", with: "<br>").replacingOccurrences(of: "<Br>", with: "<br>").replacingOccurrences(of: "<P", with: "<p").replacingOccurrences(of: "</P", with: "</p").replacingOccurrences(of: "amp-", with: "").replacingOccurrences(of: ">", with: ">\n").replacingOccurrences(of: "<", with: "\n<").trimmingCharacters(in: .whitespacesAndNewlines)

            let arr = newStr.components(separatedBy: "\n").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}.filter{$0 != ""}.filter{$0 != ""}.filter{!$0.contains("<!--")}
            arr.forEach{treeArr.append(Tree($0))}

            rootNode.initalizeDOM(rootNode: rootNode, treeArr: treeArr)

            rootNode.dfs(currentNode: rootNode, &contentStr)
            model.content = contentStr
            Parser.self.count+=1
            self.imageValidation(newStr: html2String, model: model)
            
        }
        task.resume()
    }
    func imageValidation(newStr: String, model: Model) {
        if newStr.getArrayAfterRegex(text: "og:image.+").isEmpty {
            DispatchQueue.main.async {
                model.thumbNail = UIImage(named: "No_Image")
            }
            NotificationCenter.default.post(name: Parser.parsingNoti, object: nil)
        } else if !newStr.getArrayAfterRegex(text: "og:image.+").isEmpty {
            DispatchQueue.global(qos: .userInteractive).async {
                DispatchQueue.main.async {
                    model.thumbNail = self.getImage(newStr.getArrayAfterRegex(text: "og:image.+")[0])
                }
                NotificationCenter.default.post(name: Parser.parsingNoti, object: nil)
            }
            
        }
    }
    func incodingHTML(_ data: Data) -> String? {
        var html = String(data: data, encoding: .utf8)
        guard html == nil else { return html }
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))
        html = String(data: data, encoding: encoding)
        guard html == nil else { return html }
        html = String(decoding: data, as: UTF8.self)
        return html
    }
    func getImage(_ arr: String) -> UIImage {
        guard let noImage = UIImage(named: "No_Image") else { fatalError("Invalid Image") }
        guard arr.contains("http") else { return noImage }
        var imageURL = arr.getArrayAfterRegex(text: "http.+\"")
        if imageURL == [] {
            imageURL = arr.getArrayAfterRegex(text: "http.+\'")
        }
        if imageURL == [] {
            
            return noImage
        }
        imageURL[0].removeLast()
        guard let urq = URL(string: imageURL[0]) else {
            return noImage
        }
        guard let imageData = try? Data(contentsOf: urq) else {
            return noImage
        }
        return UIImage(data: imageData)!
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
