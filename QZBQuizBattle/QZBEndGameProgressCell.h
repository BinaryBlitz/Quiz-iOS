//
//  QZBEndGameProgressCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UAProgressView;

@interface QZBEndGameProgressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UAProgressView *circularBackgroundProgress;

@property (weak, nonatomic) IBOutlet UAProgressView *circularProgress;
@property (weak, nonatomic) IBOutlet UAProgressView *circularOldProgress;

-(void)moveProgressFromBeginScore:(NSInteger)beginScore toEndScore:(NSInteger)endScore;
-(void)initCell;

-(void)initCellWithBeginScore:(NSInteger)beginScore;

@end
