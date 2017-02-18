#import "QZBUserInSession.h"
#import "QZBUser.h"
#import "QZBQuestionWithUserAnswer.h"

@implementation QZBUserInSession

- (instancetype)initWithUser:(id<QZBUserProtocol>)user {
    self = [super init];
    if (self) {
        self.user = user;
        self.currentScore = 0;
        self.userAnswers = [NSMutableArray array];
    }
    return self;
}

// return qand af if finded, or nil if not finded
- (QZBQuestionWithUserAnswer *)findQuestionAndAnswerWithQuestion:(QZBQuestion *)question {
    for (QZBQuestionWithUserAnswer *qanda in self.userAnswers) {
        if ([qanda.question isEqual:question]) {
            return qanda;
        }
    }
    return nil;
}

- (BOOL)isAnswered:(QZBQuestionWithUserAnswer *)qanda {
    if (!qanda.answer) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)couldAnswerAfterTime:(QZBQuestion *)question {
    QZBQuestionWithUserAnswer *qanda = [self findQuestionAndAnswerWithQuestion:question];
    if (qanda) {
        if (![self isAnswered:qanda]) {
            return YES;
        }
    }
    return NO;
}

@end
