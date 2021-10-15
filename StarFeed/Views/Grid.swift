//
//  Grid.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/14/21.
//

import UIKit

class Grid: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let fb = FirebaseModel.shared
    
    init(vc: UIViewController) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (vc.view.width / 2) - 15, height: vc.view.width / 4)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        super.init(frame: .zero, collectionViewLayout: layout)
        dataSource = self
        delegate = self
        backgroundColor = .clear
        register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
        showsVerticalScrollIndicator = false
        delaysContentTouches = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fb.subjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as! CustomCollectionViewCell
        cell.setSubject(subject: fb.subjects[indexPath.row])
        return cell
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton || view is UITextField {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }

}

class CustomCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "cell"
    
    private var subject: Subject!
    
    private let subjectLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let subjectImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        backgroundColor = UIColor.theme.blueColor
        addSubview(subjectLabel)
        addSubview(subjectImage)
        addConstraintsToCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }        
    
    private func addConstraintsToCell() {
        subjectImage.centerInSuperview(offset: CGPoint(x: 0, y: -10))
        subjectLabel.topToBottom(of: subjectImage)
        subjectLabel.centerXToSuperview()
        
    }
    
    public func setSubject(subject: Subject) {
        self.subject = subject
        subjectImage.image = UIImage(systemName: subject.image)
        subjectImage.tintColor = .label
        
        subjectLabel.text = subject.name        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subjectLabel.text = nil
    }
    
}
