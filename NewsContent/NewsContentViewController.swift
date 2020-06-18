//
//  NewsViewController.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/03/20.
//  Copyright © 2020 Koggy. All rights reserved.
//

import UIKit
import SnapKit
class NewsContentViewController: UIViewController {
    
    private let webView: UIWebView = {
        var webView = UIWebView()
        webView.backgroundColor = .white
        webView.allowsInlineMediaPlayback = true
        webView.mediaPlaybackRequiresUserAction = false
        webView.contentMode = .scaleToFill
        webView.scalesPageToFit = false
        return webView
    }()
    
    private let spinner = UIActivityIndicatorView(style: .gray)
    let articleTitleLeft = "<h2><span class=\"title\">"
    let articleTitleRight = "</span></h2>"
    var articleTitle = ""
    var url = ""
    var htmlStr = """
        
    """
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
        setURL(url: url)
    }
    
    private func setLayout() {
        navigationItem.largeTitleDisplayMode = .never
        view.addSubview(webView)
        webView.snp.makeConstraints { (m) in
            m.width.equalTo(view.snp.width)
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func setURL(url: String) {
        guard URL(string: url) != nil else { return }
        print(htmlStr)
        let size = """
        <html lang=\"ja\">
        <head>"
        <meta charset=\"UTF-8\">
        <style type=\"text/css\">
        html{margin:0;padding:0;}
        body {
        margin: 0;
        padding: 0;
        font-size: 90%;
        line-height: 1.6;
        }
        img{
        position: absolute;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0;
        margin: auto;
        max-width: 100%;
        max-height: 100%;
        }
        </style>
        </head>
        \(htmlStr)
        </html>
        """
        webView.loadHTMLString(articleTitleLeft+articleTitle+articleTitleRight+size, baseURL: nil)
    }
    
}

