//
//  QZBAchievement.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QZBAchievement : NSObject

@property (strong, nonatomic, readonly) UIImage *image;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *achievementDescription;
@property (assign, nonatomic, readonly) BOOL isAchieved;
@property (strong, nonatomic, readonly) NSURL *imageURL;

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imgName;
- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (void)makeAchievementGetted;
- (void)makeAchievementUnGetted;

@end
