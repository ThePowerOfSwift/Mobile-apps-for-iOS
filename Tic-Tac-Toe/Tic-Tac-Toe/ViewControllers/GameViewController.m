//
//  GameViewController.m
//  Tic-Tac-Toe
//
//  Created by Ognyanka Boneva on 18.07.18.
//  Copyright © 2018 Ognyanka Boneva. All rights reserved.
//

#import "GameEngine.h"
#import "BattleshipsEngine.h"

#import "JoinRoomViewController.h"
#import "CreateRoomViewController.h"
#import "GameViewController.h"
#import "MatrixCollectionViewController.h"
#import "ArrangeShipsViewController.h"

#import "PlayerModel.h"
#import "BotModel.h"
#import "GameCellModel.h"
#import "TunakTunakTunCellModel.h"
#import "TicTacToeCellModel.h"
#import "BoardModel.h"
#import "ShipModel.h"

#import "GameCell.h"

#import "Utilities.h"
#import "MultipeerConectivityManager.h"
#import "Protocols.h"
#import "Constants.h"

#define QUESTION                @"Another game?"
#define INVALID_COORDS_MESSAGE  @"Invalid coordinates!"

@interface GameViewController () <NotifyPlayerToPlayDelegate, EndGameDelegate, EngineDelegate, PeerSessionDelegate, UINavigationControllerDelegate, GameViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *matrixView;
@property (strong, nonatomic) MatrixCollectionViewController *matrixViewController;

@property (weak, nonatomic) IBOutlet UILabel *player1InfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *player2InfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *endOfGameLabel;
@property (strong, nonatomic) UIColor *labelsColor;

@property (weak, nonatomic) IBOutlet UIButton *startNewGameButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (assign) BOOL otherPlayerTappedNewGame;
@property (assign) BOOL isShipsInfoSended;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.player1InfoLabel.text = self.engine.player1.name;
    [self.player1InfoLabel sizeToFit];
    self.player2InfoLabel.text = self.engine.player2.name;
    [self.player2InfoLabel sizeToFit];
    self.endOfGameLabel.text = @"";
    
    self.labelsColor = [[UIColor alloc] initWithRed:255/255 green:102/255 blue:102/255 alpha:1.0];
    [self.startNewGameButton setHidden:YES];
    MultipeerConectivityManager.sharedInstance.peerSessionDelegate = self;
    
    self.navigationController.delegate = self;

    [self.activityIndicator setHidesWhenStopped:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.matrixViewController = (MatrixCollectionViewController *)[Utilities viewControllerWithClass:MatrixCollectionViewController.class];
    self.matrixViewController = segue.destinationViewController;
    self.matrixViewController.engineDelegate = self;
    self.engine.notifyPlayerToPlayDelegate = self;
    self.engine.endGameDelegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:JoinRoomViewController.class] || //back button is pressed
        [viewController isKindOfClass:CreateRoomViewController.class]) {
        [MultipeerConectivityManager.sharedInstance disconnectPeer];
    }
}

- (void)arrangeShipsAndStartGame {
    if ([self.engine.player2 isKindOfClass:BotModel.class]) {
        BotModel *botTemp = (BotModel *)self.engine.player2;
        BattleshipsEngine *engineTemp = (BattleshipsEngine *)self.engine;
        [botTemp arrangeShips:[Utilities getDefaultShips] onBoard:engineTemp.boardPlayer2];
    }
    ArrangeShipsViewController *arrangeShipsController = (ArrangeShipsViewController *)[Utilities viewControllerWithClass:ArrangeShipsViewController.class];
    BattleshipsEngine *battleshipsEngine = (BattleshipsEngine *)self.engine;
    arrangeShipsController.boardModel = battleshipsEngine.boardPlayer1;
    arrangeShipsController.gameViewDelegate = self;
    [self.navigationController presentViewController:arrangeShipsController animated:YES completion:nil];
}

-(void)didChangePlayerToPlayWithName:(NSString *)playerName {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([playerName isEqualToString:self.engine.player1.name]) {
            self.player1InfoLabel.textColor = self.labelsColor;
            self.player2InfoLabel.textColor = [UIColor grayColor];
        }
        else {
            self.player1InfoLabel.textColor = [UIColor grayColor];
            self.player2InfoLabel.textColor = self.labelsColor;
        }
        
        if ([self isOtherPlayingFromChat]) {
            [self sendTheGameMap];
        }
    });
}

- (void)didEndGameWithNoWinner {
    [self updateUIAfterGameEndWithWinner:@""];
    if ([self isOtherPlayingFromChat]) {
        [self sendWinner:@""];
    }
}

- (void)didEndGameWithWinner:(PlayerModel *)winner {
    [self updateUIAfterGameEndWithWinner:winner.name];
    if ([self isOtherPlayingFromChat]) {
        [self sendTheGameMap];
        [self sendWinner:winner.name];
    }
}

- (BOOL)isOtherPlayingFromChat {
    return self.gameMode == EnumGameModeTwoDevices && ![self.otherPlayerAppName isEqualToString:THIS_APP_NAME];
}

