//
//  MainViewController.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/03/18.
//  Copyright © 2020 Koggy. All rights reserved.
//

import UIKit
import SnapKit

class NewsListViewController: UIViewController {
    
    private let newsTableView: UITableView = {
        var tableView = UITableView()
        return tableView
    }()
    lazy var refreshController: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.red
        return refreshControl
    }()
    
    
    private let url = URL(string: "https://news.google.com/rss?hl=ko&gl=KR&ceid=KR:ko")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        navigationSet()
        fetchData()
        tableViewSet()
        //activeIndicator()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setLayout() {
        view.addSubview(newsTableView)
        newsTableView.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            m.width.equalTo(view.snp.width)
        }
    }
    private func navigationSet() {
        self.navigationItem.title = "RSSNewsReader"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
    private func tableViewSet(){
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.register(NewsListTableViewCell.self, forCellReuseIdentifier: "NewsListTableViewCell")
        
        if #available(iOS 10.0, *) {
            newsTableView.refreshControl = refreshController
        } else {
            newsTableView.addSubview(refreshController)
        }
        
     

        refreshController.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshController.snp.makeConstraints { (m) in
            m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            m.centerX.equalTo(view.snp.centerX)
        }
        refreshController.attributedTitle = NSAttributedString(string: "refresh")
    }
    
    
    
    private func fetchData() {
        let parser = Parser()
        parser.parseFeed(url: self.url!)
        NotificationCenter.default.addObserver(forName: Parser.parsingNoti, object: nil, queue: .main) { (noti) in
            
                Model.tempData = Model.newsData
                self.newsTableView.reloadData()
                self.refreshController.endRefreshing()
            
        }
    }
    
    private func activeIndicator() {
        let alert = UIAlertController(title: "로딩중", message: nil, preferredStyle: .alert)
        let activityIndicator = UIActivityIndicatorView(frame: alert.view.bounds)
        activityIndicator.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        activityIndicator.hidesWhenStopped = true
        alert.view.addSubview(activityIndicator)
        activityIndicator.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        self.present(alert, animated: true, completion: nil)
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (t) in
            activityIndicator.stopAnimating()
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func refresh() {
        //self.activeIndicator()
        Model.newsData.removeAll()
        Parser.count = 0
        fetchData()
    }
    
}
extension NewsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Model.tempData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = Model.tempData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsListTableViewCell", for: indexPath) as? NewsListTableViewCell
        cell?.configureCell(model: model)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsContentVC = UIStoryboard(name: "NewsContent", bundle: nil).instantiateViewController(withIdentifier: "NewsContent") as! NewsContentViewController
        newsContentVC.modalPresentationStyle = .overFullScreen
        newsContentVC.url = Model.tempData[indexPath.row].link
        newsContentVC.articleTitle = Model.tempData[indexPath.row].title
        
        newsContentVC.htmlStr = Model.tempData[indexPath.row].content!.replacingOccurrences(of: "width:", with: "width:\(view.frame.width - 10)px;")
        self.navigationController?.pushViewController(newsContentVC, animated: true)
    }
}

extension UIRefreshControl {
    func refreshManually() {
        beginRefreshing()
        sendActions(for: .valueChanged)
    }
}
