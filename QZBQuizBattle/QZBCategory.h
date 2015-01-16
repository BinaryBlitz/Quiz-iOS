//
//  QZBCategory.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QZBCategory : NSObject

@property(copy,   nonatomic, readonly) NSString *name;
@property(assign, nonatomic, readonly) NSInteger category_id;


- (instancetype)initWithDict:(NSDictionary *)dict;

@end
