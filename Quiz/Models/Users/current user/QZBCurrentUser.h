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

- (void)setNeedStartMessager:(BOOL)needStartMessager;
- (BOOL)needStartMessager;


@end
