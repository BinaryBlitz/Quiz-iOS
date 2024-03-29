#import "QZBCommentRoomCell.h"

#import <DFImageManager/DFImageView.h>

@implementation QZBCommentRoomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];

    [self configureSubviews];
  }
  return self;
}

- (void)configureSubviews {
  [self.contentView addSubview:self.thumbnailView];
  [self.contentView addSubview:self.titleLabel];
  [self.contentView addSubview:self.bodyLabel];
  [self.contentView addSubview:self.attachmentView];
  [self.contentView addSubview:self.timeAgoLabel];

  NSDictionary *views = @{@"thumbnailView": self.thumbnailView,
      @"titleLabel": self.titleLabel,
      @"bodyLabel": self.bodyLabel,
      @"attachmentView": self.attachmentView,
      @"timeAgoLabel": self.timeAgoLabel
  };

  NSDictionary *metrics = @{@"tumbSize": @(kMessageTableViewCellAvatarHeight),
      @"padding": @15,
      @"right": @10,
      @"left": @5,
      @"attchSize": @80,
  };
  [self.contentView addConstraints:
      [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[titleLabel(>=0)]-[timeAgoLabel(attchSize)]-right-|"
                                              options:0 metrics:metrics views:views]];
  [self.contentView addConstraints:
      [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[bodyLabel(>=0)]-right-|"
                                              options:0 metrics:metrics views:views]];
  [self.contentView addConstraints:
      [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[thumbnailView(tumbSize)]-right-[attachmentView]-right-|"
                                              options:0 metrics:metrics views:views]];

  [self.contentView addConstraints:
      [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-right-[thumbnailView(tumbSize)]-(>=0)-|"
                                              options:0 metrics:metrics views:views]];
  [self.contentView addConstraints:
      [NSLayoutConstraint
          constraintsWithVisualFormat:@"V:|-right-[titleLabel]-left-[bodyLabel(>=0)]-left-[attachmentView(>=0,<=attchSize)]-right-|"
                              options:0 metrics:metrics views:views]];

  [self.contentView addConstraints:
      [NSLayoutConstraint
          constraintsWithVisualFormat:@"V:|-right-[timeAgoLabel]-left-[bodyLabel(>=0)]-left-[attachmentView(>=0,<=attchSize)]-right-|"
                              options:0 metrics:metrics views:views]];
}

- (void)prepareForReuse {
  [super prepareForReuse];

  self.selectionStyle = UITableViewCellSelectionStyleNone;

  CGFloat pointSize = [QZBCommentRoomCell defaultFontSize];

  self.titleLabel.font = [UIFont boldSystemFontOfSize:pointSize];
  self.bodyLabel.font = [UIFont systemFontOfSize:pointSize];
  self.attachmentView.image = nil;
}

#pragma mark - Getters

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [UILabel new];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.userInteractionEnabled = NO;
    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = [UIColor grayColor];
    _titleLabel.font = [UIFont boldSystemFontOfSize:[QZBCommentRoomCell defaultFontSize]];
  }
  return _titleLabel;
}

- (UILabel *)bodyLabel {
  if (!_bodyLabel) {
    _bodyLabel = [UILabel new];
    _bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _bodyLabel.backgroundColor = [UIColor clearColor];
    _bodyLabel.userInteractionEnabled = NO;
    _bodyLabel.numberOfLines = 0;
    _bodyLabel.textColor = [UIColor darkGrayColor];
    _bodyLabel.font = [UIFont systemFontOfSize:[QZBCommentRoomCell defaultFontSize]];
  }
  return _bodyLabel;
}

- (UIImageView *)thumbnailView {
  if (!_thumbnailView) {
    _thumbnailView = [DFImageView new];
    _thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
    _thumbnailView.userInteractionEnabled = NO;
    _thumbnailView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];

    _thumbnailView.layer.cornerRadius = kMessageTableViewCellAvatarHeight / 2.0;
    _thumbnailView.layer.masksToBounds = YES;
  }
  return _thumbnailView;
}

- (UIImageView *)attachmentView {
  if (!_attachmentView) {
    _attachmentView = [UIImageView new];
    _attachmentView.translatesAutoresizingMaskIntoConstraints = NO;
    _attachmentView.userInteractionEnabled = NO;
    _attachmentView.backgroundColor = [UIColor clearColor];
    _attachmentView.contentMode = UIViewContentModeCenter;

    _attachmentView.layer.cornerRadius = kMessageTableViewCellAvatarHeight / 4.0;
    _attachmentView.layer.masksToBounds = YES;
  }
  return _attachmentView;
}

- (UILabel *)timeAgoLabel {
  if (!_timeAgoLabel) {
    _timeAgoLabel = [UILabel new];
    _timeAgoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _timeAgoLabel.backgroundColor = [UIColor clearColor];
    _timeAgoLabel.userInteractionEnabled = NO;
    _timeAgoLabel.numberOfLines = 1;
    _timeAgoLabel.textAlignment = NSTextAlignmentRight;
    _timeAgoLabel.textColor = [UIColor colorWithWhite:128.0 / 255.0 alpha:1.0];
    _timeAgoLabel.font = [UIFont systemFontOfSize:[QZBCommentRoomCell defaultFontSize]];
    _timeAgoLabel.text = @"10:10";
  }

  return _timeAgoLabel;
}

- (BOOL)needsPlaceholder {
  return self.thumbnailView.image ? NO : YES;
}

+ (CGFloat)defaultFontSize {
  CGFloat pointSize = 16.0;

  return pointSize;
}

@end
