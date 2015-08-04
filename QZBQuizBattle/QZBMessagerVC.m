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
//#import "QZBMessagerManager.h"
#import <TSMessage.h>
#import "QZBServerManager.h"
#import "QZBPlayerPersonalPageVC.h"
#import "UIViewController+QZBControllerCategory.h"
#import "QZBUserWorker.h"
#import <NSDate+DateTools.h>

#import <LayerKit/LayerKit.h>
#import "QZBLayerMessagerManager.h"


//#import <XMPPFramework/XMPPFramework.h>
//#import "XMPPCoreDataStorage.h"
//#import "XMPPMessageArchiving.h"
//#import "XMPPMessageArchivingCoreDataStorage.h"

NSString *const QZBSegueToUserPageIdentifier = @"showBuddy";
const NSTimeInterval QZBMessageTimeInterval = 600;

@interface QZBMessagerVC () < LYRQueryControllerDelegate>

//@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) JSQMessagesAvatarImage *myAvatar;
@property (strong, nonatomic) JSQMessagesAvatarImage *friendAvatar;

@property (strong, nonatomic) id<QZBUserProtocol> friend;

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic, retain) LYRQueryController *queryController;

@property (weak, nonatomic) LYRClient *layerClient;

@end

@implementation QZBMessagerVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initStatusbarWithColor:[UIColor blackColor]];

   // [QZBMessagerManager sharedInstance].delegate = self;

    // self.senderId = [[QZBCurrentUser sharedInstance].user.userID stringValue];

    self.senderId =  [QZBCurrentUser sharedInstance].user.userID.stringValue;// [[QZBMessagerManager sharedInstance]
      //  jidAsStringFromUser:[QZBCurrentUser sharedInstance].user];
    self.senderDisplayName = [QZBCurrentUser sharedInstance].user.userID.stringValue;
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
    
    self.layerClient = [QZBLayerMessagerManager sharedInstance].layerClient;

    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBDoNotNeedShowMessagerNotifications"
                                                        object:nil];

    [self.collectionView setBackgroundColor:[UIColor darkGrayColor]];

  //  self.messages = [[QZBMessagerManager sharedInstance] generateJSQMessagesForUser:self.friend];

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
    
    [self setupLayerNotificationObservers];
    [self fetchLayerConversation];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //  [self goOffline];
    //    [self.stream removeDelegate:self];
    //    [self.stream disconnect];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedShowMessagerNotifications"
                                                        object:nil];
    
    
//    QZBUserWorker *userWorker = [[QZBUserWorker alloc] init];
    
//    QZBStoredUser *storedUser = [userWorker userWithID:self.friend.userID];
    
//    if(storedUser){
//        [userWorker readAllMessages:storedUser];
//    }
   
    

 //   self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWithUser:(id<QZBUserProtocol>)user {
    self.title = user.name;
    self.friend = user;
    
    [self setupLayerNotificationObservers];
   // [self fetchLayerConversation];
    
//    [[QZBServerManager sharedManager] GETAllMessagesForUserId:user.userID onSuccess:^(NSArray *messages) {
//        
//    } onFailure:^(NSError *error, NSInteger statusCode) {
//        
//    }];

    [self updateImages];
}

//- (void)initWithUser:(id<QZBUserProtocol>)user userpic:(UIImage *)image {
//    [self initWithUser:user];
//
//    self.friendAvatar = [JSQMessagesAvatarImageFactory
//        avatarImageWithImage:image
//                    diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
//}

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

//    if (![QZBMessagerManager sharedInstance].isConnected) {
//        NSLog(@"problems!!");
//        //        [TSMessage showNotificationWithTitle:@"Невозможно подключиться к серверу"
//        //                                    subtitle:QZBNoInternetConnectionMessage
//        //                                        type:TSMessageNotificationTypeError];
//
//        [TSMessage
//            showNotificationInViewController:self.navigationController
//                                       title:@"Невозможно подключиться к "
//                                             @"серверу"
//                                    subtitle:QZBNoInternetConnectionMessage
//                                        type:TSMessageNotificationTypeError
//                                    duration:0.0
//                        canBeDismissedByUser:YES];
//        return;
//    }

