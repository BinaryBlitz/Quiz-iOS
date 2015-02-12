//
//  QZBFriendInHorizontalTabelViewCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 22/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBSomethingInHorizontalTabelViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *picture;
@property (strong, nonatomic) UILabel *name;

- (void)setName:(NSString *)name picURLAsString:(NSString *)URLString;
- (void)setName:(NSString *)name picture:(UIImage *)image;

@end
