//
//  QZBMessagerVC.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 30/04/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBMessagerVC.h"
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import <JSQMessagesViewController/JSQMessages.h>
#import <AFNetworking/AFNetworking.h>
#import "UIColor+QZBProjectColors.h"
#import "QZBMessagerManager.h"
#import <TSMessage.h>
#import "QZBServerManager.h"
#import "QZBPlayerPersonalPageVC.h"
#import "UIViewController+QZBControllerCategory.h"
#import "QZBUserWorker.h"

//#import <XMPPFramework/XMPPFramework.h>
//#import "XMPPCoreDataStorage.h"
//#import "XMPPMessageArchiving.h"
//#import "XMPPMessageArchivingCoreDataStorage.h"

NSString *const QZBSegueToUserPageIdentifier = @"showBuddy";

@interface QZBMessagerVC () <QZBMessagerManagerDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) JSQMessagesAvatarImage *myAvatar;
@property (strong, nonatomic) JSQMessagesAvatarImage *friendAvatar;

@property (strong, nonatomic) id<QZBUserProtocol> friend;

@end

@implementation QZBMessagerVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initStatusbarWithColor:[UIColor blackColor]];

    [QZBMessagerManager sharedInstance].delegate = self;

    // self.senderId = [[QZBCurrentUser sharedInstance].user.userID stringValue];

    self.senderId = [[QZBMessagerManager sharedInstance]
        jidAsStringFromUser:[QZBCurrentUser sharedInstance].user];
    self.senderDisplayName = [QZBCurrentUser sharedInstance].user.name;
    // self.showLoadEarlierMessagesHeader = YES;
    self.inputToolbar.contentView.leftBarButtonItem = nil;

    [self initAvatars];

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];

    self.outgoingBubbleImageData =
        [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    self.incomingBubbleImageData = [bubbleFactory
        incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];

    // Do any additional setup after loading the view.

    //[self.view setBackgroundColor:[UIColor darkGrayColor]];

    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.collectionView setBackgroundColor:[UIColor darkGrayColor]];

    self.messages = [[QZBMessagerManager sharedInstance] generateJSQMessagesForUser:self.friend];

    [self.collectionView reloadData];

    self.tabBarController.tabBar.hidden = YES;
    // [self initMessager];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.inputToolbar.contentView.textView becomeFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [self scrollToBottomAnimated:YES];
                   });
}\


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //  [self goOffline];
    //    [self.stream removeDelegate:self];
    //    [self.stream disconnect];
    
    
    
    QZBUserWorker *userWorker = [[QZBUserWorker alloc] init];
    
    QZBStoredUser *storedUser = [userWorker userWithID:self.friend.userID];
    
    if(storedUser){
        [userWorker readAllMessages:storedUser];
    }
   
    

 //   self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithUser:(id<QZBUserProtocol>)user {
    self.title = user.name;
    self.friend = user;

    [self updateImages];
}

- (void)initWithUser:(id<QZBUserProtocol>)user userpic:(UIImage *)image {
    [self initWithUser:user];

    self.friendAvatar = [JSQMessagesAvatarImageFactory
        avatarImageWithImage:image
                    diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}

- (void)updateImages {
    // NSURL *url = [NSURL URLWithString:self.user.imageURL];

    if (self.friend.imageURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.friend.imageURL];

        AFHTTPRequestOperation *operation =
            [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];

        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                                   id responseObject) {

            self.friendAvatar = [JSQMessagesAvatarImageFactory
                avatarImageWithImage:responseObject
                            diameter:kJSQMessagesCollectionViewAvatarSizeDefault];

            [self.collectionView reloadData];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Error: %@", error);
        }];

        [operation start];
    }

    if ([QZBCurrentUser sharedInstance].user.imageURL) {
        NSURLRequest *requestForMyAva =
            [NSURLRequest requestWithURL:[QZBCurrentUser sharedInstance].user.imageURL];

        AFHTTPRequestOperation *operationForMyAva =
            [[AFHTTPRequestOperation alloc] initWithRequest:requestForMyAva];

        operationForMyAva.responseSerializer = [AFImageResponseSerializer serializer];

        [operationForMyAva setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                                           id responseObject) {

            self.myAvatar = [JSQMessagesAvatarImageFactory
                avatarImageWithImage:responseObject
                            diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
            [self.collectionView reloadData];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            NSLog(@"Error: %@", error);
        }];

        [operationForMyAva start];
    }
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date {
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    //[JSQSystemSoundPlayer jsq_playMessageSentSound];

    if (![QZBMessagerManager sharedInstance].isConnected) {
        NSLog(@"problems!!");
        //        [TSMessage showNotificationWithTitle:@"Невозможно подключиться к серверу"
        //                                    subtitle:QZBNoInternetConnectionMessage
        //                                        type:TSMessageNotificationTypeError];

        [TSMessage
            showNotificationInViewController:self.navigationController
                                       title:@"Невозможно подключиться к "
                                             @"серверу"
                                    subtitle:QZBNoInternetConnectionMessage
                                        type:TSMessageNotificationTypeError
                                    duration:0.0
                        canBeDismissedByUser:YES];
        return;
    }

    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];

    [self sendMessageWithText:text];

    [self.messages addObject:message];

    //  [self.demoData.messages addObject:message];

    [self finishSendingMessageAnimated:YES];

    // [self receiveMessage:text];
}

