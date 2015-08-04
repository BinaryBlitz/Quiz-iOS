//
//  QZBCurrentUser.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QZBUser.h"

@class QZBUser;

@interface QZBCurrentUser : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic, readonly) QZBUser *user;
@property (strong, nonatomic, readonly) NSString *pushToken;
@property (strong, nonatomic, readonly) NSData *pushTokenData;

- (void)setUser:(QZBUser *)user;
- (BOOL)checkUser;
- (void)userLogOut;

-(void)setAPNsToken:(NSData *)pushToken;

@end
