#import "QZBPasswordTextField.h"

@implementation QZBPasswordTextField

- (BOOL)validate {
  return ([self.text length] >= 6);
}

@end
