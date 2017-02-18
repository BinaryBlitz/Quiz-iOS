#import "QZBUserInRating.h"

@implementation QZBUserInRating

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    return [self initWithDictionary:dict position:0];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict position:(NSInteger)position {
    self = [super initWithDictionary:dict];
    if (self) {
        NSInteger points = 0;
        if(dict[@"points"] && ![dict[@"points"] isEqual:[NSNull null]]){
            points = [dict[@"points"] integerValue];
        }
        
        self.points = points;
        self.position = position;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        QZBUserInRating *obj = (QZBUserInRating *)object;
        if (self.userID == obj.userID) {
            return YES;
        }
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.userID unsignedIntegerValue];
}

@end
