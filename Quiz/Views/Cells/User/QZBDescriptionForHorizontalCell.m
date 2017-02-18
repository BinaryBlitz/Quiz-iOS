#import "QZBDescriptionForHorizontalCell.h"
#import "UITableViewCell+QZBCellCategory.h"

@implementation QZBDescriptionForHorizontalCell

- (void)awakeFromNib {
  // Initialization code

  self.shadowView = [self addDropShadows];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end
