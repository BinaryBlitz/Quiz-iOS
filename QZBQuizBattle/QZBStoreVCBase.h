//
//  QZBStoreVCBase.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 27/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBStoreVCBase : UIViewController

@property (strong, nonatomic, readonly) NSNumberFormatter *priceFormatter;

- (void)restoreTapped:(id)sender;

@end
