#import <Foundation/Foundation.h>
@class LYRClient;
@class QZBAnotherUserWithLastMessages;

@interface QZBLayerMessagerManager : NSObject

@property (nonatomic, readonly) LYRClient *layerClient;

- (void)connectWithCompletion:(void (^)(BOOL success, NSError * error))completion;

+ (instancetype)sharedInstance;


-(NSInteger)unreadedCount;

-(NSArray *)conversations;

- (void)updateConversations;

- (void)deleteConversationLocalyForUser:(QZBAnotherUserWithLastMessages *)user;

-(void)logOut;

-(void)logOutWithCompletion:(void (^)(BOOL success, NSError *error))completion;

@end
