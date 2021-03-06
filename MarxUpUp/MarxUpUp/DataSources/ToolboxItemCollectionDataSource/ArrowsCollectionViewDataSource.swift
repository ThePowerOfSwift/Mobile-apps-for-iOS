//
//  ArrowsCollectionViewDataSource.swift
//  MarxUpUp
//
//  Created by Ognyanka Boneva on 14.11.18.
//  Copyright © 2018 Ognyanka Boneva. All rights reserved.
//

import UIKit

final class ArrowsCollectionViewDataSource: NSObject {
    private let arrows = [ArrowModel(withType: ArrowEndLineType.open), ArrowModel(withType: ArrowEndLineType.closed)]
}

extension ArrowsCollectionViewDataSource: ToolboxItemCollectionDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrows.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(fromClass: ToolboxItemOptionsCollectionViewCell.self,
                                                      forIndexPath: indexPath)

        cell.itemImageView.image = arrows[indexPath.item].image

        return cell
    }

    func option(atIndex index: Int) -> Int {
        if index >= arrows.count || index < 0 {
            print("Error: Index out of bounds")
            return -1
        }
        return arrows[index].type.rawValue
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
