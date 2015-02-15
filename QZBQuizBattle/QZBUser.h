//
//  QZBUser.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QZBUser : NSObject

//@property(assign, nonatomic, readonly) NSInteger user_id;

@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSString *api_key;
@property (strong, nonatomic, readonly) NSNumber *user_id;
@property (strong, nonatomic, readonly) UIImage *userPic;

- (instancetype)initWithDict:(NSDictionary *)dict;
- (void)setUserPic:(UIImage *)userPic;

@end
