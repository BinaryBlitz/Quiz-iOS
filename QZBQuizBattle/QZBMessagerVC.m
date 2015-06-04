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

//#import <XMPPFramework/XMPPFramework.h>
//#import "XMPPCoreDataStorage.h"
//#import "XMPPMessageArchiving.h"
//#import "XMPPMessageArchivingCoreDataStorage.h"


@interface QZBMessagerVC ()

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) JSQMessagesAvatarImage *myAvatar;
@property (strong, nonatomic) JSQMessagesAvatarImage *friendAvatar;

@property (strong, nonatomic) id<QZBUserProtocol> friend;

//@property(strong, nonatomic) XMPPStream *stream;

//@property(weak, nonatomic) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingStorage;
//
//@property(strong, nonatomic) XMPPMessageArchiving *xmppMessageArchivingModule;
//@property(strong, nonatomic) XMPPReconnect *xmppReconnect;

@end

@implementation QZBMessagerVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.senderId = [[QZBCurrentUser sharedInstance].user.userID stringValue];
    self.senderDisplayName = [QZBCurrentUser sharedInstance].user.name;
    // self.showLoadEarlierMessagesHeader = YES;
    self.inputToolbar.contentView.leftBarButtonItem = nil;

    //    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    //    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;

    [self initAvatars];

    self.messages = [NSMutableArray array];

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];

    self.outgoingBubbleImageData = [bubbleFactory
        outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    self.incomingBubbleImageData =
        [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];

    // Do any additional setup after loading the view.
    
    //[self.view setBackgroundColor:[UIColor darkGrayColor]];
    
    
    
    [self setNeedsStatusBarAppearanceUpdate];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectionView setBackgroundColor:[UIColor darkGrayColor]];
    
   // [self initMessager];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.inputToolbar.contentView.textView becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
  //  [self goOffline];
//    [self.stream removeDelegate:self];
//    [self.stream disconnect];
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
    NSURLRequest *request = [NSURLRequest requestWithURL:self.friend.imageURL];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                               id responseObject) {

        self.friendAvatar = [JSQMessagesAvatarImageFactory
            avatarImageWithImage:responseObject
                        diameter:kJSQMessagesCollectionViewAvatarSizeDefault];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
    
    NSURLRequest *requestForMyAva = [NSURLRequest
                                     requestWithURL:[QZBCurrentUser sharedInstance].user.imageURL];
    
    AFHTTPRequestOperation *operationForMyAva = [[AFHTTPRequestOperation alloc]
                                                 initWithRequest:requestForMyAva];
    
    operationForMyAva.responseSerializer = [AFImageResponseSerializer serializer];
    
    [operationForMyAva setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                               id responseObject) {
        
        self.myAvatar = [JSQMessagesAvatarImageFactory
                             avatarImageWithImage:responseObject
                             diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", error);
    }];

    

    [operationForMyAva start];
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

    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
   // [self sendMessageWithText:text];

    [self.messages addObject:message];
    
    

    //  [self.demoData.messages addObject:message];

    [self finishSendingMessageAnimated:YES];
    
   // [self receiveMessage:text];
}

