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
        refreshControl.attributedTitle = NSAttributedString(string: "refresh")
        return refreshControl
    }()
    
    
    private let url = URL(string: "https://news.google.com/rss?hl=ko&gl=KR&ceid=KR:ko")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = false
        setLayout()
        navigationSet()
        fetchData()
        tableViewSet()
        activeIndicator()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setLayout() {
        view.addSubview(newsTableView)
        newsTableView.snp.makeConstraints { (m) in
            m.top.equalToSuperview()
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
        
    }
    
    private func fetchData() {
        Parser.shared.parseFeed(url: self.url!)
        NotificationCenter.default.addObserver(forName: Parser.parsingNoti, object: nil, queue: .main) { (noti) in
            Model.tempData = Model.newsData
            self.newsTableView.reloadData()
            self.refreshController.endRefreshing()
        }
        activeIndicator()
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
        NotificationCenter.default.addObserver(forName: Parser.parsingNoti, object: nil, queue: .main) { (noti) in
            if Parser.count == Model.newsData.count && Model.newsData.count != 0{
                activityIndicator.stopAnimating()
                alert.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func refresh() {
        
        Model.newsData.removeAll()
        Parser.count = 0 // 로딩을 위한 수치
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
        tableView.deselectRow(at: indexPath, animated: true)
        let newsContentVC = UIStoryboard(name: "NewsContent", bundle: nil).instantiateViewController(withIdentifier: "NewsContent") as! NewsContentViewController
        newsContentVC.modalPresentationStyle = .overFullScreen
        newsContentVC.url = Model.tempData[indexPath.row].link
        newsContentVC.articleTitle = Model.tempData[indexPath.row].title
        
        newsContentVC.htmlStr = Model.tempData[indexPath.row].content!
        self.navigationController?.pushViewController(newsContentVC, animated: true)
    }
}

extension UIRefreshControl {
    func refreshManually() {
        beginRefreshing()
        sendActions(for: .valueChanged)
    }
}
extension UIScrollView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0), animated: false)
        }
    }
}
