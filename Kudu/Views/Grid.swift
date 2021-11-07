//
//  Grid.swift
//  Kudu
//
//  Created by Wendy Buhler on 10/14/21.
//

import UIKit

protocol GridFunction: AnyObject {
    func presentView(subject: Subject)
}

class Grid: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, CustomCellectionViewCellDelegate {

    let fb = FirebaseModel.shared
    
    weak var vc: UIViewController?
        
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width / 2) - 15, height: UIScreen.main.bounds.width / 4)
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
        cell.delegate = self
        cell.setSubject(subject: fb.subjects[indexPath.row])
        return cell
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton || view is UITextField {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
    
    func didPressCell(subject: Subject) {
        vc?.navigationController?.pushViewController(SubjectPostViewController(subject: subject), animated: true)
    }
}

protocol CustomCellectionViewCellDelegate: AnyObject {
    func didPressCell(subject: Subject)
}

class CustomCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "cell"
    
    weak var delegate: CustomCellectionViewCellDelegate?
    
    private var subject: Subject?
    
    private lazy var buttonAction: UIAction = {
        let action = UIAction() { _ in
            if let subject = self.subject {
                self.delegate!.didPressCell(subject: subject)
            }
        }
        return action
    }()
    
    private let subjectLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let subjectImage: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        return imageView
    }()
    
    private let button = CustomButton(text: "", color: UIColor.theme.blueColor)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(button)
        addSubview(subjectLabel)
        addSubview(subjectImage)
        
        addConstraintsToCell()        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }        
    
    private func addConstraintsToCell() {
        button.edgesToSuperview()
        
        subjectImage.centerInSuperview(offset: CGPoint(x: 0, y: -10))
        subjectLabel.topToBottom(of: subjectImage)
        subjectLabel.centerXToSuperview()
        
    }
    
    func setSubject(subject: Subject) {
        self.subject = subject
        subjectImage.image = UIImage(systemName: subject.image)
        subjectLabel.text = subject.name
        
        button.addAction(self.buttonAction, for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subjectLabel.text = nil
        button.removeAction(self.buttonAction, for: .touchUpInside)
        subjectImage.image = nil
        
    }
    
}