//    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
//                                             senderDisplayName:senderDisplayName
//                                                          date:date
//                                                          text:text];

    [self sendMessage:text];
    
//    - (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
//    {
//        // Get nav bar colors from conversation metadata
//        [self setNavbarColorFromConversationMetadata:self.conversation.metadata];
        [self fetchLayerConversation];
  //  }
    //[self sendMessageWithText:text];

   // [self.messages addObject:message];

    //  [self.demoData.messages addObject:message];

    [self finishSendingMessageAnimated:YES];

    // [self receiveMessage:text];
}

//- (void)receiveMessage:(NSString *)message {
//    // JSQMessage *copyMessage = [[self.messages lastObject] copy];
//
//    JSQMessage *copyMessage = [JSQMessage messageWithSenderId:[self.friend.userID stringValue]
//                                                  displayName:self.friend.name
//                                                         text:message];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
//                   dispatch_get_main_queue(), ^{
//
//                       [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
//                    //   [self.messages addObject:copyMessage];
//                       [self finishReceivingMessageAnimated:YES];
//
//                   });
//}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView
       messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    LYRMessage *message = [self.queryController objectAtIndexPath:indexPath];
//    LYRMessagePart *messagePart = message.parts[0];
//    NSString *text = [[NSString alloc]initWithData:messagePart.data
//                                          encoding:NSUTF8StringEncoding];
    
    JSQMessage *messageView = [self messageAtIndexPath:indexPath];
    
    return messageView;//[self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */

    JSQMessage *message = [self messageAtIndexPath:indexPath]; //[self.messages objectAtIndex:indexPath.item];

    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }

    return self.incomingBubbleImageData;

  //  return nil;
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
    JSQMessage *message = [self messageAtIndexPath:indexPath];//[self.messages objectAtIndex:indexPath.item];

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
    
    NSInteger rows = [self.queryController numberOfObjectsInSection:0];
    return rows;
    //return [self.messages count];
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

    JSQMessage *msg =  [self messageAtIndexPath:indexPath];//[self.messages objectAtIndex:indexPath.item];

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

//- (void)sendMessageWithText:(NSString *)textMessage {
//    [[QZBMessagerManager sharedInstance] sendMessage:textMessage toUser:self.friend];
//}

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

//- (void)didRecieveMessageFrom:(NSString *)bareJid text:(NSString *)text {
//    if ([bareJid isEqualToString:[[QZBMessagerManager sharedInstance]
//                                     jidAsStringFromUser:self.friend]]) {
//        JSQMessage *mess =
//            [JSQMessage messageWithSenderId:bareJid displayName:self.friend.name text:text];
//
//        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
//        //[self.messages addObject:mess];
//        [self finishReceivingMessageAnimated:YES];
//    }
//}

