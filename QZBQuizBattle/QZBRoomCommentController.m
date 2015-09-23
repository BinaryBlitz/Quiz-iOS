//
//  QZBRoomCommentController.m
//  QZBQuizBattle
//
//  Created by Andrey Mikhaylov on 07/09/15.
//  Copyright (c) 2015 Andrey Mikhaylov. All rights reserved.
//

#import "QZBRoomCommentController.h"
#import "QZBCommentRoomCell.h"
#import "QZBComment.h"
#import "QZBCommentTextView.h"
#import "QZBCurrentUser.h"
#import "QZBUser.h"

#import "QZBServerManager.h"

#import <LoremIpsum/LoremIpsum.h>
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

//@property (nonatomic, strong) NSArray *users;
//@property (nonatomic, strong) NSArray *channels;
//@property (nonatomic, strong) NSArray *emojis;
//
//@property (nonatomic, strong) NSArray *searchResult;

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

    // Register a SLKTextView subclass, if you need any special appearance and/or behavior
    // customisation.
    [self registerClassForTextView:[QZBCommentTextView class]];

    //#if DEBUG_CUSTOM_TYPING_INDICATOR
    //    // Register a UIView subclass, conforming to SLKTypingIndicatorProtocol, to use a custom
    //    typing indicator view.
    //    [self registerClassForTypingIndicatorView:[TypingIndicatorView class]];
    //#endif
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Чат";

    //    NSMutableArray *array = [[NSMutableArray alloc] init];
    //
    //    for (int i = 0; i < 100; i++) {
    //        NSInteger words = (arc4random() % 40)+1;
    //
    //        QZBComment *message = [QZBComment new];
    //        message.username = [LoremIpsum name];
    //        message.text = [LoremIpsum wordsWithNumber:words];
    //        message.timestamp = [LoremIpsum date];
    //        [array addObject:message];
    //    }

    //    NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
    //
    //    self.messages = [[NSMutableArray alloc] initWithArray:reversed];

    self.user = [QZBCurrentUser sharedInstance].user;

    //    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithImage:[UIImage
    //    imageNamed:@"icn_editing"]
    //                                                                 style:UIBarButtonItemStylePlain
    //                                                                target:self
    //                                                                action:@selector(editRandomMessage:)];
    //
    //    UIBarButtonItem *typeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage
    //    imageNamed:@"icn_typing"]
    //                                                                 style:UIBarButtonItemStylePlain
    //                                                                target:self
    //                                                                action:@selector(simulateUserTyping:)];
    //
    //    UIBarButtonItem *appendItem = [[UIBarButtonItem alloc] initWithImage:[UIImage
    //    imageNamed:@"icn_append"]
    //                                                                   style:UIBarButtonItemStylePlain
    //                                                                  target:self
    //                                                                  action:@selector(fillWithText:)];

    //  self.navigationItem.rightBarButtonItems = @[editItem, appendItem, typeItem];

    //    self.users = @[@"Allen", @"Anna", @"Alicia", @"Arnold", @"Armando", @"Antonio", @"Brad",
    //    @"Catalaya", @"Christoph", @"Emerson", @"Eric", @"Everyone", @"Steve"];
    //    self.channels = @[@"General", @"Random", @"iOS", @"Bugs", @"Sports", @"Android", @"UI",
    //    @"SSB"];
    //    self.emojis = @[@"m", @"man", @"machine", @"block-a", @"block-b", @"bowtie", @"boar",
    //    @"boat", @"book", @"bookmark", @"neckbeard", @"metal", @"fu", @"feelsgood"];

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
    [self.textInputbar.editortRightButton
        setTintColor:
            [UIColor colorWithRed:0.0 / 255.0 green:122.0 / 255.0 blue:255.0 / 255.0 alpha:1.0]];

#if !DEBUG_CUSTOM_TYPING_INDICATOR
    self.typingIndicatorView.canResignByTouch = YES;
#endif

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[QZBCommentRoomCell class]
           forCellReuseIdentifier:MessengerCellIdentifier];

    [self.autoCompletionView registerClass:[QZBCommentRoomCell class]
                    forCellReuseIdentifier:AutoCompletionCellIdentifier];
    // [self registerPrefixesForAutoCompletion:@[@"@", @"#", @":", @"+:"]];
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

