//
//  QZBStatiscticCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 27/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@interface QZBStatiscticCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *winLabel;
@property (weak, nonatomic) IBOutlet UILabel *lossesLabel;
@property (weak, nonatomic) IBOutlet UILabel *drawsLabel;

-(void)setCellWithUser:(id <QZBUserProtocol>)user;

@end