#pragma mark - date

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath{
//    if(self.messages.count > 0 && indexPath.item == 0){
//        JSQMessage *message = self.messages[indexPath.item];
//        
//        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
//    } else if(indexPath.item > 0){
//       // NSDate *firstDate =
//      //  NSTimeInterval timeInterval = self.messages[indexPath.item] indexPath.item
//        
//        JSQMessage *firstMessage = self.messages[indexPath.item];
//        JSQMessage *secondMessage = self.messages[indexPath.item-1];
//        
//        
//        
//        NSDate *firstDate = firstMessage.date;
//        NSDate *secondDate = secondMessage.date;
//        
//        NSTimeInterval timeInterval = [firstDate timeIntervalSinceDate:secondDate];
//        
//        if(timeInterval> QZBMessageTimeInterval){
//            return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:firstMessage.date];
//        }
//        
//    }
    
//    if (indexPath.item % 3 == 0) {
//        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
//        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
//    }
    
    return nil;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
   // if (indexPath.item % 3 == 0) {
      //  return kJSQMessagesCollectionViewCellLabelHeightDefault;
  //  }
    
   // return 0.0f;
    
    
//    if(self.messages.count > 0 && indexPath.item == 0){
//     //   JSQMessage *message = self.messages[indexPath.item];
//        return kJSQMessagesCollectionViewCellLabelHeightDefault;//[[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
//    } else if(indexPath.item > 0){
//        // NSDate *firstDate =
//        //  NSTimeInterval timeInterval = self.messages[indexPath.item] indexPath.item
//        
//        JSQMessage *firstMessage = self.messages[indexPath.item];
//        JSQMessage *secondMessage = self.messages[indexPath.item-1];
//        
//        
//        
//        NSDate *firstDate = firstMessage.date;
//        NSDate *secondDate = secondMessage.date;
//        
//        NSTimeInterval timeInterval = [firstDate timeIntervalSinceDate:secondDate];
//        
//        if(timeInterval>QZBMessageTimeInterval){
//            return  kJSQMessagesCollectionViewCellLabelHeightDefault;//[[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:firstMessage.date];
//        }
//        
//    }
    
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
 didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *m = [self messageAtIndexPath:indexPath];//self.messages[indexPath.row];
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

- (void)sendMessage:(NSString *)messageText{
    
    // Send a Message
    // See "Quick Start - Send a Message" for more details
    // https://developer.layer.com/docs/quick-start/ios#send-a-message
    
    LYRMessagePart *messagePart;
   // self.messageImage.image = nil;
    // If no conversations exist, create a new conversation object with a single participant
    if (!self.conversation) {
        [self fetchLayerConversation];
    }
    

        messagePart = [LYRMessagePart messagePartWithText:messageText];
    
    NSString *name = [QZBCurrentUser sharedInstance].user.name;

    
    // Creates and returns a new message object with the given conversation and array of message parts
    NSString *pushMessage= [NSString stringWithFormat:@"%@: %@",name ,messageText];
    LYRMessage *message = [self.layerClient newMessageWithParts:@[messagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: pushMessage, LYRMessageOptionsPushNotificationSoundNameKey: @"layerbell.caf"} error:nil];
    
    // Sends the specified message
    NSError *error;
    BOOL success = [self.conversation sendMessage:message error:&error];
    if (success) {
        // If the message was sent by the participant, show the sentAt time and mark the message as read
        NSLog(@"Message queued to be sent: %@", messageText);
        //self.inputTextView.text = @"";
        
    } else {
        NSLog(@"Message send failed: %@", error);
    }
   // self.photo = nil;
//    if (!self.queryController) {
//        [self setupQueryController];
//    }
}


- (void)fetchLayerConversation {
    // Fetches all conversations between the authenticated user and the supplied participant
    // For more information about Querying, check out https://developer.layer.com/docs/integration/ios#querying
    
   
    NSString *identifier = nil;
    
    if([self.friend.userID isKindOfClass:[NSNumber class]]){
        identifier = self.friend.userID.stringValue;
    } else {
        identifier = (NSString *)self.friend.userID;
    }
    
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsEqualTo
                                                    value:@[ identifier]];
    query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO] ];
    
    NSError *error;
    NSOrderedSet *conversations = [self.layerClient executeQuery:query error:&error];
    
    if (conversations.count <= 0) {
        NSError *conv_error = nil;
        self.conversation = [self.layerClient newConversationWithParticipants:[NSSet setWithArray:@[ identifier,self.layerClient.authenticatedUserID ]]
                                                                      options:nil
                                                                        error:&conv_error];
        [QZBUserWorker saveUser:self.friend inConversation:self.conversation];
        [QZBUserWorker saveUser:[QZBCurrentUser sharedInstance].user inConversation:self.conversation];

        
      //  [QZBUserWorker saveUser:self.friend inConversation:self.conversation];
        
        if (!self.conversation) {
            NSLog(@"New Conversation creation failed: %@", conv_error);
        }
    }
    
    if (!error) {
        NSLog(@"%tu conversations with participants %@", conversations.count, @[ identifier ]);
    } else {
        NSLog(@"Query failed with error %@", error);
    }
    
    // Retrieve the last conversation
    if (conversations.count) {
        self.conversation = [conversations lastObject];
        NSLog(@"Get last conversation object: %@",self.conversation.identifier);
        //[self.conversation delete:LYRDeletionModeAllParticipants error:nil];
        
        // setup query controller with messages from last conversation
        if (!self.queryController) {
            [self setupQueryController];
        }
    }
    
