//
//  QZBPlayerCountChooserCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 29/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBPlayerCountChooserCell.h"
#import "UIFont+QZBCustomFont.h"

@implementation QZBPlayerCountChooserCell


-(void)awakeFromNib{
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont museoFontOfSize:25]};
    
    [self.playersCountSegmentControll setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

@end
