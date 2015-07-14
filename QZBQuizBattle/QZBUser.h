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

@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSString *api_key;
@property (strong, nonatomic, readonly) NSNumber *userID;
//@property (strong, nonatomic, readonly) UIImage *userPic;
@property (assign, nonatomic, readonly) BOOL isFriend;
@property (strong, nonatomic, readonly) NSString *pushToken;
@property (strong, nonatomic, readonly) NSURL *imageURL;
@property (strong, nonatomic) QZBUserStatistic *userStatistics;
@property (assign, nonatomic, readonly) BOOL isRegistred;
@property (strong, nonatomic, readonly) NSString *xmppPassword;
@property (assign, nonatomic, readonly) BOOL isOnline;

- (instancetype)initWithDict:(NSDictionary *)dict;

//- (void)setUserPic:(UIImage *)userPic;
- (void)setUserName:(NSString *)userName;
-(void)makeUserRegisterWithUserName:(NSString *)username;
- (void)updateUserFromServer;

-(void)deleteImage;
//-(void)setAPNsToken:(NSString *)pushToken;


@end
