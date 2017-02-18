#import "QZBAnswer.h"

@interface QZBAnswer ()

@property (nonatomic, assign) NSUInteger answerNum;
@property (nonatomic, assign) NSUInteger time;

@end

@implementation QZBAnswer

- (instancetype)initWithAnswerNumber:(NSUInteger)answerNum answerTime:(NSUInteger)time {
    self = [super init];
    if (self) {
        self.answerNum = answerNum;
        self.time = time;
    }
    return self;
}

@end