//    [[QZBServerManager sharedManager] GETChatForRoomWithID:roomID
//        onSuccess:^(NSArray *messages) {
//            NSArray *reversed = [[messages reverseObjectEnumerator] allObjects];
//
//            self.messages = [[NSMutableArray alloc] initWithArray:reversed];
//            [self.tableView reloadData];
//        }
//        onFailure:^(NSError *error, NSInteger statusCode) {
//            [TSMessage showNotificationWithTitle:QZBNoInternetConnectionMessage
//                                            type:TSMessageNotificationTypeError];
//        }];
}

#pragma mark - Action Methods

//- (void)fillWithText:(id)sender
//{
//    if (self.textView.text.length == 0)
//    {
//        int sentences = (arc4random() % 4);
//        if (sentences <= 1) sentences = 1;
//        self.textView.text = @"Текст";//[LoremIpsum sentencesWithNumber:sentences];
//    }
//    else {
//        [self.textView slk_insertTextAtCaretRange:@"some text"];
//    }
//}

//- (void)simulateUserTyping:(id)sender
//{
//    if ([self canShowTypingIndicator]) {
//
//#if DEBUG_CUSTOM_TYPING_INDICATOR
//        __block TypingIndicatorView *view = (TypingIndicatorView *)self.typingIndicatorProxyView;
//
//        CGFloat scale = [UIScreen mainScreen].scale;
//        CGSize imgSize = CGSizeMake(kTypingIndicatorViewAvatarHeight*scale,
//        kTypingIndicatorViewAvatarHeight*scale);
//
//        // This will cause the typing indicator to show after a delay ¯\_(ツ)_/¯
//        [LoremIpsum asyncPlaceholderImageWithSize:imgSize
//                                       completion:^(UIImage *image) {
//                                           UIImage *thumbnail = [UIImage
//                                           imageWithCGImage:image.CGImage scale:scale
//                                           orientation:UIImageOrientationUp];
//                                           [view presentIndicatorWithName:[LoremIpsum name]
//                                           image:thumbnail];
//                                       }];
//#else
//        [self.typingIndicatorView insertUsername:@"Name"];
//#endif
//    }
//}

- (void)editCellMessage:(UIGestureRecognizer *)gesture {
    QZBCommentRoomCell *cell = (QZBCommentRoomCell *)gesture.view;
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

    [self editText:@"edit text"];  //[LoremIpsum sentencesWithNumber:sentences]];
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
    message.username = self.user.name;  //@"right button name";//[LoremIpsum name];
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
    [self.tableView insertRowsAtIndexPaths:@[ indexPath ] withRowAnimation:rowAnimation];
    [self.tableView endUpdates];

    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];

    // Fixes the cell from blinking (because of the transform, when using translucent cells)
    // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [super didPressRightButton:sender];

    [self sendMessage:message];
    // [self.textView refreshFirstResponder];

    //    QZBComment *message = [QZBComment new];
    //    message.username = self.user.name;//@"right button name";//[LoremIpsum name];
    //    message.text = [self.textView.text copy];
    //    message.timestamp = [NSDate date];
    //
    //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //    UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom :
    //    UITableViewRowAnimationTop;
    //    UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom
    //    : UITableViewScrollPositionTop;
    //
    //    [self.tableView beginUpdates];
    //    [self.messages insertObject:message atIndex:0];
    //    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
    //    [self.tableView endUpdates];
    //
    //    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition
    //    animated:YES];
    //
    //    // Fixes the cell from blinking (because of the transform, when using translucent cells)
    //    // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
    //    [self.tableView reloadRowsAtIndexPaths:@[indexPath]
    //    withRowAnimation:UITableViewRowAnimationAutomatic];

    // [super didPressRightButton:sender];
}
-(void)sendMessage:(QZBComment *)comment {
    [[QZBServerManager sharedManager] POSTSendMessage:comment.text inRoomWithID:self.roomID
    onSuccess:^{
        comment.isSended = YES;
    } onFailure:^(NSError *error, NSInteger statusCode) {//REDO TEST (may not crash)
        if(![self.messages containsObject:comment]){
            return ;
        }
        
        NSInteger row = [self.messages indexOfObject:comment];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView beginUpdates];
        [self.messages removeObject:comment];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
       
        [self.tableView endUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [TSMessage showNotificationWithTitle:@"Не удалось отправить сообщение" type:TSMessageNotificationTypeError];

        
    }];
}

