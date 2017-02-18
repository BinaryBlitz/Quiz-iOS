#import <Foundation/Foundation.h>

@interface QZBAnswer : NSObject

@property (assign, nonatomic, readonly) NSUInteger answerNum;
@property (assign, nonatomic, readonly) NSUInteger time;
@property (copy, nonatomic, readonly) NSString *answer;
@property (assign, nonatomic, readonly) NSInteger *answerId;

- (instancetype)initWithAnswerNumber:(NSUInteger)answerNum answerTime:(NSUInteger)time;

@end
