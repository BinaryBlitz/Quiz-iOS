//
//  QZBAchievementManager.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 07/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QZBAchievementManager : NSObject

@property(strong, nonatomic, readonly) NSArray *achievements;

+ (instancetype)sharedInstance;
- (void)updateAchievements;

-(NSArray *)mergeAchievemtsWithGetted:(NSArray *)achievements;

@end
