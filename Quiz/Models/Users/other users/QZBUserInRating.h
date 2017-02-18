#import "QZBAnotherUser.h"
//#import "QZBUserProtocol.h"

@interface QZBUserInRating : QZBAnotherUser

@property(assign, nonatomic) NSInteger points;
@property(assign, nonatomic) NSInteger position;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict position:(NSInteger) position;

@end
