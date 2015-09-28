//
//  QZBRatingVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const QZBNeedReloadRatingTableView;

typedef NS_ENUM(NSInteger, QZBRatingTableType) {
    QZBRatingTableAllTime,
    QZBRatingTableWeek,
    QZBRatingTableFriends
};

@interface QZBRatingTVC : UITableViewController

@property (assign, nonatomic) QZBRatingTableType tableType;

- (void)setPlayersRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray;

@end
