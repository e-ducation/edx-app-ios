//
//  TDFindSuiteCell.swift
//  edX
//
//  Created by Elite Edu on 2019/4/16.
//  Copyright © 2019年 edX. All rights reserved.
//

import UIKit

protocol CourseSeriesDelegate: class {
    func couseSeriesSelect(index: NSInteger)
}

class TDFindSuiteCell: UICollectionViewCell {
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collect = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collect.delegate = self
        collect.dataSource = self
        collect.bounces = true
        collect.showsHorizontalScrollIndicator = false
        collect.backgroundColor = UIColor.white
        collect.register(TDCourseSeriesCell.self, forCellWithReuseIdentifier: "TDCourseSeriesCell")
        return collect
    }()
    
    var courseArray: Array<TDMainSiteCourseModel>?
    weak var delegate: CourseSeriesDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViewConstraint()
    }
    
    public func setDataArray(array: Array<TDMainSiteCourseModel>?) {
        courseArray = array
        collectionView.reloadData()
    }
    
    func setViewConstraint() {
        
        self.backgroundColor = UIColor.white
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(-7)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }                
}

extension TDFindSuiteCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courseArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = courseArray?[indexPath.row]
        let cell: TDCourseSeriesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TDCourseSeriesCell", for: indexPath) as! TDCourseSeriesCell
        cell.model = model
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 192, height: 136)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.couseSeriesSelect(index: indexPath.row)
    }
}
