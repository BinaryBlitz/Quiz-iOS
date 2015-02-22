//
//  QZBUser.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 13/12/14.
//  Copyright (c) 2014 Andrey Mikhaylov. All rights reserved.
//

#import "QZBUser.h"

@interface QZBUser ()

//@property(assign, nonatomic) NSInteger user_id;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *api_key;
@property (strong, nonatomic) NSNumber *user_id;
@property (strong, nonatomic) UIImage *userPic;

@end

@implementation QZBUser

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.api_key = [dict objectForKey:@"token"];
        self.name = [dict objectForKey:@"name"];
        self.email = [dict objectForKey:@"email"];
        self.user_id = [dict objectForKey:@"id"];
        self.userPic = nil;
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [[QZBUser alloc] init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"userName"];
        self.email = [coder decodeObjectForKey:@"userEmail"];
        self.api_key = [coder decodeObjectForKey:@"userApiKey"];
        self.user_id = [coder decodeObjectForKey:@"user_id"];
        NSString *imagePath = [coder decodeObjectForKey:@"userPic"];
        NSLog(@"path %@", imagePath);
        if (imagePath) {
            self.userPic = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
        }else{
            self.userPic = [UIImage imageNamed:@"achiv"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"userName"];
    [coder encodeObject:self.email forKey:@"userEmail"];
    [coder encodeObject:self.api_key forKey:@"userApiKey"];
    [coder encodeObject:self.user_id forKey:@"user_id"];
    if(self.userPic){
    NSData *imageData = UIImageJPEGRepresentation(self.userPic, 1);
    
    // Get image path in user's folder and store file with name image_CurrentTimestamp.jpg (see documentsPathForFileName below)
    NSString *imagePath = [self documentsPathForFileName:[NSString stringWithFormat:@"userpic_img.jpg"]];
    
    // Write image data to user's folder
    [imageData writeToFile:imagePath atomically:YES];
    
    // Store path in NSUserDefaults
        
    [coder encodeObject:imagePath forKey:@"userPic"];
    }
    
}

- (NSString *)documentsPathForFileName:(NSString *)name {
    NSString  *documentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
   
    
    return [documentsPath stringByAppendingPathComponent:name];
}


-(void)setUserName:(NSString *)userName{
    self.name = userName;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"currentUser"];
    
    NSLog(@"userName %@", self.name);
    
}

-(void)setUserPic:(UIImage *)userPic{
    
    _userPic = userPic;
    NSLog(@"setted %@", [userPic debugDescription]);
    
    NSData *imageData = UIImageJPEGRepresentation(self.userPic, 1);
    
    // Get image path in user's folder and store file with name image_CurrentTimestamp.jpg (see documentsPathForFileName below)
    NSString *imagePath = [self documentsPathForFileName:[NSString stringWithFormat:@"userpic_img.jpg"]];
    
    // Write image data to user's folder
    [imageData writeToFile:imagePath atomically:YES];
    
    
    //todo load to server
}
    


@end
