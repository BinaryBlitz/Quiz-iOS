#import <UIKit/UIKit.h>
#import "QZBUserProtocol.h"

@class QZBUserWithTopic;
@class QZBAnotherUser;

@interface QZBRoom : NSObject

@property (strong, nonatomic, readonly) NSNumber *roomID;
@property (strong, nonatomic, readonly) QZBUserWithTopic *owner;
@property (strong, nonatomic, readonly) NSMutableArray *participants;
@property (strong, nonatomic, readonly) NSDate *creationDate;

@property (strong, nonatomic, readonly) NSNumber *maxUserCount;
@property (assign, nonatomic, readonly) BOOL isFriendOnly;

- (instancetype)initWithDictionary:(NSDictionary *)d;

- (BOOL)isContainUser:(id <QZBUserProtocol>)user;

- (QZBUserWithTopic *)findUserWithID:(NSNumber *)userID;

- (void)addUser:(QZBUserWithTopic *)userWithTopic;

- (void)removeUser:(QZBUserWithTopic *)userWithTopic;

- (NSAttributedString *)descriptionForUserWithTopic:(QZBUserWithTopic *)userWithTopic;

//- (NSString *)descriptionForUserWithTopic:(QZBUserWithTopic *)userWithTopic;

//- (NSString *)descriptionForAllUsers;

- (NSString *)participantsDescription;

- (NSString *)topicsDescription;


@end
