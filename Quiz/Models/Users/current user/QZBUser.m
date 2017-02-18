#import "QZBUser.h"
#import "QZBServerManager.h"
#import "QZBAnotherUser.h"

@interface QZBUser ()

//@property(assign, nonatomic) NSInteger user_id;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *api_key;
@property (strong, nonatomic) NSNumber *userID;
//@property (strong, nonatomic) UIImage *userPic;
@property(assign, nonatomic) BOOL isFriend;
@property(strong, nonatomic) NSURL *imageURL;
@property(strong, nonatomic) NSURL *imageURLBig;
@property(strong, nonatomic) NSString *xmppPassword;

@property(assign, nonatomic) BOOL isRegistred;

@property(assign, nonatomic) BOOL isOnline;

//@property(strong, nonatomic) NSString *pushToken;

@end

@implementation QZBUser

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.api_key = [dict objectForKey:@"token"];
       // self.name = [dict objectForKey:@"username"];//??
        if(![dict[@"username"] isEqual:[NSNull null]] && dict[@"username"]){
            self.name = [dict objectForKey:@"username"];
            self.isRegistred = YES;
        }else{
            self.name = nil;
            self.isRegistred = NO;
        }
        
        if([dict objectForKey:@"email"]){
            self.email = [dict objectForKey:@"email"];
        }else{
            self.email = nil;
        }
        self.userID = @([[dict objectForKey:@"id"] integerValue]);
        
        self.xmppPassword = dict[@"xmpp_password"];
       // self.userPic = nil;
        
        self.isFriend = NO;
        
        NSString *urlAppend = dict[@"avatar_thumb_url"];
        if(![urlAppend isEqual:[NSNull null]]){
            NSString *urlString = [QZBServerBaseUrl stringByAppendingString:urlAppend];
            self.imageURL = [NSURL URLWithString:urlString];
        }else{
            self.imageURL = nil;
        }
        
        NSString *urlAppendBig = dict[@"avatar_url"];
        if(![urlAppendBig isEqual:[NSNull null]]){
            NSString *urlString = [QZBServerBaseUrl stringByAppendingString:urlAppendBig];
            self.imageURLBig = [NSURL URLWithString:urlString];
        }else{
            self.imageURLBig = nil;
        }
        
        
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [[QZBUser alloc] init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"userName"];
        self.email = [coder decodeObjectForKey:@"userEmail"];
        self.api_key = [coder decodeObjectForKey:@"userApiKey"];
        self.userID = [coder decodeObjectForKey:@"user_id"];
        self.isFriend = NO;
        self.xmppPassword = [coder decodeObjectForKey:@"xmpp_password"];
        
        self.imageURL = [coder decodeObjectForKey:@"user_image_url"];
        self.imageURLBig = [coder decodeObjectForKey:@"user_image_url_big"];
        
        
 
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"userName"];
    [coder encodeObject:self.email forKey:@"userEmail"];
    [coder encodeObject:self.api_key forKey:@"userApiKey"];
    [coder encodeObject:self.userID forKey:@"user_id"];
    [coder encodeObject:self.xmppPassword forKey:@"xmpp_password"];
    
    if(self.imageURL){
    
        [coder encodeObject:self.imageURL forKey:@"user_image_url"];
    }
    if(self.imageURLBig) {
        [coder encodeObject:self.imageURLBig forKey:@"user_image_url_big"];
    }
    
    
//    if(self.pushToken){
//        [coder encodeObject:self.pushToken forKey:@"pushToken"];
//    }
    
//    if(self.userPic){
//    NSData *imageData = UIImageJPEGRepresentation(self.userPic, 1);
//    
//    // Get image path in user's folder and store file with name image_CurrentTimestamp.jpg (see documentsPathForFileName below)
//    NSString *imagePath = [self documentsPathForFileName:[NSString stringWithFormat:@"userpic_img.jpg"]];
//    
//    // Write image data to user's folder
//    [imageData writeToFile:imagePath atomically:YES];
//    
//    // Store path in NSUserDefaults
//        
//    [coder encodeObject:imagePath forKey:@"userPic"];
//    }
    
}

- (NSString *)documentsPathForFileName:(NSString *)name {
    NSString  *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
   
    
    return [documentsPath stringByAppendingPathComponent:name];
}



//TODO ?
-(void)setUserName:(NSString *)userName{
    self.name = userName;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"currentUser"];
    
}


-(void)makeUserRegisterWithUserName:(NSString *)username{

    self.isRegistred = YES;
    [self setUserName:username];
}



-(void)updateUserFromServer{
    if(self.userID){
    [[QZBServerManager sharedManager] GETPlayerWithID:self.userID onSuccess:^(QZBAnotherUser *anotherUser) {
        
        BOOL changed = NO;
        if(![self.imageURL isEqual: anotherUser.imageURL]){
            self.imageURL = anotherUser.imageURL;
            
            changed = YES;
            
        }
        
        if(![self.imageURLBig isEqual: anotherUser.imageURLBig]){
            self.imageURLBig = anotherUser.imageURLBig;
            
            changed = YES;
            
        }
        
        if(![self.name isEqual:anotherUser.name]){
            self.name = anotherUser.name;
            changed = YES;
        }
        
        if(changed){
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
            
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"currentUser"];
        }
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
    }];
    }
    
    
}

-(void)deleteImage {
    self.imageURL = nil;
}
    
-(BOOL)isOnline {
    return YES;
}

@end