-(void)receiveMessage:(NSString *)message{
    
    //JSQMessage *copyMessage = [[self.messages lastObject] copy];
    
    
    JSQMessage *copyMessage = [JSQMessage messageWithSenderId:[self.friend.userID stringValue]
                                                  displayName:self.friend.name
                                                         text:message];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
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

//-(void)initMessager{
//   // NSString *toUser = [NSString stringWithFormat:@"id%@@localhost", self.friend.userID];
//    
//    self.stream = [[XMPPStream alloc] init];
//    [self.stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    
////    xmppReconnect = [[XMPPReconnect alloc]init];
////    [xmppReconnect activate:self.xmppStream];
//
//   // self.stream addDelegate:self delegateQueue:DI
//    
//    QZBUser *user = [QZBCurrentUser sharedInstance].user;
//    
//    NSString *userJID = [NSString stringWithFormat:@"id%@@localhost", user.userID];
//    
//    NSLog(@"%@",userJID);
//    
//    self.stream.myJID =  [XMPPJID jidWithString:userJID];
//    self.stream.hostName = @"binaryblitz.ru";
//
//    
//    NSError *error = nil;
//   // self.stream conn
//    
//    if (![self.stream connectWithTimeout:10 error:&error])
//    {
//        NSLog(@"Oops, I probably forgot something: %@", error);
//    }else{
//        NSLog(@"OOKey %@", self.stream);
//    }
//    
////    self.xmppMessageArchivingStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
////    self.xmppMessageArchivingModule =  [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:self.xmppMessageArchivingStorage];
////    
////    [self.xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
////    
////    [self.xmppMessageArchivingModule activate:self.stream];
////    [self.xmppMessageArchivingModule  addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    
//   // [self goOnline];
//}
//
//- (void)goOnline {
//    XMPPPresence *presence = [XMPPPresence presence];
//    [[self stream] sendElement:presence];
//}
//
//- (void)goOffline {
//    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
//    [[self stream] sendElement:presence];
//}
//
//- (void)xmppStreamDidConnect:(XMPPStream *)sender
//{
//    NSLog(@"kkkkk");
//    QZBUser *user = [QZBCurrentUser sharedInstance].user;
//    NSError *error = nil;
//    
//    NSLog(@"password %@",user.xmppPassword);
//    
//    if(![sender authenticateWithPassword:user.xmppPassword error:&error]){
//        NSLog(@"problems %@",error );
//    }else{
//        NSLog(@"okkkk");
//      //  [self goOnline];
//    }
//}
//
//-(void)xmppStreamDidRegister:(XMPPStream *)sender{
//    NSLog(@"registred");
//  //  [self goOnline];
//}
//
//- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
//    NSLog(@"DidAuthenticate");
//    [self goOnline];
//
//}
//
//- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
//    NSLog(@"DidNOTAuthenticate err %@", error);
//}
//
//- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
//    
////    NSString *presenceType = [presence type]; // online/offline
////    NSString *myUsername = [[sender myJID] user];
////    NSString *presenceFromUser = [[presence from] user];
////    
////    if (![presenceFromUser isEqualToString:myUsername]) {
////        
////        if ([presenceType isEqualToString:@"available"]) {
////            
////            [_chatDelegate newBuddyOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
////            
////        } else if ([presenceType isEqualToString:@"unavailable"]) {
////            
////            [_chatDelegate buddyWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"jerry.local"]];
////            
////        }
////        
////    }
//    
//}
//
//- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
//    
//    // message received
//    
//
//    //XMPPMessageArchiving *a
//    
//    NSLog(@"res");
//    
//    NSString *msg = [[message elementForName:@"body"] stringValue];
// //   NSString *from = [[message attributeForName:@"from"] stringValue];
//    
//    NSLog(@"message %@", msg);
//    
//    JSQMessage *mess = [JSQMessage messageWithSenderId:[self.friend.userID stringValue]
//                                          displayName:self.friend.name
//                                                 text:msg];
//    
//    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
//    [self.messages addObject:mess];
//    [self finishReceivingMessageAnimated:YES];
//    
//    
//    
////    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
////    [m setObject:msg forKey:@"msg"];
////    [m setObject:from forKey:@"sender"];
//    
//   // [_messageDelegate newMessageReceived:m];
//   // [m release];
//    
//    
//}
//
//
//
//
//-(void)sendMessageWithText:(NSString *)textMessage{
//    
//    NSString *messageStr = textMessage;
//    
//    if([messageStr length] > 0) {
//        
//        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//        [body setStringValue:messageStr];
//        
//        NSString *toUser = [NSString stringWithFormat:@"id%@@localhost", self.friend.userID];
//        
//        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
//        [message addAttributeWithName:@"type" stringValue:@"chat"];
//        [message addAttributeWithName:@"to" stringValue:toUser];//REDO
//        [message addChild:body];
//        
//        [self.stream sendElement:message];
//        
//        
//       // [self testMessageArchiving];
//        
//       // self.messageField.text = @"";
//        
////        NSString *m = [NSString stringWithFormat:@"%@:%@", messageStr, @"you"];
////        
////        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
////        [m setObject:messageStr forKey:@"msg"];
////        [m setObject:@"you" forKey:@"sender"];
////        
////        [messages addObject:m];
////        [self.tView reloadData];
////        [m release];
//        
//    }
//    
//}
//
#pragma mark - support methods

- (void)initAvatars {
   

    self.myAvatar = [JSQMessagesAvatarImageFactory
        avatarImageWithImage:[UIImage imageNamed:@"userpicStandart"]
                    diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    self.friendAvatar = [JSQMessagesAvatarImageFactory
        avatarImageWithImage:[UIImage imageNamed:@"userpicStandart"]
                    diameter:kJSQMessagesCollectionViewAvatarSizeDefault];

}


#pragma mark - test methods


//-(void)testMessageArchiving{
//    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
//    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
//                                                         inManagedObjectContext:moc];
//    NSFetchRequest *request = [[NSFetchRequest alloc]init];
//    [request setEntity:entityDescription];
//    NSError *error;
//    NSArray *messages = [moc executeFetchRequest:request error:&error];
//    
//    [self print:[[NSMutableArray alloc]initWithArray:messages]];
//}
//
//-(void)print:(NSMutableArray*)messages{
//    
//        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages) {
//            NSLog(@"messageStr param is %@",message.messageStr);
//            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
//            NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
//            NSLog(@"NSCore object id param is %@",message.objectID);
//            NSLog(@"bareJid param is %@",message.bareJid);
//            NSLog(@"bareJidStr param is %@",message.bareJidStr);
//            NSLog(@"body param is %@",message.body);
//            NSLog(@"timestamp param is %@",message.timestamp);
//            NSLog(@"outgoing param is %d",[message.outgoing intValue]);
//        }
//    
//}

@end
