#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define UIColorFromRGB(rgbValue)                                               \
  [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0         \
                  green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0            \
                   blue:((float)(rgbValue & 0xFF)) / 255.0                     \
                  alpha:1.0]

#define QZB_PRODUCTION 0

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

@end
