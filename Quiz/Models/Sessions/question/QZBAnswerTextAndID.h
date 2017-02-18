#import <Foundation/Foundation.h>

@interface QZBAnswerTextAndID : NSObject

@property (copy, nonatomic, readonly) NSString *answerText;
@property (assign, nonatomic, readonly) NSInteger answerID;

- (instancetype)initWithText:(NSString *)answer answerID:(NSInteger)answerID;

@end
