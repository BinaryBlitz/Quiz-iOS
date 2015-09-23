//
//  QZBStoreBoosterCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBStoreBoosterCell.h"
#import "UIButton+QZBButtonCategory.h"

@implementation QZBStoreBoosterCell

- (void)awakeFromNib {
  //  [self.purchaseButton configButtonWithRoundedBorders];
    self.layer.cornerRadius = 5.0;
    self.clipsToBounds = YES;
    
}

@end
