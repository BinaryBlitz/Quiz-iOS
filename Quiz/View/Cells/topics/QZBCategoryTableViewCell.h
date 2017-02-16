//
//  QZBCategoryTableViewCell.h
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 15/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFImageManager/DFImageView.h>

@interface QZBCategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
//@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet DFImageView *categoryImageView;

@end