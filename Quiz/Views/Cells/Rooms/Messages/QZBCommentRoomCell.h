#import <UIKit/UIKit.h>

static CGFloat kMessageTableViewCellMinimumHeight = 50.0;
static CGFloat kMessageTableViewCellAvatarHeight = 30.0;

@class DFImageView;
@interface QZBCommentRoomCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *timeAgoLabel;
@property (nonatomic, strong) DFImageView *thumbnailView;
@property (nonatomic, strong) UIImageView *attachmentView;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, readonly) BOOL needsPlaceholder;
@property (nonatomic) BOOL usedForMessage;

+ (CGFloat)defaultFontSize;

@end
