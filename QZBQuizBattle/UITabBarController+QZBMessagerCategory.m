//
//  UIViewController+QZBMessagerCategory.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 12/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "UITabBarController+QZBMessagerCategory.h"
#import <TSMessage.h>
#import <TSMessageView.h>
#import "QZBMessagerManager.h"
#import "QZBMessangerList.h"
#import "QZBSessionManager.h"

@implementation UITabBarController (QZBMessagerCategory)


-(void)showMessage:(NSString *)messge userName:(NSString *)userName{
    
    NSString *title = [NSString stringWithFormat:@"От: %@",userName];
    
    
//    [TSMessage showNotificationInViewController:self title:title
//                                       subtitle:messge
//                                           type:TSMessageNotificationTypeMessage];
    
    if(![[QZBSessionManager sessionManager] isGoing]){
    
    [TSMessage showNotificationInViewController:self
                                          title:title subtitle:messge
                                          image:[UIImage imageNamed:@"messageIcon"]
                                           type:TSMessageNotificationTypeMessage
                                       duration:0.0 callback:^{
                                           [self showMessageList];}
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionNavBarOverlay
                           canBeDismissedByUser:YES];
    }
    
    
    
    
}

- (void)messageReciever:(NSNotification *)note {
    if([note.name isEqualToString:QZBMessageRecievedNotificationIdentifier]){
        NSDictionary *payload = note.object;
        
        [self showMessage:payload[@"message"] userName:payload[@"username"]];
    }
}

- (void)subscribeToMessages{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReciever:) name:QZBMessageRecievedNotificationIdentifier object:nil];
}

-(void)unsubscribeFromMessages{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:QZBMessageRecievedNotificationIdentifier
                                                  object:nil];
    
   // [TSMessage  queuedMessages]
    
   // [TSMessage dismissActiveNotification];
    [self dismissAllActiveNotifications];
}

-(void)dismissAllActiveNotifications {

    NSArray *quedMessages = [TSMessage queuedMessages];
    for(TSMessageView *m in quedMessages){
//        NSLog(@"%@", m);
//        [TSMessage dismissActiveNotification];
        
        [m fadeMeOut];
    }

}

-(void)showMessageList{
    
    NSLog(@"message");
    
    self.selectedIndex = 1;
    
    UINavigationController *nav = self.viewControllers[1];
    
    [nav popToRootViewControllerAnimated:NO];
    QZBMessangerList *messList = [nav.storyboard
                                  instantiateViewControllerWithIdentifier:@"messagerList"];
    
    [nav pushViewController:messList animated:YES];
    
    
    
}

@end
