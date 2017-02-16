//
//  UIView+QZBShakeExtension.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 20/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (QZBShakeExtension)

- (void)shakeView;
- (void)addDropShadowsForView;
- (void)addShadows;
- (void)addShadowsAllWay;
- (void)addShadowsAllWayRasterize;

-(void)addShadowsCategory;
- (UIView *) addShadowWithBackgroundCopy ;

@end