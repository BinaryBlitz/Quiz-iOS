//
//  QZBCameraVC.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 14/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBCameraVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *cameraImageView;


@end
