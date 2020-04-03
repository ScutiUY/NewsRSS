//
//  NewsTableViewCell.swift
//  RSSNewsReader
//
//  Created by 신의연 on 2020/03/20.
//  Copyright © 2020 Koggy. All rights reserved.
//

import UIKit
import SnapKit

class NewsListTableViewCell: UITableViewCell {
   
    private let stackView: UIStackView = {
        var stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private let keywordsView: UIView = {
        var view = UIView()
        return view
    }()
    
    private let thumNail: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let title: UILabel = {
        var label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let detailLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        return label
    }()
    
    private let keywordLabel1: UIButton = {
        var label = UIButton()
        label.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        label.setTitleColor(.black, for: .normal)
        label.contentEdgeInsets = UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 5)
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 10
        return label
    }()
    private let keywordLabel2: UIButton = {
        var label = UIButton()
        label.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        label.setTitleColor(.black, for: .normal)
        label.contentEdgeInsets = UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 5)
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 10
        return label
    }()
    private let keywordLabel3: UIButton = {
        var label = UIButton()
        label.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        label.setTitleColor(.black, for: .normal)
        label.contentEdgeInsets = UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 5)
        label.layer.borderWidth = 1
        label.layer.cornerRadius = 10
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCellLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setCellLayout()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    private func setCellLayout() {
        
        contentView.addSubview(stackView)
        contentView.addSubview(thumNail)
        
        
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(detailLabel)
        stackView.addArrangedSubview(keywordsView)
        
        keywordsView.addSubview(keywordLabel1)
        keywordsView.addSubview(keywordLabel2)
        keywordsView.addSubview(keywordLabel3)
        
        
        thumNail.snp.makeConstraints { (m) in
            m.centerY.equalTo(self.snp.centerY)
            m.height.equalTo(self.snp.height).multipliedBy(0.8)
            m.width.equalTo(thumNail.snp.height)
            m.leading.equalTo(self.snp.leading).offset(5)
        }

        stackView.snp.makeConstraints { (m) in
            m.centerY.equalTo(contentView.snp.centerY)
            m.height.equalTo(self.snp.height).multipliedBy(0.8)
            m.leading.equalTo(thumNail.snp.trailing).offset(5)
            m.trailing.equalTo(contentView.safeAreaLayoutGuide.snp.trailing).offset(-5)
        }
        title.snp.makeConstraints { (m) in
            m.height.equalTo(stackView.snp.height).multipliedBy(0.25)
        }
        detailLabel.snp.makeConstraints { (m) in
            m.height.equalTo(stackView.snp.height).multipliedBy(0.5)
        }
        keywordsView.snp.makeConstraints { (m) in
            m.height.equalTo(stackView.snp.height).multipliedBy(0.25) 
        }

        keywordLabel1.snp.makeConstraints { (m) in
            m.leading.equalTo(stackView.snp.leading)
            m.centerY.equalTo(keywordsView.snp.centerY)
        }
        keywordLabel2.snp.makeConstraints { (m) in
            m.leading.equalTo(keywordLabel1.snp.trailing).offset(5)
            m.centerY.equalTo(keywordsView.snp.centerY)
        }
        keywordLabel3.snp.makeConstraints { (m) in
            m.leading.equalTo(keywordLabel2.snp.trailing).offset(5)
            m.centerY.equalTo(keywordsView.snp.centerY)
        }
        
    }
    func configureCell(model: Model) {
        title.text = model.title
        detailLabel.text = model.detail
        thumNail.image = model.thumbNail
        keywordLabel1.setTitle(model.keywords?[0], for: .normal)
        keywordLabel2.setTitle(model.keywords?[1], for: .normal)
        keywordLabel3.setTitle(model.keywords?[2], for: .normal)
    }
    
}