//    if(self.conversation) {
//        [QZBUserWorker saveUser:self.friend inConversation:self.conversation];
//        [QZBUserWorker saveUser:[QZBCurrentUser sharedInstance].user inConversation:self.conversation];
//    }
    
}


-(void)setupQueryController
{
    // For more information about the Query Controller, check out https://developer.layer.com/docs/integration/ios#querying
    
    // Query for all the messages in conversation sorted by position
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"conversation" predicateOperator:LYRPredicateOperatorIsEqualTo value:self.conversation];
    query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
    
    // Set up query controller
    self.queryController = [self.layerClient queryControllerWithQuery:query];
    self.queryController.delegate = self;
    
    NSError *error;
    BOOL success = [self.queryController execute:&error];
    if (success) {
        NSLog(@"Query fetched %tu message objects", [self.queryController numberOfObjectsInSection:0]);
    } else {
        NSLog(@"Query failed with error: %@", error);
    }
    [self.collectionView reloadData];
    [self.conversation markAllMessagesAsRead:nil];
}


-(JSQMessage *)messageAtIndexPath:(NSIndexPath *)path {
    LYRMessage *message = [self.queryController objectAtIndexPath:path];
    [message markAsRead:nil];
    LYRMessagePart *messagePart = message.parts[0];
    NSString *text = [[NSString alloc]initWithData:messagePart.data
                                          encoding:NSUTF8StringEncoding];
    
    JSQMessage *messageView = [JSQMessage messageWithSenderId:message.sender.userID
                                                  displayName:message.sender.userID
                                                         text:text];
    
    return messageView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupLayerNotificationObservers
{
    // Register for Layer object change notifications
    // For more information about Synchronization, check out https://developer.layer.com/docs/integration/ios#synchronization
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLayerObjectsDidChangeNotification:)
                                                 name:LYRClientObjectsDidChangeNotification
                                               object:nil];
    
//     Register for typing indicator notifications
//     For more information about Typing Indicators, check out https://developer.layer.com/docs/integration/ios#typing-indicator
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didReceiveTypingIndicator:)
//                                                 name:LYRConversationDidReceiveTypingIndicatorNotification
//                                               object:self.conversation];
//    
//    // Register for synchronization notifications
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didReceiveLayerClientWillBeginSynchronizationNotification:)
//                                                 name:LYRClientWillBeginSynchronizationNotification
//                                               object:self.layerClient];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(didReceiveLayerClientDidFinishSynchronizationNotification:)
//                                                 name:LYRClientDidFinishSynchronizationNotification
//                                               object:self.layerClient];
}


- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
    // Get nav bar colors from conversation metadata
    //[self setNavbarColorFromConversationMetadata:self.conversation.metadata];
    [self fetchLayerConversation];
}


#pragma mark - Query Controller Delegate Methods

- (void)queryControllerWillChangeContent:(LYRQueryController *)queryController
{
    //[self.tableView beginUpdates];
   // [self.collectionView reloadData];
}

- (void)queryController:(LYRQueryController *)controller
        didChangeObject:(id)object
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(LYRQueryControllerChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath
{
    
    [self finishReceivingMessage];
    
    // Automatically update tableview when there are change events
//    switch (type) {
//        case LYRQueryControllerChangeTypeInsert:
//            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
//                                  withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//        case LYRQueryControllerChangeTypeUpdate:
//            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
//                                  withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//        case LYRQueryControllerChangeTypeMove:
//            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
//                                  withRowAnimation:UITableViewRowAnimationAutomatic];
//            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
//                                  withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//        case LYRQueryControllerChangeTypeDelete:
//            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
//                                  withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//        default:
//            break;
//    }
}

- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController
{
    
    [self.collectionView reloadData];
//    [self.tableView endUpdates];
//    [self scrollToBottom];
    
}



@end
