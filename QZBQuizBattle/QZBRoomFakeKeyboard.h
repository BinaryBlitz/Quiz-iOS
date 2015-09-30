//
//  QZBRoomFakeKeyboard.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 29/09/15.
//  Copyright © 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBRoomFakeKeyboard : UIView
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *phrasesButtons;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end
