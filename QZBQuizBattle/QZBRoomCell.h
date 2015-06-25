//
//  QZBRoomCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 16/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QZBRoom;
@interface QZBRoomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicsDescriptionLabel;

- (void)configureCellWithRoom:(QZBRoom *)room;

@end
