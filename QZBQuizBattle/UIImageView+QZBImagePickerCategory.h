//
//  UIImageView+QZBImagePickerCategory.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 11/07/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (QZBImagePickerCategory)

-(void)loadNewPic:(UIImage *)image;
-(void)loadDeafaultPicture;

@end
