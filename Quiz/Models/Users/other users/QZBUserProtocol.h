
//Protocol for all users in program
#import <Foundation/Foundation.h>
#import "QZBUserStatistic.h"

@protocol QZBUserProtocol <NSObject>

@required

-(NSString *)name;

-(NSNumber *)userID;

-(NSURL *)imageURL;

-(NSURL *)imageURLBig;

@optional

-(BOOL)isFriend;

-(QZBUserStatistic *)userStatistics;

-(BOOL)isOnline;

@end
