//
//  MainTabbarController.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import UIKit

final class MainTabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabbar()
    }
    
    private func setNavigationControllerItem(vc: UIViewController, title: String, image: UIImage) -> UINavigationController {
        let naviVC = UINavigationController(rootViewController: vc)
        vc.tabBarItem.title = title
        vc.tabBarItem.image = image
        
        return naviVC
    }
    
    private func configureTabbar() {
        let searchVC = setNavigationControllerItem(
            vc: SearchCharacterViewController(),
            title: "Search",
            image: UIImage(systemName: "magnifyingglass") ?? UIImage()
        )
        let favoriteVC = setNavigationControllerItem(
            vc: FavoriteCharacterViewController(),
            title: "Favorite",
            image: UIImage(systemName: "star") ?? UIImage()
        )
        
        setViewControllers([searchVC, favoriteVC], animated: true)
    }
}
