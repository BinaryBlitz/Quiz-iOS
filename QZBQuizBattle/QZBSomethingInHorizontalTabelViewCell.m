//
//  QZBFriendInHorizontalTabelViewCell.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 22/01/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBSomethingInHorizontalTabelViewCell.h"
#import "UIImageView+AFNetworking.h"

@implementation QZBSomethingInHorizontalTabelViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    self.name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    self.name.textAlignment = NSTextAlignmentCenter;
    self.name.transform = CGAffineTransformMakeRotation(1.5707963);
    self.name.frame = CGRectMake(10, 0, 20, 100);

    self.picture = [[UIImageView alloc] initWithFrame:CGRectMake(40, 10, 80, 80)];
    self.picture.layer.cornerRadius = self.picture.bounds.size.height / 2;
    self.picture.clipsToBounds = YES;
    self.picture.transform = CGAffineTransformMakeRotation(1.5707963);

    [self addSubview:self.name];
    [self addSubview:self.picture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString *)name picURLAsString:(NSString *)URLString {
    self.name.text = name;

    NSURL *url = [NSURL URLWithString:URLString];

    [self.picture setImageWithURL:url];
}

- (void)setName:(NSString *)name picture:(UIImage *)image{
    self.name.text = name;
    self.picture.image = image;
    
}

-(NSString *)reuseIdentifier{
    return @"somethingInHorizontalCell";
}


@end
