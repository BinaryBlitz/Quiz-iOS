#import <Foundation/Foundation.h>

@interface QZBUserStatistic : NSObject

@property (strong, nonatomic, readonly) NSNumber *losses;
@property (strong, nonatomic, readonly) NSNumber *wins;

@property (strong, nonatomic, readonly) NSNumber *totalDraws;
@property (strong, nonatomic, readonly) NSNumber *totaLosses;
@property (strong, nonatomic, readonly) NSNumber *totalWins;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