- (void)updateUIAfterGameEndWithWinner:(NSString *)winner {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([winner isEqualToString:@""]) {
            self.endOfGameLabel.text = @"No winner";
        }
        else {
            self.endOfGameLabel.text = [[NSString alloc] initWithFormat:@"%@ won", winner];
        }
        self.endOfGameLabel.textColor = self.labelsColor;
        [self.endOfGameLabel sizeToFit];
        self.matrixView.userInteractionEnabled = NO;
        [self.startNewGameButton setHidden:NO];
    });
}

-(void)forceRefresh {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.matrixViewController.collectionView reloadData];
    });
}

- (void)shipsAreArranged {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if (self.gameMode == EnumGameModeOneDevice) {
        [self.engine startGame];
    }
    else {
        [self sendShipsInfo];
        if (!self.isShipsInfoSended) {
            [self.engine startMultipeerGame];
        }
    }
}

- (void)shouldStartNewGame {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.activityIndicator isAnimating]) {
            [self.activityIndicator stopAnimating];
            self.otherPlayerTappedNewGame = false;
            [self newGame];
        }
    });
}

- (void)setPlayerOnTurnWithName:(NSString *)name {
    if ([name isEqualToString:self.engine.player1.name]) {
        self.engine.currentPlayer = self.engine.player1;
    }
    else {
        self.engine.currentPlayer = self.engine.player2;
    }
}

- (IBAction)onNewGameTap:(id)sender {
    [self.startNewGameButton setHidden:YES];
    self.endOfGameLabel.text = @"";
    if (self.gameMode == EnumGameModeOneDevice) {
        [self newGame];
    }
    else {
        [self sendInfoAndStartNewMultipeerGame];
    }
    self.matrixView.userInteractionEnabled = YES;
}

- (void)sendInfoAndStartNewMultipeerGame {
    if (self.roomBelongsToMe) {
        [self.engine setUpPlayers];
        if ([self.otherPlayerAppName isEqualToString:THIS_APP_NAME]) {
            [self sendTheFirstPlayerOnTurn:self.engine.currentPlayer.name];
        }
    }
    else {
        [self sendTappedNewGame];
    }
    [self shouldStartNewMutipeerGame];
}

- (void)shouldStartNewMutipeerGame {
    if (self.otherPlayerTappedNewGame) {
        self.otherPlayerTappedNewGame = false;
        [self newGame];
    }
    else {
        if ([self isOtherPlayingFromChat]) {
            [self sendQuestionForNewGame];
        }
        [self.activityIndicator startAnimating];
    }
}

- (void)sendCellMarkedAtIndexPath:(NSIndexPath *)indexPath {
    NSString *stringCoords = [NSString stringWithFormat:@"%d,%d",(int)indexPath.section, (int)indexPath.row];
    [self sendDictWithKey:KEY_COORDINATES andValue:stringCoords];
}

- (void)sendTheFirstPlayerOnTurn:(NSString *)name {
    [self sendDictWithKey:KEY_TURN andValue:name];
}

- (void)sendTappedNewGame {
    [self sendDictWithKey:KEY_READY andValue:self.engine.player1.name];
}

- (void)sendQuestionForNewGame {
    [self sendDictWithKey:KEY_QUESTION andValue:QUESTION];
}

- (void)sendWinner:(NSString *)winnerName {
    NSString *message = [[NSString alloc] initWithFormat:@"Congrats to %@!", winnerName];
    [self sendDictWithKey:KEY_MESSAGE andValue:message];
}

- (void)sendTheGameMap {
    [self sendDictWithKey:KEY_MAP andValue:[self.engine mapParsedToString]];
}

- (void)sendInvalidCoordinatesMessage {
    [self sendDictWithKey:KEY_MESSAGE andValue:INVALID_COORDS_MESSAGE];
}

- (void)sendShipsInfo {
    BattleshipsEngine *battleshipsEngine = (BattleshipsEngine *)self.engine;
    NSMutableArray *shipsInfo = [[NSMutableArray alloc] init];
    for (ShipModel *ship in battleshipsEngine.boardPlayer1.ships) {
        [shipsInfo addObject:[ship toJSON]];
    }
    NSDictionary *dataDict = @{KEY_BOARD : shipsInfo};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:NSJSONWritingPrettyPrinted error:nil];
    [MultipeerConectivityManager.sharedInstance sendData:data toPeer:self.peer];
}

- (void)sendDictWithKey:(NSString *)key andValue:(NSString *)value {
    NSDictionary *dataDict = @{key : value};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict options:NSJSONWritingPrettyPrinted error:nil];
    [MultipeerConectivityManager.sharedInstance sendData:data toPeer:self.peer];
}

- (void)didReceiveCoordinatesWithString:(NSString *)string {
    NSInteger section = [[string substringFromIndex:0] intValue];
    NSInteger row = [[string substringFromIndex:2] intValue];
    if (![self.otherPlayerAppName isEqualToString:THIS_APP_NAME]) {
        section--;
        row--;
    }
    NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:section];

    if ([self.otherPlayerAppName isEqualToString:THIS_APP_NAME] ||
        ([self.engine areCoordinatesValidX:(int)section andY:(int)row] &&
         [self.engine isCellAtIndexPathSelectable:index] && self.engine.currentPlayer == self.engine.player2)) {
        [self.engine playerSelectedItemAtIndexPath:index];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.matrixViewController.collectionView reloadData];
        });
    }
    else {
        [self sendInvalidCoordinatesMessage];
    }
}

