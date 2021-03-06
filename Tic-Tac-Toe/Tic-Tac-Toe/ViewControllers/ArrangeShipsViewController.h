//
//  ArrangeShipsViewController.h
//  Tic-Tac-Toe
//
//  Created by Ognyanka Boneva on 21.08.18.
//  Copyright © 2018 Ognyanka Boneva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"

@class BoardModel;
@interface ArrangeShipsViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) BoardModel *boardModel;
@property (strong, nonatomic)id<GameViewDelegate>gameViewDelegate;

@end
