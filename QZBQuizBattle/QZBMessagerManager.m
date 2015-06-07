//
//  QZBMessagerManager.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 04/06/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBMessagerManager.h"
#import "XMPPFramework.h"
#import "QZBCurrentUser.h"
#import "QZBUser.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import <JSQMessagesViewController/JSQMessages.h>

#import <DDASLLogger.h>

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface QZBMessagerManager()<XMPPStreamDelegate, XMPPRosterDelegate>
@property(strong, nonatomic) XMPPStream *xmppStream;
@property(strong, nonatomic) XMPPReconnect *xmppReconnect;
@property(strong, nonatomic) XMPPRoster *xmppRoster;
@property(strong, nonatomic) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property(strong, nonatomic) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property(strong, nonatomic) XMPPvCardTempModule *xmppvCardTempModule;
@property(strong, nonatomic) XMPPCapabilities *xmppCapabilities;
@property(strong, nonatomic) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
@property(strong, nonatomic) XMPPMessageArchiving *messageArchiving;

@property(assign, nonatomic) BOOL isConnected;

@property(strong, nonatomic) NSString *password;
@property(assign, nonatomic) BOOL isXmppConnected;

@end

@implementation QZBMessagerManager

@synthesize delegate;

+ (instancetype)sharedInstance
{
    static QZBMessagerManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[QZBMessagerManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupStream];
    }
    return self;
}

- (void)dealloc
{
    [self teardownStream];
}
- (void)setupStream
{
    
    NSAssert(self.xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    self.xmppStream = [[XMPPStream alloc] init];
    self.xmppStream.hostName = @"binaryblitz.ru";
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        self.xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    self.xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
    self.xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];
    
    self.xmppRoster.autoFetchRoster = YES;
    self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    self.xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    self.xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.xmppvCardStorage];
    
  //  self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    self.xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    self.xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:self.xmppCapabilitiesStorage];
    
    self.xmppCapabilities.autoFetchHashedCapabilities = YES;
    self.xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Activate xmpp modules
    
    [self.xmppReconnect         activate:self.xmppStream];
    [self.xmppRoster            activate:self.xmppStream];
    [self.xmppvCardTempModule   activate:self.xmppStream];
    //[self.xmppvCardAvatarModule activate:self.xmppStream];
    [self.xmppCapabilities      activate:self.xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self initCoreDataStorage];
    
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    //
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    //	[xmppStream setHostName:@"talk.google.com"];
    //	[xmppStream setHostPort:5222];
    
    
    // You may need to alter these settings depending on the server you're connecting to
   // customCertEvaluation = YES;
}

- (void)teardownStream
{
    [self.xmppStream removeDelegate:self];
    [self.xmppRoster removeDelegate:self];
    
    [self.xmppReconnect         deactivate];
    [self.xmppRoster            deactivate];
    [self.xmppvCardTempModule   deactivate];
    //[self.xmppvCardAvatarModule deactivate];
    [self.xmppCapabilities      deactivate];
    
    [self.xmppStream disconnect];
    
    self.xmppStream = nil;
    self.xmppReconnect = nil;
    self.xmppRoster = nil;
    self.xmppRosterStorage = nil;
    self.xmppvCardStorage = nil;
    self.xmppvCardTempModule = nil;
    //self.xmppvCardAvatarModule = nil;
    self.xmppCapabilities = nil;
    self.xmppCapabilitiesStorage = nil;
}

// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
  //  NSString *domain = [self.xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
