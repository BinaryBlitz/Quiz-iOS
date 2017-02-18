#import <Foundation/Foundation.h>

@interface QZBProduct : NSObject

@property (copy, nonatomic, readonly) NSString *identifier;
@property (strong, nonatomic, readonly) NSNumber *topicID;
@property (assign, nonatomic, readonly) BOOL isPurchased;
@property (assign, nonatomic, readonly) int dayCount;

- (instancetype)initWhithDictionary:(NSDictionary *)dict;

@end
