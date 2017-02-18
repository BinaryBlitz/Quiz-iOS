#import "QZBIAPHelper.h"

@interface QZBQuizTopicIAPHelper : QZBIAPHelper

+ (QZBQuizTopicIAPHelper *)sharedInstance;
-(void)getTopicIdentifiersFromServerOnSuccess:(void (^)())success
                                    onFailure:(void (^)(NSError *error, NSInteger statusCode))failure;




@end