//    
//    if([domain isEqualToString:@"gmail.com"]
//       || [domain isEqualToString:@"gtalk.com"]
//       || [domain isEqualToString:@"talk.google.com"])
//    {
//        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
//        [presence addChild:priority];
//    }
    
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
    if (![self.xmppStream isDisconnected]) {
        return YES;
    }
    
    QZBUser *user = [QZBCurrentUser sharedInstance].user;
    //
       // NSString *userJID = [NSString stringWithFormat:@"id%@@localhost", user.userID];
    
    NSString *myJID = [NSString stringWithFormat:@"id%@@localhost", user.userID];
    NSString *myPassword = user.xmppPassword;//[[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
    
    //
    // If you don't want to use the Settings view to set the JID,
    // uncomment the section below to hard code a JID and password.
    //
    // myJID = @"user@gmail.com/xmppframework";
    // myPassword = @"";
    
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    
   
    
    [self.xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    self.xmppStream.hostName = @"binaryblitz.ru";
    self.password = myPassword;
    
    NSError *error = nil;
    if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
//                                                            message:@"See console for error details." 
//                                                           delegate:nil 
//                                                  cancelButtonTitle:@"Ok" 
//                                                  otherButtonTitles:nil];
//        [alertView show];
        
        DDLogError(@"Error connecting: %@", error);
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [self.xmppStream disconnect];
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
}

//- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    
//    NSString *expectedCertName = [self.xmppStream.myJID domain];
////    if (expectedCertName)
////    {
////        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
////    }
//    
////    if (customCertEvaluation)
////    {
////        settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
////    }
//}

//- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
// completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    
//    // The delegate method should likely have code similar to this,
//    // but will presumably perform some extra security code stuff.
//    // For example, allowing a specific self-signed certificate that is known to the app.
//    
//    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(bgQueue, ^{
//        
//        SecTrustResultType result = kSecTrustResultDeny;
//        OSStatus status = SecTrustEvaluate(trust, &result);
//        
//        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
//            completionHandler(YES);
//        }
//        else {
//            completionHandler(NO);
//        }
//    });
//}

//- (void)xmppStreamDidSecure:(XMPPStream *)sender
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    self.isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![[self xmppStream] authenticateWithPassword:self.password error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
    }else{
        
    }
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    
    [self testMessageArchiving];
    
    // A simple example of inbound message handling.
    
    if ([message isChatMessageWithBody])
    {
        XMPPUserCoreDataStorageObject *user = [self.xmppRosterStorage userForJID:[message from]
                                                                 xmppStream:self.xmppStream
                                                       managedObjectContext:[self managedObjectContext_roster]];
        
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [user displayName];
        
        DDLogCVerbose(@"%@ %@", displayName, body);
        
      //  [message from].bare;
        
        //[self.delegate myClassDelegateMethod:self];
        
//        JSQMessage *mess = [JSQMessage messageWithSenderId:[message from].bare
//                                               displayName:user.name
//                                                      text:message.body];

        
        
        [self.delegate didRecieveMessageFrom:[message from].bare text:message.body];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
//                                                                message:body
//                                                               delegate:nil
//                                                      cancelButtonTitle:@"Ok"
//                                                      otherButtonTitles:nil];
//            [alertView show];
        }
        else
        {
//            // We are not active, so use a local notification instead
//            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//            localNotification.alertAction = @"Ok";
//            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
//            
//            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!self.isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [self.xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:self.xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [user displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
//                                                            message:body
//                                                           delegate:nil 
//                                                  cancelButtonTitle:@"Not implemented"
//                                                  otherButtonTitles:nil];
//        [alertView show];
    }
    else 
    {
        // We are not active, so use a local notification instead
//        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//        localNotification.alertAction = @"Not implemented";
//        localNotification.alertBody = body;
//        
//        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
}

#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [self.xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [self.xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

-(void)initCoreDataStorage{
   XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    
    XMPPMessageArchiving *xmppMessageArchivingModule = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:xmppMessageArchivingStorage];
    
    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    
    [xmppMessageArchivingModule activate:self.xmppStream];
    [xmppMessageArchivingModule  addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.messageArchiving = xmppMessageArchivingModule;
}


-(void)testMessageArchiving{
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSError *error;
    NSArray *messages = [moc executeFetchRequest:request error:&error];
    
    [self print:[[NSMutableArray alloc]initWithArray:messages]];
}

