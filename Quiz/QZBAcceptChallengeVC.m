//
//  QZBAcceptChallengeVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 17/03/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBAcceptChallengeVC.h"
#import "QZBServerManager.h"

@interface QZBAcceptChallengeVC()


@property(strong, nonatomic) NSNumber *lobbyNumber;
@property(strong, nonatomic) id<QZBUserProtocol> user;

@end

@implementation QZBAcceptChallengeVC


-(void)initWithLobbyID:(NSNumber *)lobbyID user:(id<QZBUserProtocol>)user{
    
    self.lobbyNumber = lobbyID;
    self.user = user;
    
}

-(void)initSession{
    
    NSLog(@"subclassed");
    
    self.acceptButton.enabled =YES;
    self.declineButton.enabled = YES;

    
}

#pragma mark - actions

- (IBAction)acceptAction:(id)sender {
    [[QZBServerManager sharedManager] POSTAcceptChallengeWhithLobbyID:self.lobbyNumber onSuccess:^(QZBSession *session) {
        
        [self settitingSession:session bot:nil];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        
    }];
    
}
- (IBAction)declineAction:(id)sender {
    
    [[QZBServerManager sharedManager] POSTDeclineChallengeWhithLobbyID:self.lobbyNumber onSuccess:^{
        NSLog(@"decline");
        [self.navigationController popToRootViewControllerAnimated:YES];
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"decline");
        [self.navigationController popToRootViewControllerAnimated:YES];

    }];
    
    
    
}

@end
