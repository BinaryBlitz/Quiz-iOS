#import "QZBChallengeDescription.h"

@class QZBUser;
@class QZBAnotherUser;
@class QZBCurrentUser;

@interface QZBChallengeDescriptionWithResults : QZBChallengeDescription

@property(assign, nonatomic, readonly) NSInteger firstResult;
@property(assign, nonatomic, readonly) NSInteger opponentResult;
@property(strong, nonatomic, readonly) QZBAnotherUser *opponentUser;
@property(strong, nonatomic, readonly) QZBUser *firstUser;
@property(assign, nonatomic, readonly) NSInteger multiplier;
@property(copy, nonatomic, readonly) NSString *sessionResult;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