-(void)print:(NSMutableArray*)messages{
  //  @autoreleasepool {
        for (XMPPMessageArchiving_Message_CoreDataObject *message in messages) {
            NSLog(@"messageStr param is %@",message.messageStr);
            NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
            NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
            NSLog(@"NSCore object id param is %@",message.objectID);
            NSLog(@"bareJid param is %@",message.bareJid);
            NSLog(@"bareJidStr param is %@",message.bareJidStr);
            NSLog(@"body param is %@",message.body);
            NSLog(@"timestamp param is %@",message.timestamp);
            NSLog(@"outgoing param is %d",[message.outgoing intValue]);
        }
  //  }
}

-(NSArray *)messagesFromUser:(id<QZBUserProtocol>)user{
    
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"bareJidStr == %@",
                              [self jidAsStringFromUser:user]];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
  //  [request setPropertiesToFetch:@[predicate]];
    [request setPredicate:predicate];
    [request setEntity:entityDescription];
    NSError *error;
    return [moc executeFetchRequest:request error:&error];
    
   // return [NSArray array];
}


#pragma mark - messaging

-(void)sendMessage:(NSString *)messageStr toUser:(id<QZBUserProtocol>)user{
    
        //NSString *messageStr = message;
    
        if([messageStr length] > 0) {
    
            NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
            [body setStringValue:messageStr];
    
            NSString *toUser = [self jidAsStringFromUser:user];
    
            NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
            [message addAttributeWithName:@"type" stringValue:@"chat"];
            [message addAttributeWithName:@"to" stringValue:toUser];//REDO
            [message addChild:body];
    
            [self.xmppStream sendElement:message];
        }
}

#pragma mark - delegate



#pragma mark - support methods

-(NSString *)jidAsStringFromUser:(id<QZBUserProtocol>)user{
    
    return [NSString stringWithFormat:@"id%@@localhost", user.userID];
}


-(NSMutableArray *)generateJSQMessagesForUser:(id<QZBUserProtocol>)user{
    NSArray *messages = [self messagesFromUser:user];
    
    NSMutableArray *res = [NSMutableArray array];
    
    NSString *currentUserIdentificator = [self jidAsStringFromUser:[QZBCurrentUser sharedInstance].user]; //[[QZBCurrentUser sharedInstance].user.userID stringValue];
    
    NSString *friendIdentificator = [self jidAsStringFromUser:user];
    
    for (XMPPMessageArchiving_Message_CoreDataObject *message in messages){
        
//        NSLog(@"messageStr param is %@",message.messageStr);
//        NSXMLElement *element = [[NSXMLElement alloc] initWithXMLString:message.messageStr error:nil];
//        NSLog(@"to param is %@",[element attributeStringValueForName:@"to"]);
//        NSLog(@"NSCore object id param is %@",message.objectID);
//        NSLog(@"bareJid param is %@",message.bareJid);
//        NSLog(@"bareJidStr param is %@",message.bareJidStr);
//        NSLog(@"body param is %@",message.body);
//        NSLog(@"timestamp param is %@",message.timestamp);
//        NSLog(@"outgoing param is %d \n\n\n",[message.outgoing intValue]);
        
        
        NSString *identificator = nil;
        
        if(message.isOutgoing){
            identificator = currentUserIdentificator; //[currentUserIdentificator copy];
        }else{
            identificator = friendIdentificator; //[user.userID stringValue];
        }
            JSQMessage *mess = [JSQMessage messageWithSenderId:identificator
                                                   displayName:user.name
                                                          text:message.body];
    
        [res addObject:mess];
        
//            JSQMessage *mess = [JSQMessage messageWithSenderId:[self.friend.userID stringValue]
//                                                                          displayName:self.friend.name
//                                                                                 text:msg];
    }
    
    return res;
    
}

#pragma mar - reloading

-(BOOL)isConnected{
    return self.xmppStream.isConnected;
}


@end
