#import <Foundation/Foundation.h>
#import "QZBUserProtocol.h"

@class QZBUser;
@class QZBQuestion;
@class QZBQuestionWithUserAnswer;

@interface QZBUserInSession : NSObject

@property (strong, nonatomic) id<QZBUserProtocol> user;
@property (nonatomic, assign) NSUInteger currentScore;
@property (nonatomic, strong) NSMutableArray *userAnswers;  // QZBQuestionWithUserAnswer

- (instancetype)initWithUser:(id<QZBUserProtocol>)user;

- (BOOL)couldAnswerAfterTime:(QZBQuestion *)question;
- (QZBQuestionWithUserAnswer *)findQuestionAndAnswerWithQuestion:(QZBQuestion *)question;

@end
