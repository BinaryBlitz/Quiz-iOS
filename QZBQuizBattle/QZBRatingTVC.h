//
//  QZBRatingVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 06/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QZBRatingTableType) { QZBRatingTableAllTime, QZBRatingTableWeek };

@interface QZBRatingTVC : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *ratingTableView;
@property (copy, nonatomic) NSString *urlString;
@property (assign, nonatomic) QZBRatingTableType tableType;

- (void)setPlayersRanksWithTop:(NSArray *)topArray playerArray:(NSArray *)playerArray;

@end
