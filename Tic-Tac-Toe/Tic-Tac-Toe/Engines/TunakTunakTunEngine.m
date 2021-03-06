//
//  TunakTunakTunEngine.m
//  Tic-Tac-Toe
//
//  Created by Ognyanka Boneva on 24.07.18.
//  Copyright © 2018 Ognyanka Boneva. All rights reserved.
//

#import "TunakTunakTunEngine.h"

#import "TunakTunakTunCellModel.h"
#import "PlayerModel.h"

@interface GameEngine ()

- (BOOL)isWinnerPlayerAtIndex:(NSIndexPath *)indexPath;
- (void)markCellSelectedAtIndexPath:(NSIndexPath *)indexPath;
+ (Class)cellType;
- (GameCellModel *)getCellAtIndex:(NSIndexPath *)indexPath;

@end

@interface TunakTunakTunEngine () <BoardStateDelegate>

@property (strong, nonatomic) NSArray<NSArray<TunakTunakTunCellModel *> *> *gameMatrix;

@end

@implementation TunakTunakTunEngine

+(Class)cellType
{
    return TunakTunakTunCellModel.class;
}

- (NSArray<NSIndexPath *> *)availableCells {
    NSMutableArray *accumulated = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.gameMatrix.count; i++) {
        for (int j = 0; j < self.gameMatrix[i].count; j++) {
            if ([self.gameMatrix[i][j] isSelectable]) {
                [accumulated addObject:[NSIndexPath indexPathForItem:j inSection:i]];
            }
        }
    }
    return accumulated.copy;
}

- (BOOL)isCellAtIndexPathSelectable:(NSIndexPath *)indexPath {
    return [super isCellAtIndexPathSelectable:indexPath] && [self.gameMatrix[indexPath.section][indexPath.item] isSelectable];
}

- (void)setNewColorForCellAtIndexPath:(NSIndexPath *)indexPath {
    TunakTunakTunCellModel *cell = self.gameMatrix[indexPath.section][indexPath.item];
    cell.color++;
    if (cell.color == LAST_COLOR) {
        self.filled_cells++;
    }
}

- (void)markCellSelectedAtIndexPath:(NSIndexPath *)indexPath {
    [self setNewColorForCellAtIndexPath:indexPath];
}

- (void)unmarkCellAtIndexPath:(NSIndexPath *)indexPath {
    TunakTunakTunCellModel *cell = self.gameMatrix[indexPath.section][indexPath.item];
    if (cell.color == LAST_COLOR) {
        self.filled_cells--;
    }
    cell.color--;
}

- (BOOL)isWinCombinationAtIndexPathForMe:(NSIndexPath *)indexPath {
    [self markCellSelectedAtIndexPath:indexPath];
    BOOL winCombination = [self isWinnerPlayerAtIndex:indexPath];
    [self unmarkCellAtIndexPath:indexPath];
    
    return winCombination;
}

- (BOOL)isWinCombinationAtIndexPathForOther:(NSIndexPath *)indexPath {
    //kind of a stub
    return false;
}

- (int)emptyCellsCount {
    //stub
    return 0;
}


@end
