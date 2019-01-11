//
//  TabsCollectionViewDataSource.swift
//  MarxUpUp
//
//  Created by Ognyanka Boneva on 12.11.18.
//  Copyright © 2018 Ognyanka Boneva. All rights reserved.
//

import UIKit

class TabsCollectionViewDataSource: NSObject {
    private let tabs = [TabModel(title: "TOP", filter: DataFilter(local: false, sort: ImageSort.Top)),
                TabModel(title: "VIRAL", filter: DataFilter(local: false, sort: ImageSort.Viral)),
                TabModel(title: "LATEST", filter: DataFilter(local: false, sort: ImageSort.Date)),
                TabModel(title: "YOUR IMAGES", filter: DataFilter(local: true, sort: ImageSort.None))]

    var defaultSelectedTabIndex : IndexPath {
        return IndexPath(item: 1, section: 0)
    }
    
    func filter(atIndex index: Int) -> DataFilter {
        guard index < tabs.count else {
            return tabs[defaultSelectedTabIndex.item].filter
        }
        return tabs[index].filter
    }
}

extension TabsCollectionViewDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(fromClass: TabsCollectionViewCell.self, forIndexPath: indexPath)
        cell.tabLabel.text = tabs[indexPath.item].title
        cell.tabLabel.textColor = UIColor.orange
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
        return tabs.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
