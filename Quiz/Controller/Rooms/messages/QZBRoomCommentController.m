#import "QZBRoomCommentController.h"
#import "QZBCommentRoomCell.h"
#import "QZBComment.h"
#import "QZBCommentTextView.h"
#import "QZBCurrentUser.h"

#import "QZBServerManager.h"

#import <NSDate+DateTools.h>

#import <DFImageManager/DFImageManager.h>
#import <DFImageManager/DFImageRequestOptions.h>
#import <DFImageManager/DFURLImageFetcher.h>
#import <DFImageManager/DFImageRequest.h>
#import <DFImageManager/DFImageView.h>

#import <TSMessage.h>

#define DEBUG_CUSTOM_TYPING_INDICATOR 0

static NSString *MessengerCellIdentifier = @"MessengerCell";
static NSString *AutoCompletionCellIdentifier = @"AutoCompletionCell";

@interface QZBRoomCommentController ()

@property (nonatomic, strong) NSMutableArray *messages;

@property (nonatomic, strong) QZBUser *user;
@property (strong, nonatomic) NSNumber *roomID;
@end

@implementation QZBRoomCommentController

- (id)init {
  self = [super initWithTableViewStyle:UITableViewStylePlain];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder {
  return UITableViewStylePlain;
}

- (void)commonInit {
  [[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                           selector:@selector(reloadData)
                                               name:UIContentSizeCategoryDidChangeNotification
                                             object:nil];

  // Register a SLKTextView subclass, if you need any special appearance and/or behavior customisation
  [self registerClassForTextView:[QZBCommentTextView class]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Чат";

  self.bounces = YES;
  self.shakeToClearEnabled = YES;
  self.keyboardPanningEnabled = YES;
  self.shouldScrollToBottomAfterKeyboardShows = NO;
  self.inverted = YES;

  //    [self.leftButton setImage:[UIImage imageNamed:@"icn_upload"]
  //    forState:UIControlStateNormal];
  //    [self.leftButton setTintColor:[UIColor grayColor]];

  [self.rightButton setTitle:@"Отпр" forState:UIControlStateNormal];

  self.textInputbar.autoHideRightButton = YES;
  self.textInputbar.maxCharCount = 256;
  self.textInputbar.counterStyle = SLKCounterStyleSplit;
  self.textInputbar.counterPosition = SLKCounterPositionTop;

  [self.textInputbar.editorTitle setTextColor:[UIColor darkGrayColor]];
  // [self.textInputbar.editortLeftButton setTintColor:[UIColor colorWithRed:0.0/255.0
  // green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
  [self.textInputbar.editorRightButton setTintColor:[UIColor colorWithRed:0.0 / 255.0 green:122.0 / 255.0 blue:255.0 / 255.0 alpha:1.0]];

#if !DEBUG_CUSTOM_TYPING_INDICATOR
  self.typingIndicatorView.canResignByTouch = YES;
#endif

  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self.tableView registerClass:[QZBCommentRoomCell class]
         forCellReuseIdentifier:MessengerCellIdentifier];

  [self.autoCompletionView registerClass:[QZBCommentRoomCell class]
                  forCellReuseIdentifier:AutoCompletionCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)configureWithRoomID:(NSNumber *)roomID {
  self.roomID = roomID;

  [self reloadMessages];
}

#pragma mark - Action Methods

- (void)editCellMessage:(UIGestureRecognizer *)gesture {
  QZBCommentRoomCell *cell = (QZBCommentRoomCell *) gesture.view;
  QZBComment *message = self.messages[cell.indexPath.row];

  [self editText:message.text];

  [self.tableView scrollToRowAtIndexPath:cell.indexPath
                        atScrollPosition:UITableViewScrollPositionBottom
                                animated:YES];
}

- (void)editRandomMessage:(id)sender {
  int sentences = (arc4random() % 10);
  if (sentences <= 1)
    sentences = 1;

  [self editText:@"edit text"];
}

- (void)editLastMessage:(id)sender {
  if (self.textView.text.length > 0) {
    return;
  }

  NSInteger lastSectionIndex = [self.tableView numberOfSections] - 1;
  NSInteger lastRowIndex = [self.tableView numberOfRowsInSection:lastSectionIndex] - 1;

  QZBComment *lastMessage = [self.messages objectAtIndex:lastRowIndex];

  [self editText:lastMessage.text];

  [self.tableView
      scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex]
            atScrollPosition:UITableViewScrollPositionBottom
                    animated:YES];
}

#pragma mark - Overriden Methods

- (BOOL)ignoreTextInputbarAdjustment {
  return [super ignoreTextInputbarAdjustment];
}

- (BOOL)forceTextInputbarAdjustmentForResponder:(UIResponder *)responder {
  // On iOS 9, returning YES helps keeping the input view visible when the keyboard if presented
  // from another app when using multi-tasking on iPad.
  return SLK_IS_IPAD;
}

- (void)didChangeKeyboardStatus:(SLKKeyboardStatus)status {
  // Notifies the view controller that the keyboard changed status.
}

- (void)textWillUpdate {
  // Notifies the view controller that the text will update.

  [super textWillUpdate];
}

- (void)textDidUpdate:(BOOL)animated {
  // Notifies the view controller that the text did update.

  [super textDidUpdate:animated];
}

- (void)didPressLeftButton:(id)sender {
  // Notifies the view controller when the left button's action has been triggered, manually.

  [super didPressLeftButton:sender];
}

- (void)didPressRightButton:(id)sender {
  // Notifies the view controller when the right button's action has been triggered, manually or
  // by using the keyboard return key.

  // This little trick validates any pending auto-correction or auto-spelling just after hitting
  // the 'Send' button
  [self.textView refreshFirstResponder];

  [self.textView refreshFirstResponder];

  QZBComment *message = [QZBComment new];
  message.username = self.user.name;
  message.text = [self.textView.text copy];
  message.timestamp = [NSDate date];
  message.isSended = NO;

  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  UITableViewRowAnimation rowAnimation =
      self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
  UITableViewScrollPosition scrollPosition =
      self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;

  [self.tableView beginUpdates];
  [self.messages insertObject:message atIndex:0];
  [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
  [self.tableView endUpdates];

  [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];

  // Fixes the cell from blinking (because of the transform, when using translucent cells)
  // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
  [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
  [super didPressRightButton:sender];

  [self sendMessage:message];
}

- (void)sendMessage:(QZBComment *)comment {
  [[QZBServerManager sharedManager] POSTSendMessage:comment.text inRoomWithID:self.roomID
                                          onSuccess:^{
                                            comment.isSended = YES;
                                          } onFailure:^(NSError *error, NSInteger statusCode) {//REDO TEST (may not crash)
        if (![self.messages containsObject:comment]) {
          return;
        }

        NSInteger row = [self.messages indexOfObject:comment];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView beginUpdates];
        [self.messages removeObject:comment];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];

        [self.tableView endUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [TSMessage showNotificationWithTitle:@"Не удалось отправить сообщение" type:TSMessageNotificationTypeError];
      }];
}

- (void)didPressArrowKey:(id)sender {
  [super didPressArrowKey:sender];

  UIKeyCommand *keyCommand = (UIKeyCommand *) sender;

  if ([keyCommand.input isEqualToString:UIKeyInputUpArrow]) {
    [self editLastMessage:nil];
  }
}

- (NSString *)keyForTextCaching {
  return [[NSBundle mainBundle] bundleIdentifier];
}

- (void)willRequestUndo {
  // Notifies the view controller when a user did shake the device to undo the typed text

  [super willRequestUndo];
}

- (void)didCommitTextEditing:(id)sender {
  // Notifies the view controller when tapped on the right "Accept" button for commiting the
  // edited text

  QZBComment *message = [QZBComment new];
  message.username = @"Commit name";
  message.text = [self.textView.text copy];
  // message.timestamp = [NSDate date];

  [self.messages removeObjectAtIndex:0];
  [self.messages insertObject:message atIndex:0];
  [self.tableView reloadData];

  [super didCommitTextEditing:sender];
}

- (void)didCancelTextEditing:(id)sender {
  // Notifies the view controller when tapped on the left "Cancel" button

  [super didCancelTextEditing:sender];
}

- (BOOL)canPressRightButton {
  return [super canPressRightButton];
}

- (BOOL)canShowTypingIndicator {
  return NO;
#if DEBUG_CUSTOM_TYPING_INDICATOR
  return YES;
#else
  return [super canShowTypingIndicator];
#endif
}

- (BOOL)canShowAutoCompletion {
  return NO;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if ([tableView isEqual:self.tableView]) {
    return self.messages.count;
  } else {
    return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self messageCellForRowAtIndexPath:indexPath];
}

- (QZBCommentRoomCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath {
  QZBCommentRoomCell *cell = (QZBCommentRoomCell *)
      [self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];

  QZBComment *message = self.messages[indexPath.row];

  cell.titleLabel.text = message.username;
  cell.bodyLabel.text = message.text;
  NSString *minutes = [message.timestamp minute] < 10
      ? [NSString stringWithFormat:@"0%ld", [message.timestamp minute]]
      : [NSString stringWithFormat:@"%ld", [message.timestamp minute]];
  cell.timeAgoLabel.text =
      [NSString stringWithFormat:@"%ld:%@", [message.timestamp hour], minutes];

  cell.indexPath = indexPath;
  cell.usedForMessage = YES;

  if (cell.needsPlaceholder) {
    if (message.owner.imageURL) {
      DFMutableImageRequestOptions *options = [DFMutableImageRequestOptions new];

      options.allowsClipping = YES;
      options.userInfo = @{DFURLRequestCachePolicyKey: @(NSURLRequestReturnCacheDataElseLoad)};

      DFImageRequest *request =
          [DFImageRequest requestWithResource:message.owner.imageURL
                                   targetSize:CGSizeZero
                                  contentMode:DFImageContentModeAspectFill
                                      options:options];

      cell.thumbnailView.allowsAnimations = YES;

      [cell.thumbnailView prepareForReuse];

      [cell.thumbnailView setImageWithRequest:request];
    } else {
      cell.thumbnailView.image = [UIImage imageNamed:@"userpicStandart"];
    }
  }

  // Cells must inherit the table view's transform
  // This is very important, since the main table view may be inverted
  cell.transform = self.tableView.transform;

  return cell;
}

//- (QZBCommentRoomCell *)autoCompletionCellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    QZBCommentRoomCell *cell = (QZBCommentRoomCell *)[self.autoCompletionView
//    dequeueReusableCellWithIdentifier:AutoCompletionCellIdentifier];
//    cell.indexPath = indexPath;
//
//    NSString *item = self.searchResult[indexPath.row];
//
//    if ([self.foundPrefix isEqualToString:@"#"]) {
//        item = [NSString stringWithFormat:@"# %@", item];
//    }
//    else if (([self.foundPrefix isEqualToString:@":"] || [self.foundPrefix
//    isEqualToString:@"+:"])) {
//        item = [NSString stringWithFormat:@":%@:", item];
//    }
//
//    cell.titleLabel.text = item;
//    cell.titleLabel.font = [UIFont systemFontOfSize:14.0];
//    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
//
//    return cell;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([tableView isEqual:self.tableView]) {
    QZBComment *message = self.messages[indexPath.row];

    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;

    CGFloat pointSize = [QZBCommentRoomCell defaultFontSize];

    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:pointSize],
        NSParagraphStyleAttributeName: paragraphStyle
    };

    CGFloat width = CGRectGetWidth(tableView.frame) - kMessageTableViewCellAvatarHeight;
    width -= 25.0;

    CGRect titleBounds =
        [message.username boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attributes
                                       context:NULL];
    CGRect bodyBounds = [message.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:NULL];

    if (message.text.length == 0) {
      return 0.0;
    }

    CGFloat height = CGRectGetHeight(titleBounds);
    height += CGRectGetHeight(bodyBounds);
    height += 40.0;

    if (height < kMessageTableViewCellMinimumHeight) {
      height = kMessageTableViewCellMinimumHeight;
    }

    return height;
  } else {
    return kMessageTableViewCellMinimumHeight;
  }
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // Since SLKTextViewController uses UIScrollViewDelegate to update a few things, it is important
  // that if you ovveride this method, to call super.
  [super scrollViewDidScroll:scrollView];
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)       textView:(SLKTextView *)textView
shouldChangeTextInRange:(NSRange)range
        replacementText:(NSString *)text {
  return [super textView:textView shouldChangeTextInRange:range replacementText:text];
}