- (void)receiveMessage:(NSString *)message {
    // JSQMessage *copyMessage = [[self.messages lastObject] copy];

    JSQMessage *copyMessage = [JSQMessage messageWithSenderId:[self.friend.userID stringValue]
                                                  displayName:self.friend.name
                                                         text:message];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{

                       [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                       [self.messages addObject:copyMessage];
                       [self finishReceivingMessageAnimated:YES];

                   });
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView
       messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */

    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];

    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }

    return self.incomingBubbleImageData;

    return nil;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */

    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];

    if ([message.senderId isEqualToString:self.senderId]) {
        return self.myAvatar;
    } else {
        return self.friendAvatar;
    }

    // return [self.demoData.avatars objectForKey:message.senderId];
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)
        [super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the
     *font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from
     *`viewDidLoad`
     */

    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];

    if (!msg.isMediaMessage) {
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        } else {
            cell.textView.textColor = [UIColor blackColor];
        }

        cell.textView.linkTextAttributes = @{
            NSForegroundColorAttributeName : cell.textView.textColor,
            NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid)
        };
    }

    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before
navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - server methods

- (void)sendMessageWithText:(NSString *)textMessage {
    [[QZBMessagerManager sharedInstance] sendMessage:textMessage toUser:self.friend];
}

#pragma mark - support methods

- (void)initAvatars {
    self.myAvatar = [JSQMessagesAvatarImageFactory
        avatarImageWithImage:[UIImage imageNamed:@"userpicStandart"]
                    diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    self.friendAvatar = [JSQMessagesAvatarImageFactory
        avatarImageWithImage:[UIImage imageNamed:@"userpicStandart"]
                    diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}

#pragma mark - message delegate

//-(void) receivedMessage
//
//- (void) myClassDelegateMethod: (QZBMessagerManager *) sender{
//
//    NSLog(@"recieved");
//
//}
//-(void)didRecieveMessageFrom:(NSString *)bareJid{
//    NSLog(@"%@", bareJid);
//
//    if([bareJid isEqualToString:[[QZBMessagerManager sharedInstance]
//    jidAsStringFromUser:self.friend]]){
//
//    }
//}

- (void)didRecieveMessageFrom:(NSString *)bareJid text:(NSString *)text {
    if ([bareJid isEqualToString:[[QZBMessagerManager sharedInstance]
                                     jidAsStringFromUser:self.friend]]) {
        JSQMessage *mess =
            [JSQMessage messageWithSenderId:bareJid displayName:self.friend.name text:text];

        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self.messages addObject:mess];
        [self finishReceivingMessageAnimated:YES];
    }
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
 didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *m = self.messages[indexPath.row];
    if (![m.senderId isEqualToString:self.senderId]) {
        [self performSegueWithIdentifier:QZBSegueToUserPageIdentifier sender:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:QZBSegueToUserPageIdentifier]) {
        QZBPlayerPersonalPageVC *destVC =
            (QZBPlayerPersonalPageVC *)segue.destinationViewController;

        [destVC initPlayerPageWithUser:self.friend];
    }
}



@end
