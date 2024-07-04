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
        let networkManager = NetworkManager()
        let coreDataManager = CoreDataManager()
        let searchVM = SearchCharacterViewModel(networkManager: networkManager, coreDataManager: coreDataManager)
        
        let searchVC = setNavigationControllerItem(
            vc: SearchCharacterViewController(viewModel: searchVM),
            title: "Search",
            image: UIImage(systemName: "magnifyingglass") ?? UIImage()
        )
        let favoriteVC = setNavigationControllerItem(
            vc: FavoriteCharacterViewController(),
            title: "Favorite",
            image: UIImage(systemName: "star") ?? UIImage()
        )
        
        coreDataManager.getFavoriteCharacter()
        
        setViewControllers([searchVC, favoriteVC], animated: true)
    }
}
