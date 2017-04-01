#import "QZBImageViewerVC.h"
#import <UIImageView+AFNetworking.h>
#import "QZBCurrentUser.h"
//#import <SVProgressHUD.h>
//#import "QZBServerManager.h"
#import "UIImageView+QZBImagePickerCategory.h"

@interface QZBImageViewerVC ()

@property (strong, nonatomic) id <QZBUserProtocol> user;

@end

@implementation QZBImageViewerVC

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.userPicImageView removeConstraints:self.userPicImageView.constraints];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  if ([self.user respondsToSelector:@selector(imageURLBig)]) {
    [self setImageWithUrl:self.user.imageURLBig];
  } else {
    [self setImageWithUrl:self.user.imageURL];
  }
}

- (void)setImageWithUrl:(NSURL *)url {

  if (url) {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                            timeoutInterval:60];
    __weak typeof(self) weakSelf = self;
    [self.userPicImageView setImageWithURLRequest:urlRequest placeholderImage:[UIImage imageNamed:@"userpicStandart"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
      [weakSelf.userPicImageView setImage:image];
    }                                     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
  } else {
    [self.userPicImageView setImage:[UIImage imageNamed:@"userpicStandart"]];
  }
}

- (void)configureWithUser:(id <QZBUserProtocol>)user {

  self.user = user;

  if ([[QZBCurrentUser sharedInstance].user.userID isEqualToNumber:user.userID]) {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:@"Изменить"
                style:UIBarButtonItemStylePlain
               target:self
               action:@selector(showChoose)];
  }
}

#pragma  mark - action sheet

- (void)showChoose {
  UIActionSheet *actSheet =
      [[UIActionSheet alloc] initWithTitle:@"Изменить аватар"
                                  delegate:self
                         cancelButtonTitle:@"Отменить"
                    destructiveButtonTitle:nil
                         otherButtonTitles:@"Выбрать из галереи",
                                           @"Сфотографировать", @"Удалить фотографию", nil];

  [actSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

  if (buttonIndex == 0) {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
      [self selectPhoto:nil];
    } else {
      [[[UIAlertView alloc] initWithTitle:@"Нет доступа к фотогалерее"
                                  message:@"Включите доступ к фотогалерее в настройках приложения"
                                 delegate:nil
                        cancelButtonTitle:@"Ок"
                        otherButtonTitles:nil] show];
    }
  } else if (buttonIndex == 1) {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
      [self takePhoto:nil];
    } else {
      [[[UIAlertView alloc] initWithTitle:@"Нет доступа к камере" message:@"Включите доступ к камере в настройках приложения" delegate:nil cancelButtonTitle:@"Ок" otherButtonTitles:nil] show];
    }
  } else if (buttonIndex == 2) {
    [self.userPicImageView loadDeafaultPicture];
  }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - image picker

- (IBAction)takePhoto:(UIButton *)sender {

  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.delegate = self;
  picker.allowsEditing = YES;
  picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;

  [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)selectPhoto:(UIButton *)sender {

  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.delegate = self;
  picker.allowsEditing = YES;
  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

  [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
  [self.userPicImageView loadNewPic:chosenImage];
  [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
