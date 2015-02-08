//
//  QZBUser.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QZBUser : NSObject

//@property(assign, nonatomic, readonly) NSInteger user_id;

@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSString *api_key;
@property (strong, nonatomic, readonly) NSNumber *user_id;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
