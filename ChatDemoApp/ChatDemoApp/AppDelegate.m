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

#pragma mark - Local notification
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
    if (application.applicationState == UIApplicationStateActive) {
        
    }
    else {
        
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
//    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    
//#if TARGET_IPHONE_SIMULATOR
//    DDLogError(@"The iPhone simulator does not process background network traffic. "
//               @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
//#endif
//    
//    if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
//    {
//        [application setKeepAliveTimeout:600 handler:^{
//            
//            DDLogVerbose(@"KeepAliveHandler");
//            
//            // Do other keep alive stuff here.
//        }];
//    }
    [self enterBackgroundMethod:application];
}

//Here stop to app in terminate mode
//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    
//    __block UIBackgroundTaskIdentifier identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        if (identifier != UIBackgroundTaskInvalid) {
//            [[UIApplication sharedApplication] endBackgroundTask:identifier];
//            identifier = UIBackgroundTaskInvalid;
//        }
//    }];
////
//    dispatch_async(dispatch_get_main_queue(), ^{
//        for (int i=0; i < 100000; i++) {
//            NSLog(@"%d", i);
//            sleep(2);
//        }
//        
//        if (identifier != UIBackgroundTaskInvalid) {
//            [[UIApplication sharedApplication] endBackgroundTask:identifier];
//            identifier = UIBackgroundTaskInvalid;
//        }
//    });
//    
//}

//- (void)targetMethod {
//    NSLog(@"called");
//}
//
//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    NSLog(@"termination------------------> %s", __PRETTY_FUNCTION__);
//}


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


//#pragma mark - Push notification methods
//
//-(void)registerDeviceForNotification
//{
//    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
//    {
//        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
//    }
//    else
//    {
//        
//        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
//    }
//}
//
//- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken1
//{
//    NSString *token = [[deviceToken1 description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
//    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSLog(@"Notification token device ...............................////// info %@",token);
//    self.deviceToken = token;
//    
//    [[WebService sharedManager] registerDeviceForPushNotification:token deviceType:@"ios"  success:^(id responseObject) {
//        //[myDelegate stopIndicator];
//    } failure:^(NSError *error) {
//        
//    }] ;
//}
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]!=nil)
//    {
//        [UIApplication sharedApplication].applicationIconBadgeNumber=0;
//        NSLog(@"Notification userinfo  --------------------->>>%@",userInfo);
//        NSDictionary *tempDict=[userInfo objectForKey:@"aps"];
//        if (application.applicationState == UIApplicationStateActive)
//        {
//            if ([[tempDict objectForKey:@"isChat"]intValue]!=1) {
//                [self addBadgeIconLastTab];
//                if ([myDelegate.myView isEqualToString:@"MyProfileViewController" ]) {
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"MyProfileData" object:nil];
//                }
//            }
//        }
//    }
//    else
//    {
//        return;
//    }
//}
//- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
//{
//    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
//    NSLog(@"did failtoRegister and testing : %@",str);
//    
//}
//-(void)unregisterDeviceForNotification
//{
//    [[UIApplication sharedApplication]  unregisterForRemoteNotifications];
//}
//
//#pragma mark - end

