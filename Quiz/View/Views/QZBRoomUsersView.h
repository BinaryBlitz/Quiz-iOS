//
//  QZBRoomUsersView.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 03/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBRoomUsersView : UIView
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *nameLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *usersScores;

@end
