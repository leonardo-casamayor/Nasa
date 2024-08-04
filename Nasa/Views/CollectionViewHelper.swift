//
//  CollectionViewHelper.swift
//  Nasa
//
//  Created by Leonardo Casamayor on 04/08/2024.
//

import UIKit

class CollectionViewHelper{
    
    static func generateLayout(size: CollectionViewConstants.LayoutSize) -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(size.height)),subitem: item,count: size.columns)
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    static func setLayoutSize(traitCollection: UITraitCollection) -> CollectionViewConstants.LayoutSize {
        (traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular) ? CollectionViewConstants.LayoutSize(columns: 1,height: 2/3) : CollectionViewConstants.LayoutSize(columns: 2,height: 1/3)
    }
    
    static func traitCollectionDidChange(collectionView: UICollectionView, traitCollection: UITraitCollection) {
        collectionView.setCollectionViewLayout(CollectionViewHelper.generateLayout(size: CollectionViewHelper.setLayoutSize(traitCollection: traitCollection)), animated: false)
        collectionView.setContentOffset(.zero, animated: true)
    }
    static func setupCollectionView(_ controller: UICollectionViewDataSource, collectionView: UICollectionView, traitCollection: UITraitCollection, identifier: String) {
        collectionView.register(CollectionCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.setCollectionViewLayout(CollectionViewHelper.generateLayout(size: CollectionViewHelper.setLayoutSize(traitCollection: traitCollection)), animated: false)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = controller
    }
}
