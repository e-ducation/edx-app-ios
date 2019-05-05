//
//  TDCourseCategoryCell.swift
//  edX
//
//  Created by Elite Edu on 2019/4/16.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

protocol CourseCategoryDelegate: class {
    func courseCategoryDidSelect(index: NSInteger)
}

class TDCourseCategoryCell: UICollectionViewCell {
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collect = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collect.delegate = self
        collect.dataSource = self
        collect.bounces = true
        collect.showsHorizontalScrollIndicator = false
        collect.backgroundColor = UIColor.white
        collect.register(TDCategoryItemCell.self, forCellWithReuseIdentifier: "TDCategoryItemCell")
        return collect
    }()
    
    var categoryArray: Array<TDMainSiteCategoryModel>?
    weak var delegate: CourseCategoryDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViewConstraint()
    }
    
    public func setDataArray(array: Array<TDMainSiteCategoryModel>?) {
        categoryArray = array
        collectionView.reloadData()
    }
    
    private func setViewConstraint() {
        
        self.backgroundColor = UIColor.white
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self).offset(-3)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension TDCourseCategoryCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = categoryArray?[indexPath.row]
        let cell: TDCategoryItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TDCategoryItemCell", for: indexPath) as! TDCategoryItemCell
        cell.model = model
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 86, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 12, bottom: 10, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.courseCategoryDidSelect(index: indexPath.row)
    }
}

