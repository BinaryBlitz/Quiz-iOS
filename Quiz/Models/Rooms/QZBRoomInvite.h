#import <Foundation/Foundation.h>

@interface QZBRoomInvite : NSObject

@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic, readonly) NSNumber *roomID;
@property (strong, nonatomic, readonly) NSNumber *roomInviteID;
@property (strong, nonatomic, readonly) NSDate *createdAt;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end
