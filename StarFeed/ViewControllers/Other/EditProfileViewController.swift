//
//  EditProfileViewController.swift
//  StarFeed
//
//  Created by Wendy Buhler on 10/17/21.
//

import UIKit

class EditProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    let label: UILabel = {
       
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        setupView()
        addConstraints()
    }
    
    private func setupView() {
        tableView.register(TableCell.self, forCellReuseIdentifier: "tableCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemBackground
    }
    
    private func addConstraints() {
        
        tableView.edgesToSuperview(excluding: .top, usingSafeArea: true)
        tableView.topToBottom(of: label)
        
        label.topToSuperview(offset: 10)
        label.centerXToSuperview()
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! TableCell
        cell.setupCell(title: "Title", image: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Cell tapped \(indexPath.row)")
    }
    


}

class TableCell: UITableViewCell {
    let imageUIView: UIImageView = {
        
        let image = UIImageView()
        image.image = UIImage(systemName: "chevron.right")
        return image
    }()
    
    let title: UILabel = {
        
        let title = UILabel()
        return title
        
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }
    
    func setupCell(title: String, image: Bool) {
        
        self.title.text = title
        if image {
            self.addSubview(imageUIView)
        }
        addSubview(self.title)
        
        self.title.leadingToSuperview(offset: 20)
        self.title.centerYToSuperview()
        
        self.imageUIView.trailingToSuperview(offset: 20)
        self.imageUIView.centerYToSuperview()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
