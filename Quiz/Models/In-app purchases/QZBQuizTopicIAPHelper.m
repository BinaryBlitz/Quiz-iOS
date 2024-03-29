#import "QZBQuizTopicIAPHelper.h"
#import "QZBServerManager.h"

@interface QZBQuizTopicIAPHelper ()

@property (strong, nonatomic) NSSet *identifiers;

@end

@implementation QZBQuizTopicIAPHelper

+ (QZBQuizTopicIAPHelper *)sharedInstance {
  static dispatch_once_t once;
  static QZBQuizTopicIAPHelper *sharedInstance;
  dispatch_once(&once, ^{

    sharedInstance = [[self alloc] init];
  });

  return sharedInstance;
}

- (void)getTopicIdentifiersFromServerOnSuccess:(void (^)())success
                                     onFailure:(void (^)(NSError *error, NSInteger statusCode))failure {

  [[QZBServerManager sharedManager] GETInAppPurchasesOnSuccess:^(NSSet *purchases) {

    [self setProductIdentifiersFromProducts:purchases];

    if (success) {
      success();
    }
  }                                                  onFailure:^(NSError *error, NSInteger statusCode) {

    if (failure) {
      failure(error, statusCode);
    }
  }];
}


@end
