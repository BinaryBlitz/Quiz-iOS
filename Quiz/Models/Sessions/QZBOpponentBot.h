#import <Foundation/Foundation.h>

@interface QZBOpponentBot : NSObject

- (instancetype)initWithAnswersAndTimes:(NSArray *)answersWithTime;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithHostAnswers:(NSDictionary *)dict;

@end
