//
//  TabBarViewController.swift
//  StarFeed
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trending = TrendingViewController()
        trending.title = "Trending"
        let trendingNav = UINavigationController(rootViewController: trending)        
        trendingNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "network"), tag: 0)
        trendingNav.navigationBar.isHidden = true
        
        let subjects = SubjectsViewController()
        subjects.title = "Subjects"
        let subjectsNav = UINavigationController(rootViewController: subjects)
        subjectsNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "list.dash"), tag: 1)
        subjectsNav.navigationBar.isHidden = true
        
        let search = SearchViewController()
        search.title = "Search"
        let searchNav = UINavigationController(rootViewController: search)
        searchNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.2"), selectedImage: UIImage(systemName: "person.2.fill"))
        searchNav.navigationBar.isHidden = true
        
        
        let following = FollowingViewController()
        following.title = "Subjects"
        let followingNav = UINavigationController(rootViewController: following)
        followingNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 3)
        followingNav.navigationBar.isHidden = true
        
        setViewControllers([trendingNav, subjectsNav , followingNav, searchNav], animated: true)
    }
    
}