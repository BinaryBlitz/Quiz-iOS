//
//  QZBAchievement.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAchievement.h"

@interface QZBAchievement ()

@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic)   NSString *name;
@property (strong, nonatomic) NSNumber *achievementID;
@property (copy, nonatomic)   NSString *achievementDescription;
@property (assign, nonatomic) BOOL isAchieved;

@end

@implementation QZBAchievement

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imgName {
    self = [super init];
    if (self) {
        self.name = name;
        self.image = [UIImage imageNamed:imgName];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
        self.name = dict[@"name"];
        self.achievementID = dict[@"id"];
        self.achievementDescription = dict[@"description"];
        self.isAchieved = [dict[@"achieved"] boolValue];   
        
    }
    return self;
}

@end
