//
//  ToolboxItemViewController.m
//  MarxUp
//
//  Created by Ognyanka Boneva on 26.09.18.
//  Copyright © 2018 Ognyanka Boneva. All rights reserved.
//

#import "ToolboxItemViewController.h"
#import "CollectionViewDataSource.h"
#import "Utilities.h"

#import "ShapesCollectionViewDataSource.h"

@interface ToolboxItemViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *toolboxItemOptions;
@property (strong, nonatomic) CollectionViewDataSource *itemOptionsDataSource;

@end

@implementation ToolboxItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    self.itemOptionsDataSource = [Utilities dataSourceForToolboxItem:self.itemType];
    self.toolboxItemOptions.dataSource = self.itemOptionsDataSource;
    self.toolboxItemOptions.delegate = self;
    self.toolboxItemOptions.backgroundColor = [UIColor clearColor];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id option = [self.itemOptionsDataSource optionAtIndex:indexPath.item];
    [self.toolboxItemsOptionsDelegate didChooseOption:option forItem:self.itemType];
}

@end
