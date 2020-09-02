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
        label.numberOfLines = 3
        return label
    }()
    
    private let detailLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 3
        return label
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCellLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    private func setCellLayout() {
        
        contentView.addSubview(stackView)
        contentView.addSubview(thumNail)
        
        
        stackView.addArrangedSubview(title)
        //stackView.addArrangedSubview(detailLabel)
        
        
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
            m.height.equalTo(stackView.snp.height).multipliedBy(1)
        }
    }
    
    func configureCell(model: Model) {
        title.text = model.title
        detailLabel.text = model.detail
        thumNail.image = model.thumbNail
    }
    
}
