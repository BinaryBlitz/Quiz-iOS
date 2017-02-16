//
//  QZBStoreBoosterCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 25/02/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QZBStoreBoosterCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *IAPName;

@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UILabel *allTopicPurchaseDescriptionLabel;

@end