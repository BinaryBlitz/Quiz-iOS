//
//  QZBFriendsHorizontalCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 22/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QZBHorizontalCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *horizontalTabelView;

@property(copy, nonatomic)NSString *buttonTitle;



-(void)setSomethingArray:(NSArray *)somethingArray;

@end
