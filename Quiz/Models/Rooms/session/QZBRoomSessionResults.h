#import <Foundation/Foundation.h>

@interface QZBRoomSessionResults : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSNumber *)pointsForUserWithID:(NSNumber *)userID;

@end
