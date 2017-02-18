#import "QZBMessagerVC.h"
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import <JSQMessagesViewController/JSQMessages.h>
#import <AFNetworking/AFNetworking.h>
#import "UIColor+QZBProjectColors.h"
#import <TSMessage.h>
#import "QZBServerManager.h"
#import "QZBPlayerPersonalPageVC.h"
#import "UIViewController+QZBControllerCategory.h"
#import "QZBUserWorker.h"
#import <NSDate+DateTools.h>

#import <LayerKit/LayerKit.h>
#import "QZBLayerMessagerManager.h"

NSString *const QZBSegueToUserPageIdentifier = @"showBuddy";
const NSTimeInterval QZBMessageTimeInterval = 600;

@interface QZBMessagerVC () <LYRQueryControllerDelegate>

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

  // self.automaticallyScrollsToMostRecentMessage = YES;

  //  self.inputToolbar.contentView.textView.delegate = self;

  self.senderId = [QZBCurrentUser sharedInstance].user.userID.stringValue;
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

  if ([[QZBCurrentUser sharedInstance] needStartMessager] &&
      ![QZBLayerMessagerManager sharedInstance].layerClient.authenticatedUser.userID) {
    [[QZBLayerMessagerManager sharedInstance]
     connectWithCompletion:^(BOOL success, NSError *error){

     }];
  }

  [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [[NSNotificationCenter defaultCenter]
   postNotificationName:@"QZBDoNotNeedShowMessagerNotifications"
   object:nil];

  [self.collectionView setBackgroundColor:[UIColor darkGrayColor]];

  [self.collectionView reloadData];

  self.tabBarController.tabBar.hidden = YES;

  //    [[NSNotificationCenter defaultCenter] addObserver:self
  //                                             selector:@selector(didReceiveTypingIndicator:)
  //                                                 name:LYRConversationDidReceiveTypingIndicatorNotification
  //                                               object:nil];

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
  NSOrderedSet *convs = [self conversationsWithFriend];
  if (convs.count > 0) {
    [self fetchLayerConversation];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  //   [[NSNotificationCenter defaultCenter] removeObserver:self];

  [[NSNotificationCenter defaultCenter] postNotificationName:@"QZBNeedShowMessagerNotifications"
                                                      object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)initWithUser:(id<QZBUserProtocol>)user {
  self.title = user.name;
  self.friend = user;

  [self setupLayerNotificationObservers];

  [self updateImages];
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
  NSLog(@"layer conv %@", self.conversation);

  if (!self.conversation) {
    [[QZBServerManager sharedManager] PATCHNeedAuthenticateLayerForUserWithID:self.friend.userID
                                                                    onSuccess:^{
                                                                      if (![QZBLayerMessagerManager sharedInstance].layerClient.authenticatedUser.userID) {
                                                                        [[QZBLayerMessagerManager sharedInstance]
                                                                         connectWithCompletion:^(BOOL success, NSError *error) {
                                                                           [self sendMessageCommon:text];
                                                                         }];
                                                                      } else {
                                                                        [self sendMessageCommon:text];
                                                                      }

                                                                    }
                                                                    onFailure:^(NSError *error, NSInteger statusCode) {
                                                                      [TSMessage showNotificationWithTitle:@"Подключение к серверу"
                                                                                                  subtitle:@"Попробуйте позже"
                                                                                                      type:TSMessageNotificationTypeError];
                                                                    }];
  } else {
    [self sendMessageCommon:text];
  }
}

- (void)sendMessageCommon:(NSString *)text {
  if ([QZBLayerMessagerManager sharedInstance].layerClient.isConnected) {
    // NSLog(@"layer conv %@",self.conversation);
    [self sendMessage:text];
    [self fetchLayerConversation];
    [self finishSendingMessageAnimated:YES];

  } else {
    [TSMessage showNotificationWithTitle:@"Подключение к серверу"
                                subtitle:@"Попробуйте позже"
                                    type:TSMessageNotificationTypeError];
  }
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView
       messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
  //    LYRMessage *message = [self.queryController objectAtIndexPath:indexPath];
  //    LYRMessagePart *messagePart = message.parts[0];
  //    NSString *text = [[NSString alloc]initWithData:messagePart.data
  //                                          encoding:NSUTF8StringEncoding];

  JSQMessage *messageView = [self messageAtIndexPath:indexPath];

  return messageView;  //[self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
  /**
   *  You may return nil here if you do not want bubbles.
   *  In this case, you should set the background color of your collection view cell's textView.
   *
   *  Otherwise, return your previously created bubble image data objects.
   */

  JSQMessage *message =
  [self messageAtIndexPath:indexPath];  //[self.messages objectAtIndex:indexPath.item];

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
  JSQMessage *message =
  [self messageAtIndexPath:indexPath];  //[self.messages objectAtIndex:indexPath.item];

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
  // return [self.messages count];
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

  JSQMessage *msg =
  [self messageAtIndexPath:indexPath];  //[self.messages objectAtIndex:indexPath.item];

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

#pragma mark - support methods

- (void)initAvatars {
  self.myAvatar = [JSQMessagesAvatarImageFactory
                   avatarImageWithImage:[UIImage imageNamed:@"userpicStandart"]
                   diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
  self.friendAvatar = [JSQMessagesAvatarImageFactory
                       avatarImageWithImage:[UIImage imageNamed:@"userpicStandart"]
                       diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
}

#pragma mark - date

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView
attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
  if (self.queryController.count > 0 && indexPath.item == 0) {
    // JSQMessage *message = self.messages[indexPath.item];
    NSDate *firstDate = [[self.queryController objectAtIndexPath:indexPath] sentAt];
    return
    [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:firstDate];
  } else if (indexPath.item > 0) {
    // NSDate *firstDate =
    //  NSTimeInterval timeInterval = self.messages[indexPath.item] indexPath.item
    NSIndexPath *nip =
    [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
    NSDate *firstDate =
    [[self.queryController objectAtIndexPath:indexPath] sentAt];  // firstMessage.date;
    NSDate *secondDate =
    [[self.queryController objectAtIndexPath:nip] sentAt];  // secondMessage.date;

    NSTimeInterval timeInterval = [firstDate timeIntervalSinceDate:secondDate];

    if (timeInterval > QZBMessageTimeInterval) {
      return [[JSQMessagesTimestampFormatter sharedFormatter]
              attributedTimestampForDate:firstDate];
    }
  }

  //    if (indexPath.item % 3 == 0) {
  //        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
  //        return [[JSQMessagesTimestampFormatter sharedFormatter]
  //        attributedTimestampForDate:message.date];
  //    }

  return nil;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout
heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
  /**
   *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource
   * method
   */

  /**
   *  This logic should be consistent with what you return from
   *`attributedTextForCellTopLabelAtIndexPath:`
   *  The other label height delegate methods should follow similarly
   *
   *  Show a timestamp for every 3rd message
   */
  // if (indexPath.item % 3 == 0) {
  //  return kJSQMessagesCollectionViewCellLabelHeightDefault;
  //  }

  // return 0.0f;

  if (self.queryController.count > 0 && indexPath.item == 0) {
    //   JSQMessage *message = self.messages[indexPath.item];
    return kJSQMessagesCollectionViewCellLabelHeightDefault;  //[[JSQMessagesTimestampFormatter
    //sharedFormatter]
    //attributedTimestampForDate:message.date];
  } else if (indexPath.item > 0) {
    // NSDate *firstDate =
    //  NSTimeInterval timeInterval = self.messages[indexPath.item] indexPath.item

    // JSQMessage *firstMessage = [self messageAtIndexPath:indexPath];//
    // self.messages[indexPath.item];
    NSIndexPath *nip =
    [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section];
    // JSQMessage *secondMessage = [self
    // messageAtIndexPath:nip];//self.messages[indexPath.item-1];

    NSDate *firstDate =
    [[self.queryController objectAtIndexPath:indexPath] sentAt];  // firstMessage.date;
    NSDate *secondDate =
    [[self.queryController objectAtIndexPath:nip] sentAt];  // secondMessage.date;

    NSTimeInterval timeInterval = [firstDate timeIntervalSinceDate:secondDate];

    if (timeInterval > QZBMessageTimeInterval) {
      return kJSQMessagesCollectionViewCellLabelHeightDefault;  //[[JSQMessagesTimestampFormatter
      //sharedFormatter]
      //attributedTimestampForDate:firstMessage.date];
    }
  }

  return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
 didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath {
  JSQMessage *m = [self messageAtIndexPath:indexPath];  // self.messages[indexPath.row];
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

- (void)sendMessage:(NSString *)content {
//  LYRMessagePart *messagePart;
  // self.messageImage.image = nil;
  // If no conversations exist, create a new conversation object with a single participant
  if (!self.conversation) {
    [self fetchLayerConversation];
  }

//  messagePart = [LYRMessagePart messagePartWithText:messageText];

  NSString *name = [QZBCurrentUser sharedInstance].user.name;

  // Creates and returns a new message object with the given conversation and array of message
  // parts

  // Create a message with a string of text
  NSString *messageText = [NSString stringWithFormat:@"%@: %@", name, content];
  LYRMessagePart *part = [LYRMessagePart messagePartWithText:messageText];

  // Configure the push notification text to be the same as the message text
  LYRPushNotificationConfiguration *defaultConfiguration = [LYRPushNotificationConfiguration new];
  defaultConfiguration.alert = messageText;
  defaultConfiguration.sound = @"layerbell.caf";

  LYRMessageOptions *messageOptions = [LYRMessageOptions new];
  messageOptions.pushNotificationConfiguration = defaultConfiguration;

  LYRMessage *message = [self.layerClient newMessageWithParts:@[part] options:messageOptions error:nil];

  // Sends the specified message
  NSError *error;
  BOOL success = [self.conversation sendMessage:message error:&error];
  if (success) {
  } else {
    NSLog(@"Message send failed: %@", error);
  }
}

- (void)fetchLayerConversation {
  // Fetches all conversations between the authenticated user and the supplied participant
  // For more information about Querying, check out
  // https://developer.layer.com/docs/integration/ios#querying

  NSString *identifier = [self opponentIdentifier];  // nil;

  LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
  query.predicate = [LYRPredicate predicateWithProperty:@"participants"
                                      predicateOperator:LYRPredicateOperatorIsEqualTo
                                                  value:@[ identifier ]];
  query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO] ];

  NSError *error;
  NSOrderedSet *conversations = [self.layerClient executeQuery:query error:&error];

  if (conversations.count <= 0) {
    NSError *conv_error = nil;
    if (!self.layerClient.authenticatedUser.userID) {
      return;
    }
    self.conversation = [self.layerClient
                         newConversationWithParticipants:
                         [NSSet setWithArray:@[ identifier, self.layerClient.authenticatedUser.userID ]]
                         options:nil
                         error:&conv_error];
    [QZBUserWorker saveUser:self.friend inConversation:self.conversation];
    [QZBUserWorker saveUser:[QZBCurrentUser sharedInstance].user
             inConversation:self.conversation];

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
    NSLog(@"Get last conversation object: %@", self.conversation.identifier);
    //[self.conversation delete:LYRDeletionModeAllParticipants error:nil];

    // setup query controller with messages from last conversation
    if (!self.queryController) {
      [self setupQueryController];
    }
  }
}

- (NSOrderedSet *)conversationsWithFriend {
  NSString *identifier = [self opponentIdentifier];  // nil;

  LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
  query.predicate = [LYRPredicate predicateWithProperty:@"participants"
                                      predicateOperator:LYRPredicateOperatorIsEqualTo
                                                  value:@[ identifier ]];
  query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO] ];

  NSError *error;
  return [self.layerClient executeQuery:query error:&error];
}

- (void)setupQueryController {
  // For more information about the Query Controller, check out
  // https://developer.layer.com/docs/integration/ios#querying

  // Query for all the messages in conversation sorted by position
  LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
  query.predicate = [LYRPredicate predicateWithProperty:@"conversation"
                                      predicateOperator:LYRPredicateOperatorIsEqualTo
                                                  value:self.conversation];
  query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES] ];

  // Set up query controller
  self.queryController = [self.layerClient queryControllerWithQuery:query error:nil];
  self.queryController.delegate = self;

  NSError *error;
  BOOL success = [self.queryController execute:&error];
  if (success) {
    NSLog(@"Query fetched %tu message objects",
          [self.queryController numberOfObjectsInSection:0]);
  } else {
    NSLog(@"Query failed with error: %@", error);
  }
  [self.collectionView reloadData];
  [self.conversation markAllMessagesAsRead:nil];
}

- (JSQMessage *)messageAtIndexPath:(NSIndexPath *)path {
  LYRMessage *message = [self.queryController objectAtIndexPath:path];
  [message markAsRead:nil];
  LYRMessagePart *messagePart = message.parts[0];
  NSString *text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];

  JSQMessage *messageView = [JSQMessage messageWithSenderId:message.sender.userID
                                                displayName:message.sender.userID
                                                       text:text];

  return messageView;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupLayerNotificationObservers {
  // Register for Layer object change notifications
  // For more information about Synchronization, check out
  // https://developer.layer.com/docs/integration/ios#synchronization
  [[NSNotificationCenter defaultCenter]
   addObserver:self
   selector:@selector(didReceiveLayerObjectsDidChangeNotification:)
   name:LYRClientObjectsDidChangeNotification
   object:nil];
}

- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
  // Get nav bar colors from conversation metadata
  //[self setNavbarColorFromConversationMetadata:self.conversation.metadata];
  [self fetchLayerConversation];
}

#pragma mark - Query Controller Delegate Methods

- (void)queryControllerWillChangeContent:(LYRQueryController *)queryController {

}

- (void)queryController:(LYRQueryController *)controller
        didChangeObject:(id)object
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(LYRQueryControllerChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath {
  [self finishReceivingMessage];
}

- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController {
  [self.collectionView reloadData];
}
- (NSString *)opponentIdentifier {
  NSString *identifier = nil;

  if ([self.friend.userID isKindOfClass:[NSString class]]) {
    identifier = (NSString *)self.friend.userID;  // self.friend.userID.stringValue;
  } else {
    identifier = self.friend.userID.stringValue;
  }

  return identifier;
}

@end