- (void)didReceivePlayerOnTurnWithString:(NSString *)string {
    if (!self.roomBelongsToMe) {
        [self setPlayerOnTurnWithName:string];
    }
    self.otherPlayerTappedNewGame = true;
    [self shouldStartNewGame];
}

- (void)didReceiveJoinedPlayerStartedNewGame {
    self.otherPlayerTappedNewGame = true;
    [self shouldStartNewGame];
}

- (void)didReceiveAnswer:(NSString *)answer {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[answer lowercaseString] containsString:@"yes"] && [self.activityIndicator isAnimating]) {
            [self.activityIndicator stopAnimating];
            [self newGame];
        }
    });
}

- (void)didReceiveShipsInfo:(NSArray *)shipsInfo {
    BattleshipsEngine *engine = (BattleshipsEngine *)self.engine;
    NSMutableArray *ships = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in shipsInfo) {
        ShipModel *newShip = [ShipModel newShipFromJSON:dict];
        [ships addObject:newShip];
    }
    engine.boardPlayer2.ships = ships.copy;
    
    if (self.isShipsInfoSended) {
        self.isShipsInfoSended = false;
        [self.engine startMultipeerGame];
    }
}

// EngineDelegate methods

- (EnumGame)getGameType {
    return self.gameType;
}

- (EnumGameMode)getGameMode {
    return self.gameMode;
}

- (PlayerModel *)getCurrentPlayer {
    return self.engine.currentPlayer;
}

- (PlayerModel *)getPlayer1 {
    return self.engine.player1;
}

- (int)rowsCount {
    return self.engine.rowsCount;
}

- (int)itemsCount {
    return self.engine.itemsCount;
}

- (BOOL)shouldDisplayContentAtIndexPath:(NSIndexPath *)indexPath { //if board on display == 1 and is part of ship ; content -> ship
    return [self.engine shouldDisplayContentAtIndexPath:indexPath];
}

- (GameCellModel *)getCellAtIndex:(NSIndexPath *)indexPath {
    return [self.engine getCellAtIndex:indexPath];
}

- (BOOL)isCellAtIndexPathSelectable:(NSIndexPath *)indexPath {
    return [self.engine isCellAtIndexPathSelectable:indexPath];
}

- (void)playerSelectedItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.engine playerSelectedItemAtIndexPath:indexPath];
}

- (void)cellMarkedAtIndexPath:(NSIndexPath *)indexPath {
    if (self.gameMode == EnumGameModeTwoDevices && [self.otherPlayerAppName isEqualToString:THIS_APP_NAME]) {
        [self sendCellMarkedAtIndexPath:indexPath];
    }
    else if (self.gameMode == EnumGameModeTwoDevices && ![self.otherPlayerAppName isEqualToString:THIS_APP_NAME] && self.engine.currentPlayer != self.engine.player1) {
        [self sendCellMarkedAtIndexPath:indexPath];
    }
}

- (void)startGame {
    if (self.gameType == EnumGameBattleships) {
        [self arrangeShipsAndStartGame];
    }
    else if (self.gameMode == EnumGameModeOneDevice) {
        [self.engine startGame];
    }
    else {
        [self.engine startMultipeerGame];
    }
}

- (void)newGame {
    if (self.gameType == EnumGameBattleships) {
        BattleshipsEngine *tempEngine = (BattleshipsEngine *)self.engine;
        [tempEngine clearBoards];
        [self arrangeShipsAndStartGame];
    }
    else if (self.gameMode == EnumGameModeOneDevice){
        [self.engine newGame];
    }
    else {
        [self.engine newMultipeerGame];
    }
}

- (void)peer:(MCPeerID *)peerID changedState:(MCSessionState)state {
    if (state == MCSessionStateNotConnected) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"The other player quit the game." message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *quit = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self.navigationController popToViewController:self.navigationController.viewControllers[(self.navigationController.viewControllers.count - 3)] animated:YES];
        }];
        
        [alert addAction:quit];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    for (NSString *key in dataDict.allKeys) {
        if ([key isEqualToString:KEY_COORDINATES]) {
            [self didReceiveCoordinatesWithString:dataDict[key]];
        }
        else if ([key isEqualToString:KEY_TURN]) {
            [self didReceivePlayerOnTurnWithString:dataDict[key]];
        }
        else if([key isEqualToString:KEY_READY]) {
            [self didReceiveJoinedPlayerStartedNewGame];
        }
        else if ([key isEqualToString:KEY_ANSWER]) {
            [self didReceiveAnswer:dataDict[KEY_ANSWER]];
        }
        else if ([key isEqualToString:KEY_BOARD]) {
            [self didReceiveShipsInfo:dataDict[KEY_BOARD]];
        }
    }
}

@end
