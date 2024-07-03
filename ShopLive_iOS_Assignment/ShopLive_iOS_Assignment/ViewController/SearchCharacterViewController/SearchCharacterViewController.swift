//
//  SearchCharacterViewController.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import UIKit
import SnapKit

final class SearchCharacterViewController: UIViewController {
    
    // MARK: - ViewProperties
    private lazy var searchCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(
            CharacterCardCollectionViewCell.self,
            forCellWithReuseIdentifier: CharacterCardCollectionViewCell.identifier
        )
        
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Search"
        setSubViews()
    }
    
    // MARK: - setSubViews
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

// MARK: - SearchCharacterViewController
extension SearchCharacterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characterMockData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CharacterCardCollectionViewCell.identifier,
            for: indexPath
        ) as? CharacterCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configureView(model: characterMockData[indexPath.row])
        
        return cell
    }
}
