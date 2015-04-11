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
    
//    NSInteger forFirstLevel
//    NSInteger progressionDiff = 50;
//    
//    NSInteger lvl = 0;
//    NSInteger currScore = 0;
//    
//    while (true) {
//        if(currScore+progressionDiff>score){
//            break;
//        }else{
//            currScore+=progressionDiff;
//            lvl++;
//        }
//    }
//
    
    NSLog(@"score %ld", score);
    
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
    
//    *level = score/100;
//    *levelProgress = (score%100)/100.0;
    
}

@end
