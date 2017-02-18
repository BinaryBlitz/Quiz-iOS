#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const QZBPusherConnectionProblrms;
UIKIT_EXTERN NSString *const QZBPusherChallengeDeclined;

@interface QZBOnlineSessionWorker : NSObject

- (void)closeConnection;

@end
