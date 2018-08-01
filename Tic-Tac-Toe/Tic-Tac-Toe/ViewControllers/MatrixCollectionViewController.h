//
//  MatrixCollectionViewController.h
//  Tic-Tac-Toe
//
//  Created by Ognyanka Boneva on 16.07.18.
//  Copyright © 2018 Ognyanka Boneva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@interface MatrixCollectionViewController : UICollectionViewController

@property (weak, nonatomic)id<EngineDelegate> engineDelegate;

@end
