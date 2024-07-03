//
//  SearchCharacterViewController.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import UIKit
import SnapKit

final class SearchCharacterViewController: UIViewController {
    private let searchCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Search"
        setSubViews()
    }
    
    private func setSubViews() {
        [searchCollectionView].forEach {
            view.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        searchCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