#pragma mark - Lifeterm

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - reload

- (void)addBarButtonRight {
  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                    target:self
                                                    action:@selector(reloadMessages)];
}

- (void)addSpinnerRight {
  UIActivityIndicatorView *actInd = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
  [actInd startAnimating];

  //    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  //    button.frame = CGRectMake(0,0,20, 20);
  //    [button addTarget:self action:@selector(showChat) forControlEvents:UIControlEventTouchUpInside];

  //    NSString *requestTitle = @"Чат";
  //
  //    [button setTitle:requestTitle forState:UIControlStateNormal];
  // button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;

  self.navigationItem.rightBarButtonItem =
      [[UIBarButtonItem alloc] initWithCustomView:actInd];
}

- (void)reloadMessages {
  [self addSpinnerRight];

  [[QZBServerManager sharedManager] GETChatForRoomWithID:self.roomID
                                               onSuccess:^(NSArray *messages) {
                                                 NSArray *reversed = [[messages reverseObjectEnumerator] allObjects];

                                                 self.messages = [[NSMutableArray alloc] initWithArray:reversed];
                                                 [self.tableView reloadData];
                                                 [self addBarButtonRight];
                                               }
                                               onFailure:^(NSError *error, NSInteger statusCode) {
                                                 [self addBarButtonRight];
                                                 [TSMessage showNotificationWithTitle:QZBNoInternetConnectionMessage
                                                                                 type:TSMessageNotificationTypeError];
                                               }];
}

#pragma mark - recieve message

- (void)didRecieveMessage:(QZBComment *)message {
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
  UITableViewRowAnimation rowAnimation =
      self.inverted ? UITableViewRowAnimationBottom : UITableViewRowAnimationTop;
  UITableViewScrollPosition scrollPosition =
      self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;

  [self.tableView beginUpdates];
  [self.messages insertObject:message atIndex:0];
  [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
  [self.tableView endUpdates];

  [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];

  // Fixes the cell from blinking (because of the transform, when using translucent cells)
  // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
  [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                        withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end