//#pragma mark - XMPP framework chat code
//
//- (NSManagedObjectContext *)managedObjectContext_roster
//{
//    return [xmppRosterStorage mainThreadManagedObjectContext];
//}
//
//- (NSManagedObjectContext *)managedObjectContext_capabilities
//{
//    return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
//}
//
//- (void)setupStream
//{
//    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
//    xmppStream = [[XMPPStream alloc] init];
//    
//#if !TARGET_IPHONE_SIMULATOR
//    {
//        xmppStream.enableBackgroundingOnSocket = YES;
//    }
//#endif
//    
//    
//    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
//    
//    xmppReconnect = [[XMPPReconnect alloc] init];
//    
//    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
//    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
//    
//    xmppRoster.autoFetchRoster = YES;
//    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
//    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
//    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
//    
//    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
//    
//    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
//    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
//    
//    xmppCapabilities.autoFetchHashedCapabilities = YES;
//    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
//    
//    // Activate xmpp modules
//    
//    [xmppReconnect         activate:xmppStream];
//    [xmppRoster            activate:xmppStream];
//    [xmppvCardTempModule   activate:xmppStream];
//    [xmppvCardAvatarModule activate:xmppStream];
//    [xmppCapabilities      activate:xmppStream];
//    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    
//    [xmppStream setHostName:@"192.168.1.169"];
//    [xmppStream setHostPort:5222];
//    
//    customCertEvaluation = YES;
//}
//
//- (void)teardownStream
//{
//    [xmppStream removeDelegate:self];
//    [xmppRoster removeDelegate:self];
//    
//    [xmppReconnect         deactivate];
//    [xmppRoster            deactivate];
//    [xmppvCardTempModule   deactivate];
//    [xmppvCardAvatarModule deactivate];
//    [xmppCapabilities      deactivate];
//    
//    [xmppStream disconnect];
//    
//    xmppStream = nil;
//    xmppReconnect = nil;
//    xmppRoster = nil;
//    xmppRosterStorage = nil;
//    xmppvCardStorage = nil;
//    xmppvCardTempModule = nil;
//    xmppvCardAvatarModule = nil;
//    xmppCapabilities = nil;
//    xmppCapabilitiesStorage = nil;
//}
//
//- (void)goOnline
//{
//    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
//    
//    NSString *domain = [xmppStream.myJID domain];
//    
//    //Google set their presence priority to 24, so we do the same to be compatible.
//    
//    if([domain isEqualToString:@"gmail.com"]
//       || [domain isEqualToString:@"gtalk.com"]
//       || [domain isEqualToString:@"talk.google.com"]  || [domain isEqualToString:@"192.168.1.169"])
//    {
//        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
//        [presence addChild:priority];
//    }
//    
//    [[self xmppStream] sendElement:presence];
//}
//
//- (void)goOffline
//{
//    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
//    
//    [[self xmppStream] sendElement:presence];
//}
//#pragma mark - end
//
//#pragma mark - Connect/disconnect user
//- (BOOL)connect
//{
//    if (![xmppStream isDisconnected]) {
//        return YES;
//    }
//    
//    NSString *myJID = [UserDefaultManager getValue:@"LoginCred"];
//    NSString *myPassword = [UserDefaultManager getValue:@"PassCred"];
//    
//    if (myJID == nil || myPassword == nil)
//    {
//        return NO;
//    }
//    
//    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
//    password = myPassword;
//    
//    NSError *error = nil;
//    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
//                                                            message:@"See console for error details."
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"Ok"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//        
//        DDLogError(@"Error connecting: %@", error);
//        
//        return NO;
//    }
//    
//    return YES;
//}
//
//- (void)disconnect
//{
//    [self goOffline];
//    [xmppStream disconnect];
//}
//#pragma mark - end
//
//#pragma mark - XMPPStream Delegate
//- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//}
//
//- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    
//    NSString *expectedCertName = [xmppStream.myJID domain];
//    if (expectedCertName)
//    {
//        [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
//    }
//    
//    if (customCertEvaluation)
//    {
//        [settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
//    }
//}
//
//- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
// completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    
//    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(bgQueue, ^{
//        
//        SecTrustResultType result = kSecTrustResultDeny;
//        OSStatus status = SecTrustEvaluate(trust, &result);
//        
//        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
//            completionHandler(YES);
//        }
//        else {
//            completionHandler(NO);
//        }
//    });
//}
//
//- (void)xmppStreamDidSecure:(XMPPStream *)sender
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//}
//
//- (void)xmppStreamDidConnect:(XMPPStream *)sender
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    
//    isXmppConnected = YES;
//    
//    NSError *error = nil;
//    
//    if (![[self xmppStream] authenticateWithPassword:password error:&error])
//    {
//        DDLogError(@"Error authenticating: %@", error);
//    }
//}
//
//- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    
//    [self goOnline];
//    
//    if ([xmppStream isAuthenticated]) {
//        
//        NSLog(@"authenticated");
//        [xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:@"test11@administrator"] ignoreStorage:YES];
//        
//    }
//    
//}
//
//- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule{
//    NSLog(@"succes");
//}
//
//- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error{
//    NSLog(@"fail");
//}
//
//- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
//                                                    message:@"Please Check Username or Password"
//                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
//
//}
//
//-(void)fetchRosterListWithUserId:(NSString *)userId // yourID
//{
//    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
//    XMPPIQ *iq = [XMPPIQ iq];
//    [iq addAttributeWithName:@"id" stringValue:@"14z2as5a236ew"];
//    [iq addAttributeWithName:@"to" stringValue:userId];
//    [iq addAttributeWithName:@"type" stringValue:@"get"];
//    [iq addChild:query];
//    [xmppStream sendElement:iq];
//}
//
//- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
//{
//    
//    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
//    
//    if (queryElement) {
//        NSArray *itemElements = [queryElement elementsForName: @"item"];
//        NSMutableArray *mArray = [[NSMutableArray alloc] init];
//        for (int i=0; i<[itemElements count]; i++) {
//            
//            NSString *jid=[[[itemElements objectAtIndex:i] attributeForName:@"jid"] stringValue];
//            [mArray addObject:jid];
//        }
//        
//        
//        
//    }
//    return NO;
//}
//
//- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    
//    if ([message isChatMessageWithBody])
//    {
//        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
//                                                                 xmppStream:xmppStream
//                                                       managedObjectContext:[self managedObjectContext_roster]];
//        NSLog(@"%@",user);
//        
//        
//        [message addAttributeWithName:@"fromTo" stringValue:[NSString stringWithFormat:@"%@-%@",[message attributeStringValueForName:@"to"],[[[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"] objectAtIndex:0]]];
//        
//        [xmppMessageArchivingCoreDataStorage archiveMessage:message outgoing:NO xmppStream:[self xmppStream]];
//        NSString *keyName = [[[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"] objectAtIndex:0];
//        if ([[UserDefaultManager getValue:@"CountData"] objectForKey:keyName] == nil) {
//            int tempCount = 1;
//            
//            NSMutableDictionary *tempDict = [[UserDefaultManager getValue:@"CountData"] mutableCopy];
//            [tempDict setObject:[NSString stringWithFormat:@"%d",tempCount] forKey:keyName];
//            [UserDefaultManager setValue:tempDict key:@"CountData"];
//        }
//        else{
//            int tempCount = [[[UserDefaultManager getValue:@"CountData"] objectForKey:keyName] intValue];
//            tempCount = tempCount + 1;
//            NSMutableDictionary *tempDict = [[UserDefaultManager getValue:@"CountData"] mutableCopy];
//            [tempDict setObject:[NSString stringWithFormat:@"%d",tempCount] forKey:keyName];
//            [UserDefaultManager setValue:tempDict key:@"CountData"];
//        }
//        
//        NSArray* fromUser = [[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
//        NSLog(@"%@",myDelegate.chatUser);
//        if ([myDelegate.chatUser isEqualToString:[fromUser objectAtIndex:0]]){
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserHistory" object:message];
//        }
//        else if ([myDelegate.chatUser isEqualToString:@"ChatScreen"]){  //this is use for History chat screen if already open
//            [self addBadgeIcon:[NSString stringWithFormat:@"%d",[[UserDefaultManager getValue:@"BadgeCount"] intValue] + 1 ]];
//            [UserDefaultManager setValue:[NSString stringWithFormat:@"%d",[[UserDefaultManager getValue:@"BadgeCount"] intValue] + 1 ] key:@"BadgeCount"];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatScreenHistory" object:nil];
//        }
//        else{
//            [self addBadgeIcon:[NSString stringWithFormat:@"%d",[[UserDefaultManager getValue:@"BadgeCount"] intValue] + 1 ]];
//            [UserDefaultManager setValue:[NSString stringWithFormat:@"%d",[[UserDefaultManager getValue:@"BadgeCount"] intValue] + 1 ] key:@"BadgeCount"];
//        }
//    }
//}
//
//- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
//{
//    
//    NSString *presenceType = [presence type];
//    if  ([presenceType isEqualToString:@"subscribe"]) {
//        
//        [xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
//    }
//    NSLog(@" Printing full jid of user %@",[[sender myJID] full]);
//    NSLog(@"Printing full jid of user %@",[[sender myJID] resource]);
//    NSLog(@"From user %@",[[presence from] full]);
//    
//    int myCount = [[UserDefaultManager getValue:@"CountValue"] intValue];
//    
//    if (myCount == 1) {
//        [UserDefaultManager setValue:[NSString stringWithFormat:@"%d",myCount+1] key:@"CountValue"];
//        [self performSelector:@selector(methodCalling) withObject:nil afterDelay:0.1];
//    }
//    
//}
//
//- (void)xmppStreamDidRegister:(XMPPStream *)sender{
//    
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Registration Successful!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
//}
//
//
//- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
//    
//    DDXMLElement *errorXML = [error elementForName:@"error"];
//    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
//    
//    NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
//    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed!" message:regError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    
//    if([errorCode isEqualToString:@"409"]){
//        
//        [alert setMessage:@"Username Already Exists!"];
//    }   
//    [alert show];
//}
//
//-(void)methodCalling{
//    
//    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
//    XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
//    NSData *pictureData = UIImageJPEGRepresentation([UIImage imageWithData:myDelegate.userProfileImageDataValue], 0.5);
//    [newvCardTemp setPhoto:pictureData];
//    XMPPvCardCoreDataStorage * xmppvCardStorage1 = [XMPPvCardCoreDataStorage sharedInstance];
//    XMPPvCardTempModule * xmppvCardTempModule1 = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage1];
//    [xmppvCardTempModule1  activate:[self xmppStream]];
//    [xmppvCardTempModule1 updateMyvCardTemp:newvCardTemp];
//    [myDelegate stopIndicator];
//    
//}
//-(void)editProfileImageUploading:(UIImage*)editProfileImge{
//    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
//    XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
//    NSData *pictureData = UIImageJPEGRepresentation(editProfileImge, 0.5);
//    
//    [newvCardTemp setPhoto:pictureData];
//    XMPPvCardCoreDataStorage * xmppvCardStorage1 = [XMPPvCardCoreDataStorage sharedInstance];
//    XMPPvCardTempModule * xmppvCardTempModule1 = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage1];
//    [xmppvCardTempModule1  activate:[self xmppStream]];
//    [xmppvCardTempModule1 updateMyvCardTemp:newvCardTemp];
//    [myDelegate stopIndicator];
//    
//}
//
//- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//}
//
//- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    
//    if (!isXmppConnected)
//    {
//        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
//    }
//}
//#pragma mark - end

