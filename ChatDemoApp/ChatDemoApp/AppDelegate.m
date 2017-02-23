//
//  AppDelegate.m
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "AppDelegate.h"
#import "MMMaterialDesignSpinner.h"

//Uncomment libxml code while running on devices in module.modulemap
//#import "XMPPFramework.h"

@import GoogleMaps;
@import GooglePlacePicker;
@interface AppDelegate () {

    UIImageView *spinnerBackground;
    UIView *loaderView;
}
@property (nonatomic, strong) MMMaterialDesignSpinner *spinnerView;
@property (nonatomic, strong) UILabel *loaderLabel;
//- (void)setupStream;
//- (void)teardownStream;
//- (void)goOnline;
//- (void)goOffline;
@end

@implementation AppDelegate
@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //set navigation bar properties.
    [[UINavigationBar appearance] setBarTintColor:[UIColor darkGrayColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:18], NSFontAttributeName, nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //end
//https://developers.google.com/places/ios-api/start
    [GMSServices provideAPIKey:@"AIzaSyBDfypjucz1_4wKfiKyvXg8PD7TLaIl8cc"];
    [GMSPlacesClient provideAPIKey:@"AIzaSyBDfypjucz1_4wKfiKyvXg8PD7TLaIl8cc"];
    self.navigationController = (UINavigationController *)[self.window rootViewController];
    
    //ios9 or later
//    center = [UNUserNotificationCenter currentNotificationCenter];
//    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
//                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
//                              // Enable or disable features based on authorization.
//                              if (!granted) {
//                                  NSLog(@"Something went wrong");
//                              }
//                          }];
    //end
    
    //permission for local notification
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    UILocalNotification *localNotiInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey];
    
    //Accept local notification when app is not open
    if (localNotiInfo)
    {
        [self application:application didReceiveLocalNotification:localNotiInfo];
    }
    
//    
//    userProfileImageData = [[UIImageView alloc] init];
//    
//    userHistoryArr = [NSMutableArray new];
//    userProfileImage = [NSMutableDictionary new];
////    if ([UserDefaultManager getValue:@"LoginCred"] == nil) {
//        [UserDefaultManager setValue:@"zebra@192.168.1.169" key:@"LoginCred"];
//        [UserDefaultManager setValue:@"password" key:@"PassCred"];
//        
////    }
//    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
//    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
//    if ([UserDefaultManager getValue:@"CountData"] == nil) {
//        NSMutableDictionary* countData = [NSMutableDictionary new];
//        [UserDefaultManager setValue:countData key:@"CountData"];
//    }
//    if ([UserDefaultManager getValue:@"BadgeCount"] == nil) {
//        [UserDefaultManager setValue:@"0" key:@"BadgeCount"];
//    }
//    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
//    [self setupStream];
//    [self connect];
    
    //Initialize xmpp connection
    [self didFinishLaunchingMethod];//Call appdelegateObjectFile method
    
    //For file transfer testing
    [self savePdfFileInDocument];
    //end
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] != nil)
    {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"DashboardViewController"];
//        [self.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
//                                             animated: YES]
        UIViewController * objView=[storyboard instantiateViewControllerWithIdentifier:@"DashboardNavigation"];
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.window setRootViewController:objView];
        [self.window makeKeyAndVisible];;
    }
//    NSDictionary *remoteNotifiInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
//    //Accept push notification when app is not open
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//    if (remoteNotifiInfo)
//    {
//        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//        [self application:application didReceiveRemoteNotification:remoteNotifiInfo];
//    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    [self enterBackgroundMethod:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [self enterForegroundMethod:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [self enterTerminationMethod:application];
}

#pragma mark - Global indicator view
- (void)showIndicator {
    
    spinnerBackground=[[UIImageView alloc]initWithFrame:CGRectMake(3, 3, 50, 50)];
    spinnerBackground.backgroundColor=[UIColor whiteColor];
    spinnerBackground.layer.cornerRadius=25.0f;
    spinnerBackground.clipsToBounds=YES;
    spinnerBackground.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    
    loaderView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.window.bounds.size.width, self.window.bounds.size.height)];
    loaderView.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5];
    [loaderView addSubview:spinnerBackground];
    
    self.spinnerView = [[MMMaterialDesignSpinner alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.spinnerView.tintColor = [UIColor darkGrayColor];
    self.spinnerView.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));
    self.spinnerView.lineWidth=3.0f;
    
    self.loaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height / 2) + 30, [[UIScreen mainScreen] bounds].size.width, 20)];
    self.loaderLabel.backgroundColor = [UIColor clearColor];
    self.loaderLabel.textColor = [UIColor whiteColor];
    self.loaderLabel.font = [UIFont systemFontOfSize:14];
    self.loaderLabel.textAlignment = NSTextAlignmentCenter;
    self.loaderLabel.text = @"Loading...";
    
    loaderView.tag=23165;
    [self.window addSubview:loaderView];
    [self.window addSubview:self.spinnerView];
    [self.window addSubview:self.loaderLabel];
    [self.spinnerView startAnimating];
}

- (void)stopIndicator
{
    [self.spinnerView stopAnimating];
    [loaderView removeFromSuperview];
    [self.spinnerView removeFromSuperview];
    [self.loaderLabel removeFromSuperview];
}
#pragma mark - end

#pragma mark - Push notification methods
-(void)registerDeviceForNotification
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken1
{
    NSString *token = [[deviceToken1 description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    //    self.deviceToken = token;
    NSLog(@"device token...........%@",token);
    
}
#pragma mark - end

#pragma mark - Local notification
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    if (application.applicationState == UIApplicationStateActive) {
        
    }
    else {
        
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}
#pragma mark - end

- (void)savePdfFileInDocument {
    
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *filePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/a.pdf",self.appDocumentfolderName]];
    success = [fileManager fileExistsAtPath:filePath];
    if (success) {
        return;
    }
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *filePath1 = [mainBundle pathForResource:@"a" ofType:@"pdf"];
    success = [fileManager copyItemAtPath:filePath1 toPath:filePath error:&error];
    NSAssert(success, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
}
@end
