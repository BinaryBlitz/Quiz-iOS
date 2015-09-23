//
//  QZBCommentTextView.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 07/09/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBCommentTextView.h"

@implementation QZBCommentTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init
{
    if (self = [super init]) {
        // Do something
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.placeholder = @"Сообщение";//NSLocalizedString(@"Message", nil);
    self.placeholderColor = [UIColor lightGrayColor];
    self.pastableMediaTypes = SLKPastableMediaTypeAll;
    
    self.layer.borderColor = [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0].CGColor;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}


@end
