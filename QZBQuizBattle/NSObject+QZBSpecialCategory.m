//
//  NSObject+QZBSpecialCategory.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 10/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "NSObject+QZBSpecialCategory.h"

@implementation NSObject (QZBSpecialCategory)

+(void)calculateLevel:(NSInteger *)level levelProgress:(float *)levelProgress fromScore:(NSInteger)score{
    
   // NSLog(@"score %ld", score);
    
    NSInteger resScore = score;
    NSInteger lvl = 0;
    
    NSInteger pointsForLevel = 50;
    NSInteger diff = 50;
    
    while (true) {
        pointsForLevel +=diff;
        if(resScore - pointsForLevel<0){
            *level = lvl;
            *levelProgress = (float)resScore/pointsForLevel;
            
            break;
        }else{
            resScore-=pointsForLevel;
            lvl++;
        }
    }
}

@end
