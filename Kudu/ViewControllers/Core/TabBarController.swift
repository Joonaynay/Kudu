//
//  TabBarViewController.swift
//  Kudu
//
//  Created by Forrest Buhler on 10/11/21.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let explore = ExploreViewController()
        explore.title = "Explore"
        let exploreNav = UINavigationController(rootViewController: explore)        
        exploreNav.tabBarItem = UITabBarItem(title: "Explore", image: UIImage(systemName: "network"), tag: 0)
        exploreNav.navigationBar.isHidden = true
        
        let subjects = SubjectsViewController()
        subjects.title = "Subjects"
        let subjectsNav = UINavigationController(rootViewController: subjects)
        subjectsNav.tabBarItem = UITabBarItem(title: "Subjects", image: UIImage(systemName: "list.dash"), tag: 1)
        subjectsNav.navigationBar.isHidden = true
        
        let search = SearchViewController()
        search.title = "Search"
        let searchNav = UINavigationController(rootViewController: search)
        searchNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        searchNav.navigationBar.isHidden = true
        
        
        let following = FollowingViewController()
        following.title = "Subjects"
        let followingNav = UINavigationController(rootViewController: following)
        followingNav.tabBarItem = UITabBarItem(title: "Following", image: UIImage(systemName: "person.2"), selectedImage: UIImage(systemName: "person.2.fill"))
        followingNav.navigationBar.isHidden = true
        
        setViewControllers([exploreNav, subjectsNav , followingNav, searchNav], animated: true)
    }
    
}
