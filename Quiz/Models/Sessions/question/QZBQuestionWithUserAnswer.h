#import "QZBQuestion.h"
#import "QZBAnswer.h"

@interface QZBQuestionWithUserAnswer : NSObject

@property (strong, nonatomic, readonly) QZBQuestion *question;
@property (strong, nonatomic, readonly) QZBAnswer *answer;
@property (assign, nonatomic, readonly) BOOL isRight;

- (instancetype)initWithQestion:(QZBQuestion *)qestion answer:(QZBAnswer *)answer;

@end