- (void)didPressArrowKey:(id)sender {
    [super didPressArrowKey:sender];

    UIKeyCommand *keyCommand = (UIKeyCommand *)sender;

    if ([keyCommand.input isEqualToString:UIKeyInputUpArrow]) {
        [self editLastMessage:nil];
    }
}

- (NSString *)keyForTextCaching {
    return [[NSBundle mainBundle] bundleIdentifier];
}

//- (void)didPasteMediaContent:(NSDictionary *)userInfo
//{
//    // Notifies the view controller when the user has pasted a media (image, video, etc) inside of
//    the text view.
//
//    SLKPastableMediaType mediaType = [userInfo[SLKTextViewPastedItemMediaType] integerValue];
//    NSString *contentType = userInfo[SLKTextViewPastedItemContentType];
//    NSData *contentData = userInfo[SLKTextViewPastedItemData];
//
//    NSLog(@"%s : %@",__FUNCTION__, contentType);
//
//    if ((mediaType & SLKPastableMediaTypePNG) || (mediaType & SLKPastableMediaTypeJPEG)) {
//
//        QZBComment *message = [QZBComment new];
//        message.username = [LoremIpsum name];
//        message.text = @"Attachment";
//     //   message.attachment = [UIImage imageWithData:contentData scale:[UIScreen
//     mainScreen].scale];
//
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        UITableViewRowAnimation rowAnimation = self.inverted ? UITableViewRowAnimationBottom :
//        UITableViewRowAnimationTop;
//        UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom
//        : UITableViewScrollPositionTop;
//
//        [self.tableView beginUpdates];
//        [self.messages insertObject:message atIndex:0];
//        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
//        [self.tableView endUpdates];
//
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition
//        animated:YES];
//    }
//}

- (void)willRequestUndo {
    // Notifies the view controller when a user did shake the device to undo the typed text

    [super willRequestUndo];
}

- (void)didCommitTextEditing:(id)sender {
    // Notifies the view controller when tapped on the right "Accept" button for commiting the
    // edited text

    QZBComment *message = [QZBComment new];
    message.username = @"Commit name";  //[LoremIpsum name];
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
    //    NSArray *array = nil;
    //    NSString *prefix = self.foundPrefix;
    //    NSString *word = self.foundWord;
    //
    //    self.searchResult = nil;
    //
    //    if ([prefix isEqualToString:@"@"]) {
    //        if (word.length > 0) {
    //            array = [self.users filteredArrayUsingPredicate:[NSPredicate
    //            predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
    //        }
    //        else {
    //            array = self.users;
    //        }
    //    }
    //    else if ([prefix isEqualToString:@"#"] && word.length > 0) {
    //        array = [self.channels filteredArrayUsingPredicate:[NSPredicate
    //        predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
    //    }
    //    else if (([prefix isEqualToString:@":"] || [prefix isEqualToString:@"+:"]) && word.length
    //    > 1) {
    //        array = [self.emojis filteredArrayUsingPredicate:[NSPredicate
    //        predicateWithFormat:@"self BEGINSWITH[c] %@", word]];
    //    }
    //
    //    if (array.count > 0) {
    //        array = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    //    }
    //
    //    self.searchResult = [[NSMutableArray alloc] initWithArray:array];
    //
    //    return self.searchResult.count > 0;
}

//- (CGFloat)heightForAutoCompletionView
//{
//    CGFloat cellHeight = [self.autoCompletionView.delegate tableView:self.autoCompletionView
//    heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//    return cellHeight*self.searchResult.count;
//}

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
    //  if ([tableView isEqual:self.tableView]) {
    return [self messageCellForRowAtIndexPath:indexPath];
    //    }
    //    else {
    //        return [self autoCompletionCellForRowAtIndexPath:indexPath];
    //    }
}