//#pragma mark - Add badge icon
//-(void)addBadgeIcon:(NSString*)badgeValue{
//    
////    if ([badgeValue intValue] < 1) {
////        [self removeBadgeIcon];
////    }
////    else{
////        for (UILabel *subview in myDelegate.tabBarView.tabBar.subviews)
////        {
////            if ([subview isKindOfClass:[UILabel class]])
////            {
////                if (subview.tag == 2365) {
////                    [subview removeFromSuperview];
////                }
////            }
////        }
////        
////        UILabel *a = [[UILabel alloc] init];
////        a.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width/5) + (([UIScreen mainScreen].bounds.size.width/5)/2) , 0, 25, 20);
////        a.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:83.0/255.0 blue:77.0/255.0 alpha:1.0];
////        a.layer.cornerRadius = 10;
////        a.layer.masksToBounds = YES;
////        a.text = badgeValue;
////        a.tag = 2365;
////        a.textAlignment = NSTextAlignmentCenter;
////        [a setFont:[UIFont fontWithName:@"Roboto-Regular" size:10.0]];
////        a.textColor = [UIColor whiteColor];
////        [myDelegate.tabBarView.tabBar addSubview:a];
////    }
//    
//}
//-(void)addBadgeIconLastTab
//{
//    
////    for (UILabel *subview in myDelegate.tabBarView.tabBar.subviews)
////    {
////        if ([subview isKindOfClass:[UILabel class]])
////        {
////            if (subview.tag == 3365) {
////                [subview removeFromSuperview];
////            }
////        }
////    }
////    
////    UILabel *notificationBadge = [[UILabel alloc] init];
////    notificationBadge.frame = CGRectMake((([UIScreen mainScreen].bounds.size.width/5)*4) + (([UIScreen mainScreen].bounds.size.width/5)/2) + 8 , 8, 8, 8);
////    notificationBadge.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:83.0/255.0 blue:77.0/255.0 alpha:1.0];
////    notificationBadge.layer.cornerRadius = 5;
////    notificationBadge.layer.masksToBounds = YES;
////    notificationBadge.tag = 3365;
////    [myDelegate.tabBarView.tabBar addSubview:notificationBadge];
//    
//    
//}
//
//
//#pragma mark - end
//#pragma mark - Remove badge icon
//-(void)removeBadgeIcon{
////    for (UILabel *subview in myDelegate.tabBarView.tabBar.subviews)
////    {
////        if ([subview isKindOfClass:[UILabel class]])
////        {
////            if (subview.tag == 2365) {
////                [subview removeFromSuperview];
////            }
////        }
////    }
//}
//
//-(void)removeBadgeIconLastTab
//{
////    for (UILabel *subview in myDelegate.tabBarView.tabBar.subviews)
////    {
////        if ([subview isKindOfClass:[UILabel class]])
////        {
////            if (subview.tag == 3365) {
////                [subview removeFromSuperview];
////            }
////        }
////    }
//}
//
//#pragma mark - end

//#pragma mark - XMPPRosterDelegate
//
//- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
//{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    
//    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
//                                                             xmppStream:xmppStream
//                                                   managedObjectContext:[self managedObjectContext_roster]];
//    
//    NSString *displayName = [[[user displayName] componentsSeparatedByString:@"@52.74.174.129@"] objectAtIndex:0];
//    NSString *jidStrBare = [presence fromStr];
//    NSString *body = nil;
//    
//    if (![displayName isEqualToString:jidStrBare])
//    {
//        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
//    }
//    else
//    {
//        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
//    }
//    
//    
//    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
//    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:jidStrBare
//                                                            message:body
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        [alertView show];
//    }
//    else
//    {
//        
//        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//        localNotification.alertAction = @"OK";
//        localNotification.alertBody = body;
//        
//        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
//    }
//    
//}
//
//- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
//{
//    if ([myDelegate.myView isEqualToString:@"UserListView"]) {
//        [myDelegate stopIndicator];
//    }
//    
//}
//#pragma mark - end
//[self saveContext];
//}
@end
