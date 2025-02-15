//
//  FavoriteCharacterViewController.swift
//  ShopLive_iOS_Assignment
//
//  Created by J_Min on 7/3/24.
//

import UIKit

final class FavoriteCharacterViewController: UIViewController {
    
    // MARK: - ViewProperties
    private lazy var favoriteCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: favoriteCollectionViewLayout())
        collectionView.register(
            CharacterCardCollectionViewCell.self,
            forCellWithReuseIdentifier: CharacterCardCollectionViewCell.identifier
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    private let emptyCharacterLabel: UILabel = {
        let label = UILabel()
        label.text = "좋아하는 캐릭터가 없습니다."
        label.textColor = .systemGray4
        
        return label
    }()
    
    // MARK: - Properties
    private var viewModel: FavoriteCharacterViewModelProtocol
    private var subscriptions = Set<SLAnyCancellable>()
    
    // MARK: - LifeCycle
    init(viewModel: FavoriteCharacterViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Favorite"
        setSubViews()
        binding()
    }
    
    private func binding() {
        viewModel.collectionViewUpdatePublisher
            .sink { [weak self] in
                self?.favoriteCollectionView.reloadData()
            }.store(in: &subscriptions)
        
        viewModel.emptyFavoriteMarvelCharacterPublisher
            .sink { [weak self] isEmpty in
                if isEmpty {
                    self?.emptyCharacterLabel.isHidden = false
                    self?.favoriteCollectionView.isHidden = true
                } else {
                    self?.emptyCharacterLabel.isHidden = true
                    self?.favoriteCollectionView.isHidden = false
                }
            }.store(in: &subscriptions)
    }
    
    // MARK: - setSubViews
    private func setSubViews() {
        [emptyCharacterLabel, favoriteCollectionView].forEach {
            view.addSubview($0)
        }
        
        setConstraints()
    }
    
    private func setConstraints() {
        favoriteCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyCharacterLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    // MARK: - CompositionalLayout
    private func favoriteCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 3, bottom: 10, trailing: 3)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
}

// MARK: - UICollectionViewDataSource
extension FavoriteCharacterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.favoriteMarvelCharacters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CharacterCardCollectionViewCell.identifier,
            for: indexPath
        ) as? CharacterCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configureView(coreDataModel: viewModel.favoriteMarvelCharacters[indexPath.row])
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension FavoriteCharacterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.deleteFavoriteMarvelCharacter(index: indexPath.row)
    }
}
