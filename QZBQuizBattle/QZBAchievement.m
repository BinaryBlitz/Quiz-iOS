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
@property (copy, nonatomic) NSString *name;

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

@end