- (QZBCommentRoomCell *)messageCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QZBCommentRoomCell *cell = (QZBCommentRoomCell *)
        [self.tableView dequeueReusableCellWithIdentifier:MessengerCellIdentifier];

    //    if (!cell.textLabel.text) {
    //        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
    //        initWithTarget:self action:@selector(editCellMessage:)];
    //        [cell addGestureRecognizer:longPress];
    //    }

    QZBComment *message = self.messages[indexPath.row];

    cell.titleLabel.text = message.username;
    cell.bodyLabel.text = message.text;
    NSString *minutes = [message.timestamp minute] < 10
                            ? [NSString stringWithFormat:@"0%ld", [message.timestamp minute]]
                            : [NSString stringWithFormat:@"%ld", [message.timestamp minute]];
    cell.timeAgoLabel.text =
        [NSString stringWithFormat:@"%ld:%@", [message.timestamp hour], minutes];
    //[message.timestamp timeAgoSinceNow];

    //    if (message.attachment) {
    //        cell.attachmentView.image = message.attachment;
    //        cell.attachmentView.layer.shouldRasterize = YES;
    //        cell.attachmentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    //    }

    cell.indexPath = indexPath;
    cell.usedForMessage = YES;

    if (cell.needsPlaceholder) {
        //        CGFloat scale = [UIScreen mainScreen].scale;
        //        CGSize imgSize = CGSizeMake(kMessageTableViewCellAvatarHeight*scale,
        //        kMessageTableViewCellAvatarHeight*scale);
        if (message.owner.imageURL) {
            DFImageRequestOptions *options = [DFImageRequestOptions new];
            options.allowsClipping = YES;

            options.userInfo =
                @{ DFURLRequestCachePolicyKey : @(NSURLRequestReturnCacheDataElseLoad) };

            DFImageRequest *request =
                [DFImageRequest requestWithResource:message.owner.imageURL
                                         targetSize:CGSizeZero
                                        contentMode:DFImageContentModeAspectFill
                                            options:options];

            cell.thumbnailView.allowsAnimations = YES;
            cell.thumbnailView.allowsAutoRetries = YES;

            [cell.thumbnailView prepareForReuse];

            [cell.thumbnailView setImageWithRequest:request];

            //        DFImageView *imageView = cell.thumbnailView;
            //        imageView.allowsAnimations = YES; // Animates images when the response isn't
            //        fast enough
            //        imageView.managesRequestPriorities = YES; // Automatically changes current
            //        request priority when image view gets added/removed from the window
            //
            //        [imageView prepareForReuse];
            //        [imageView setImageWithResource:message.owner.imageURL];
        } else {
            cell.thumbnailView.image = [UIImage imageNamed:@"userpicStandart"];
        }

        //        [LoremIpsum asyncPlaceholderImageWithSize:imgSize
        //                                       completion:^(UIImage *image) {
        //                                           UIImage *thumbnail = [UIImage
        //                                           imageWithCGImage:image.CGImage scale:scale
        //                                           orientation:UIImageOrientationUp];
        //                                           cell.thumbnailView.image = thumbnail;
        //                                           cell.thumbnailView.layer.shouldRasterize = YES;
        //                                           cell.thumbnailView.layer.rasterizationScale =
        //                                           [UIScreen mainScreen].scale;
        //                                       }];
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
            NSFontAttributeName : [UIFont systemFontOfSize:pointSize],
            NSParagraphStyleAttributeName : paragraphStyle
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
        //        if (message.attachment) {
        //            height += 80.0 + 10.0;
        //        }

        if (height < kMessageTableViewCellMinimumHeight) {
            height = kMessageTableViewCellMinimumHeight;
        }

        return height;
    } else {
        return kMessageTableViewCellMinimumHeight;
    }
}

#pragma mark - UITableViewDelegate Methods

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([tableView isEqual:self.autoCompletionView]) {
//
//        NSMutableString *item = [self.searchResult[indexPath.row] mutableCopy];
//
//        if ([self.foundPrefix isEqualToString:@"@"] && self.foundPrefixRange.location == 0) {
//            [item appendString:@":"];
//        }
//        else if (([self.foundPrefix isEqualToString:@":"] || [self.foundPrefix
//        isEqualToString:@"+:"])) {
//            [item appendString:@":"];
//        }
//
//        [item appendString:@" "];
//
//        [self acceptAutoCompletionWithString:item keepPrefix:YES];
//    }
//}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Since SLKTextViewController uses UIScrollViewDelegate to update a few things, it is important
    // that if you ovveride this method, to call super.
    [super scrollViewDidScroll:scrollView];
}

#pragma mark - UITextViewDelegate Methods

- (BOOL)textView:(SLKTextView *)textView
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

-(void)addSpinnerRight {
    UIActivityIndicatorView *actInd = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,20, 20)];
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

-(void)reloadMessages {
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
    [self.tableView insertRowsAtIndexPaths:@[ indexPath ] withRowAnimation:rowAnimation];
    [self.tableView endUpdates];

    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];

    // Fixes the cell from blinking (because of the transform, when using translucent cells)
    // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end
