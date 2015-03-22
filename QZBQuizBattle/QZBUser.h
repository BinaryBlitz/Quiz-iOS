//
//  QZBUser.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QZBUserProtocol.h"
#import <UIKit/UIKit.h>

@interface QZBUser : NSObject <QZBUserProtocol>

//@property(assign, nonatomic, readonly) NSInteger user_id;

@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSString *api_key;
@property (strong, nonatomic, readonly) NSNumber *userID;
@property (strong, nonatomic, readonly) UIImage *userPic;
@property (assign, nonatomic, readonly) BOOL isFriend;
@property (strong, nonatomic, readonly) NSString *pushToken;
@property (strong, nonatomic, readonly) NSURL *imageURL;

- (instancetype)initWithDict:(NSDictionary *)dict;

- (void)setUserPic:(UIImage *)userPic;
- (void)setUserName:(NSString *)userName;
- (void)updateUserFromServer;
//-(void)setAPNsToken:(NSString *)pushToken;


@end
