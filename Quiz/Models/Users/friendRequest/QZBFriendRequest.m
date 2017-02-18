#import "QZBFriendRequest.h"
#import "QZBAnotherUser.h"

@interface QZBFriendRequest()
@property(strong, nonatomic) NSNumber *requestID;
@end

@implementation QZBFriendRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    NSDictionary *d = nil;
    if(dict[@"player"] && ![dict[@"player"]isEqual:[NSNull null]]){
        d = dict[@"player"];
    }else if(dict[@"friend"] && ![dict[@"friend"]isEqual:[NSNull null]]){
        d = dict[@"friend"];
    }
    
    self = [super initWithDictionary:d];
    if (self) {
        self.requestID = dict[@"id"];
    }
    return self;
}

@end
