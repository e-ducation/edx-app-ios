//
//  TDFeedbackImageCell.swift
//  edX
//
//  Created by Elite Edu on 2019/7/29.
//  Copyright © 2019 edX. All rights reserved.
//

import UIKit

protocol TDFeedbackImageDelegate: class {
    func clickAddImageButton()
    func deleteImageForArray(imageArray: Array<UIImage>)
    func declickImageItem()
}

class TDFeedbackImageCell: UITableViewCell {

    let titleLabel = UILabel()
    let numLabel = UILabel()
    
    var imageArray = Array<UIImage>()
    
    weak var delegate: TDFeedbackImageDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
        configView()
        setviewConstraint()
    }
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.bounces = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        
        collectionView.register(TDFeedbackImageItemCell.self, forCellWithReuseIdentifier: TDFeedbackImageItemCell.identifier)
        return collectionView
    }()
    
    func reloadImageData(imageArray: Array<UIImage>) {
        self.imageArray = imageArray
        numLabel.text = "\(imageArray.count)/4"
        collectionView.reloadData()
    }
    
    func configView() {
        selectionStyle = .none
        contentView.backgroundColor = .white
        
        titleLabel.font = UIFont(name: "PingFangSC-Regular", size: 16)
        titleLabel.textColor = UIColor(hexString: "#2e313c")
        contentView.addSubview(titleLabel)
        
        numLabel.font = UIFont(name: "PingFangSC-Regular", size: 14)
        numLabel.textColor = UIColor(hexString: "#aab2bd")
        contentView.addSubview(numLabel)
        
        contentView.addSubview(collectionView)
        
        titleLabel.text = "图片（选填，提供问题截图）"
        numLabel.text = "0/4"
    }
    
    func setviewConstraint() {
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.top.equalTo(contentView).offset(5)
            make.height.equalTo(44)
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(contentView).offset(-16)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.left.equalTo(contentView).offset(16)
            make.right.equalTo(contentView).offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.bottom.equalTo(contentView.snp.bottom).offset(-22)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TDFeedbackImageCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imageArray.count == 4 {
            return 4
        }
        return imageArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : TDFeedbackImageItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: TDFeedbackImageItemCell.identifier, for: indexPath) as! TDFeedbackImageItemCell
        
        if imageArray.count <= 4, indexPath.row == imageArray.count {
            cell.deleteButton.isHidden = true
            cell.imageView.image = UIImage(named: "feedback_add")
        }
        else {
            cell.deleteButton.isHidden = false
            cell.deleteButton.tag = indexPath.row
            cell.deleteButton.addTarget(self, action: #selector(deleteButtonAction(sender:)), for: .touchUpInside)
            cell.imageView.image = imageArray[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.size.width - 32 - 33
        return CGSize(width: screenWidth/4 , height: screenWidth/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if imageArray.count <= 4, indexPath.row == imageArray.count {
            self.delegate?.clickAddImageButton()
        }
        else {
            self.delegate?.declickImageItem()
        }
    }
    
    @objc func deleteButtonAction(sender: UIButton) {
        imageArray.remove(at: sender.tag)
        reloadImageData(imageArray: imageArray)
        self.delegate?.deleteImageForArray(imageArray: imageArray)
    }
}
