//
//  AppDelegateObjectFile.m
//  ChatDemoApp
//
//  Created by Ranosys on 18/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "AppDelegateObjectFile.h"
#import <UserNotifications/UserNotifications.h>

//Uncomment libxml code while running on devices in module.modulemap
#import "XMPPFramework.h"
#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <CFNetwork/CFNetwork.h>
#import "XMPPvCardTemp.h"
#import "UserDefaultManager.h"

#import "ErrorCode.h"
#import "XMPPUserDefaultManager.h"
#import "XmppCoreDataHandler.h"

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface AppDelegateObjectFile() {

    UIView *notificationView;
    UIImageView *notificationImage;
    UILabel *notificationTitle, *notificationMessage;
//    UIWindow* window;
}

- (void)setupStream;
- (void)teardownStream;
- (void)goOnline;
- (void)goOffline;
@end

@implementation AppDelegateObjectFile
@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;
@synthesize userHistoryArr;
@synthesize userProfileImage, chatUser;
@synthesize xmppMessageArchivingCoreDataStorage, xmppMessageArchivingModule;
@synthesize userProfileImageData;

@synthesize xmppUserEntries;
@synthesize presencexmpp;

@synthesize portNumber, hostName, serverName, defaultPassword, xmppUniqueId, conferenceServerJid;
@synthesize isUpdatePofile, selectedFriendUserId;

//Coredata
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
//end

@synthesize xmppUserDetailedList, xmppUserListArray;
@synthesize xmppLogedInUserId, isContactListIsLoaded, xmppLogedInUserName;
//App folders
@synthesize folderName;
@synthesize appMediafolderName;
@synthesize appProfilePhotofolderName;
@synthesize appSentReceivePhotofolderName;
@synthesize appDocumentfolderName;
@synthesize appMapPhotofolderName;
//end

@synthesize afterAutentication,afterAutenticationRegistration;

#pragma mark - Intialze XMPP connection
- (void)didFinishLaunchingMethod{

    isUpdatePofile=false;
    //Create cache folders
    folderName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    appMediafolderName=[NSString stringWithFormat:@"%@/%@_Media",folderName,folderName];
    appProfilePhotofolderName=[NSString stringWithFormat:@"%@/%@_ProfilePhotos",appMediafolderName,folderName];
    appSentReceivePhotofolderName=[NSString stringWithFormat:@"%@/%@_Photos/%@_SentReceived",appMediafolderName,folderName,folderName];
    appDocumentfolderName=[NSString stringWithFormat:@"%@/%@_Documents",folderName,folderName];
    appMapPhotofolderName=[NSString stringWithFormat:@"%@/%@_Map",folderName,folderName];
    [self createCacheDirectory];
    
    //end
    
    self.myView=@"Other";
    selectedFriendUserId=@"";
    isContactListIsLoaded=NO;
    if (nil!=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"HostName"] && NULL!=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"HostName"]) {
        hostName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"HostName"];
    }
    else {
        hostName = @"";
    }
    
//    @property(strong, nonatomic)NSString *conferenceServerJid;//ConferenceServerJid
    
    if (nil!=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"ConferenceServerJid"] && NULL!=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"ConferenceServerJid"]) {
        conferenceServerJid = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ConferenceServerJid"];
    }
    else {
        conferenceServerJid = @"";
    }

    if (nil!=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"ServerName"] && NULL!=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"ServerName"]) {
        serverName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"ServerName"];
    }
    else {
        serverName = @"";
    }
    
    if (nil!=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PortNumber"] && NULL!=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PortNumber"]) {
        portNumber = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PortNumber"] intValue];
    }
    else {
        portNumber = 0;
    }
    
    defaultPassword = @"password";
    xmppUniqueId=@"Zebra123456";
    userProfileImageData = [[UIImageView alloc] init];
    
    userHistoryArr = [NSMutableArray new];
    userProfileImage = [NSMutableDictionary new];
    
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
    

    if ([XMPPUserDefaultManager getValue:@"xmppUserListArray"] == nil) {
        NSMutableDictionary* tempDict = [NSMutableDictionary new];
        NSMutableArray* tempArray = [NSMutableArray new];
        [XMPPUserDefaultManager setValue:tempArray key:@"xmppUserListArray"];
        [XMPPUserDefaultManager setValue:tempDict key:@"xmppUserDetailedList"];
    }
    
    if ([XMPPUserDefaultManager getValue:@"CountData"] == nil) {
        NSMutableDictionary* countData = [NSMutableDictionary new];
        [XMPPUserDefaultManager setValue:countData key:@"CountData"];
    }
    if ([XMPPUserDefaultManager getValue:@"BadgeCount"] == nil) {
        [XMPPUserDefaultManager setValue:@"0" key:@"BadgeCount"];
    }
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
    [self setupStream];
    NSLog(@"%@",[XMPPUserDefaultManager getValue:@"LoginCred"]);
    
    if ([XMPPUserDefaultManager getValue:@"XMPPBadgeIndicator"] == nil) {
        NSMutableDictionary* countData = [NSMutableDictionary new];
        [XMPPUserDefaultManager setValue:countData key:@"XMPPBadgeIndicator"];
    }
    
    [self createNotificationView];
}
#pragma mark - end

- (void)createNotificationView{

    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(100,100, 100, 100)];
//        [redView setBackgroundColor:[UIColor redColor]];
//        [[appDelegate window] addSubview:redView];
        
        notificationView.translatesAutoresizingMaskIntoConstraints=YES;
        notificationView=[[UIView alloc] initWithFrame:CGRectMake(3, -90, [[UIScreen mainScreen] bounds].size.width-6, 80)];
        notificationImage=[[UIImageView alloc] initWithFrame:CGRectMake(10, (notificationView.frame.size.height/2)-20, 40, 40)];
        notificationTitle=[[UILabel alloc] initWithFrame:CGRectMake(notificationImage.frame.origin.x+notificationImage.frame.size.width+10, 10, [[UIScreen mainScreen] bounds].size.width-(notificationImage.frame.origin.x+notificationImage.frame.size.width+10), 30)];
        notificationMessage=[[UILabel alloc] initWithFrame:CGRectMake(notificationImage.frame.origin.x+notificationImage.frame.size.width+10, 35, [[UIScreen mainScreen] bounds].size.width-(notificationImage.frame.origin.x+notificationImage.frame.size.width+10)-10, 30)];
        
        notificationView.layer.masksToBounds=YES;
        notificationView.layer.cornerRadius=5;
        notificationView.backgroundColor=[UIColor colorWithWhite:0 alpha:0.7];
        
        notificationImage.layer.masksToBounds=YES;
        notificationImage.layer.cornerRadius=20;
        notificationImage.contentMode=UIViewContentModeScaleToFill;
        
        notificationTitle.textAlignment=NSTextAlignmentLeft;
        notificationTitle.font=[UIFont boldSystemFontOfSize:16];
        notificationTitle.textColor=[UIColor whiteColor];
        
        notificationMessage.textAlignment=NSTextAlignmentLeft;
        notificationMessage.font=[UIFont systemFontOfSize:15];
        notificationMessage.textColor=[UIColor whiteColor];
        
        [notificationView addSubview:notificationImage];
        [notificationView addSubview:notificationTitle];
        [notificationView addSubview:notificationMessage];
        [[appDelegate window] addSubview:notificationView];
    });
}

- (void)showNotificationViewWithAnimation:(NSString *)userId alertTitle:(NSString *)alertTitle alertMessage:(NSString *)alertMessage {

//    [window bringSubviewToFront:notificationView];
    
    notificationTitle.text=alertTitle;
    notificationMessage.text=alertMessage;
        NSData *tempImageData=[self listionDataFromCacheDirectoryFolderName:appProfilePhotofolderName jid:userId];
        if (nil!=tempImageData) {
            notificationImage.image=[UIImage imageWithData:tempImageData];
        }
        else {
            notificationImage.image=[UIImage imageNamed:@"images.png"];
        }
    
    [UIView animateWithDuration:0.2f animations:^{
        //To Frame
       notificationView.frame=CGRectMake(3, 5, [[UIScreen mainScreen] bounds].size.width-6, 80);
    } completion:^(BOOL completed) {
        
        [self hideNotificationViewWithAnimation];
    }];
}

- (void)hideNotificationViewWithAnimation {
    
    [UIView animateWithDuration:0.2
                          delay:2.0
                        options: UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{ // anything animatable
                         notificationView.frame=CGRectMake(3, -90, [[UIScreen mainScreen] bounds].size.width-6, 80);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - Background/Foreground/Termination mode XMPP coding
- (void)enterBackgroundMethod :(UIApplication *)application {
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
}

- (void)enterForegroundMethod :(UIApplication *)application {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)enterTerminationMethod :(UIApplication *)application {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self teardownStream];
    [self saveContext];
}
#pragma mark - end

#pragma mark - XMPP framework chat code

- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}

- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
//    xmppMessageDeliveryRecipts = [[XMPPMessageDeliveryReceipts alloc] initWithDispatchQueue:dispatch_get_main_queue()];
//    xmppMessageDeliveryRecipts.autoSendMessageDeliveryReceipts = YES;
//    xmppMessageDeliveryRecipts.autoSendMessageDeliveryRequests = YES;
//    [xmppMessageDeliveryRecipts activate:xmppStream];
    
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [xmppStream setHostName:hostName];
    [xmppStream setHostPort:portNumber];
    
    customCertEvaluation = YES;
}

- (void)teardownStream
{
    [xmppStream removeDelegate:self];
    [xmppRoster removeDelegate:self];
    
    [xmppReconnect         deactivate];
    [xmppRoster            deactivate];
    [xmppvCardTempModule   deactivate];
    [xmppvCardAvatarModule deactivate];
    [xmppCapabilities      deactivate];
    
    [xmppStream disconnect];
    
    xmppStream = nil;
    xmppReconnect = nil;
    xmppRoster = nil;
    xmppRosterStorage = nil;
    xmppvCardStorage = nil;
    xmppvCardTempModule = nil;
    xmppvCardAvatarModule = nil;
    xmppCapabilities = nil;
    xmppCapabilitiesStorage = nil;
}

- (void)goOnline
{
//    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    presencexmpp = [XMPPPresence presence];
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"]  || [domain isEqualToString:hostName])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presencexmpp addChild:priority];
    }
    
    [[self xmppStream] sendElement:presencexmpp];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}
#pragma mark - end

#pragma mark - Connect/disconnect user
- (BOOL)connect
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    NSString *myJID = [XMPPUserDefaultManager getValue:@"LoginCred"];
    NSString *myPassword = [XMPPUserDefaultManager getValue:@"PassCred"];
    
    if (myJID == nil || myPassword == nil)
    {
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    xmppPassword = myPassword;
    
    //Added by rohit File transfer
    xmppIncomingFileTransfer = [XMPPIncomingFileTransfer new];
    xmppIncomingFileTransfer.disableIBB = NO;
    xmppIncomingFileTransfer.disableSOCKS5 = YES;
//     xmppIncomingFileTransfer.disableDirectTransfers = YES;
    xmppIncomingFileTransfer.autoAcceptFileTransfers=YES;
    // Activate all modules
    [xmppRoster activate:xmppStream];
    [xmppIncomingFileTransfer activate:xmppStream];
    
    // Add ourselves as delegate to necessary methods
    [xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //end
    
    
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        DDLogError(@"Error connecting: %@", error);
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
}
#pragma mark - end

#pragma mark - XMPPStream Delegate
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *expectedCertName = [xmppStream.myJID domain];
    if (expectedCertName)
    {
        [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
    }
    
    if (customCertEvaluation)
    {
        [settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    isXmppConnected = YES;
    
    NSError *error = nil;
    
    if (![[self xmppStream] authenticateWithPassword:xmppPassword error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    if (myDelegate.afterAutentication==1) {
         myDelegate.afterAutentication=2;
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
    
    if ([xmppStream isAuthenticated]) {
        
        NSLog(@"authenticated");
        if (nil!=xmppLogedInUserId&&![xmppLogedInUserId isEqualToString:@""]) {
//             [xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:xmppLogedInUserId] ignoreStorage:YES];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPDidAuthenticatedResponse" object:nil];
    }
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule{
    NSLog(@"succes");
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error{
    NSLog(@"fail");
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    if (myDelegate.afterAutentication==1) {
        
        myDelegate.afterAutentication=2;
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPDidNotAuthenticatedResponse" object:nil];

    }
}

-(void)fetchRosterListWithUserId:(NSString *)userId // yourID
{
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    XMPPIQ *iq = [XMPPIQ iq];
    [iq addAttributeWithName:@"id" stringValue:@"14z2as5a236ew"];
    [iq addAttributeWithName:@"to" stringValue:userId];
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    [iq addChild:query];
    [xmppStream sendElement:iq];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSXMLElement *queryElement = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    NSXMLElement *vcardInfo = [iq elementForName:@"vCard"];
    
    NSString *groupChat = [[iq attributeForName:@"id"] stringValue];
    NSXMLElement *storageElement=[NSXMLElement elementWithName:@"query" xmlns:@"storage:bookmarks"];
    if (nil!=storageElement) {
        NSLog(@"%@",[storageElement attributeStringValueForName:@"xmlns"]);
    }
    if (nil!=groupChat&&NULL!=groupChat&&[groupChat containsString:@"BookMarkManager"]) {
        
            NSLog(@"Bookmarks with id %@ succesfully uploaded", [iq attributeStringValueForName:@"id"]);
        
        
//        [[[groupChat componentsSeparatedByString:@"@"] objectAtIndex:1] isEqualToString:conferenceServerJid]
//        <iq xmlns="jabber:client" type="result" id="47ACF5E7-F088-4053-BE0D-4F96469A6557" from="010317094630@conference.192.168.18.171" to="1111111111@192.168.18.171//Smack"></iq>
//        [self getGroupChatInformation:iq];
    }
    else if (nil!=storageElement&&NULL!=storageElement) {
    
        NSMutableArray *itemElements=[[[[iq elementForName:@"query"] elementForName:@"storage"] elementsForName:@"conference"] mutableCopy];
        if (itemElements) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPFetchBookmarktList" object:itemElements];
        }
        
    }
    else {
        //Insert/Update users data in local storage
        if (vcardInfo!=nil) {
            NSXMLElement *registerUserInfo = [vcardInfo elementForName:@"RegisterUserId"];
            if (registerUserInfo!=nil) {
                NSLog(@"%@",[registerUserInfo stringValue]);
                [[XmppCoreDataHandler sharedManager] insertEntryInXmppUserModel:[registerUserInfo stringValue] xmppName:[[vcardInfo elementForName:@"NICKNAME"] stringValue] xmppPhoneNumber:[[vcardInfo elementForName:@"TEL"] stringValue] xmppUserStatus:[[vcardInfo elementForName:@"USERSTATUS"] stringValue] xmppDescription:[[vcardInfo elementForName:@"DESC"] stringValue] xmppAddress:[[vcardInfo elementForName:@"ADDRESS"] stringValue] xmppEmailAddress:[[vcardInfo elementForName:@"EMAILADDRESS"] stringValue] xmppUserBirthDay:[[vcardInfo elementForName:@"BDAY"] stringValue] xmppGender:[[vcardInfo elementForName:@"GENDER"] stringValue]];
                if (isContactListIsLoaded && xmppUserListArray!=nil) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPProfileUpdation" object:nil];
                }
            }
        }
        
        //New user entry in local storage
        NSXMLElement *addQueryElement = [iq elementForName:@"query"];
        if (addQueryElement!=nil) {
            NSXMLElement *removeitemElement = [addQueryElement elementForName:@"item"];
            if (removeitemElement!=nil) {
                NSString *addSubscriptionElement = [[removeitemElement attributeForName:@"subscription"] stringValue];
                NSString *addSetAttribut = [[iq attributeForName:@"type"] stringValue];
                if ((addSubscriptionElement!=nil)&&[addSubscriptionElement isEqualToString:@"both"]&&[addSetAttribut isEqualToString:@"set"]) {
                    [[XmppCoreDataHandler sharedManager] insertNewUserEntryInXmppUserModel:[[removeitemElement attributeForName:@"jid"] stringValue] xmppName:[[removeitemElement attributeForName:@"name"] stringValue] xmppPhoneNumber:@"" xmppUserStatus:@"" xmppDescription:@"" xmppAddress:@"" xmppEmailAddress:@"" xmppUserBirthDay:@"" xmppGender:@""];
                }
            }
        }
        
        //Remove user entry if it is deleted
        NSXMLElement *removeQueryElement = [iq elementForName:@"query"];
        if (removeQueryElement!=nil) {
            NSXMLElement *removeitemElement = [removeQueryElement elementForName:@"item"];
            if (removeitemElement!=nil) {
                NSString *removeSubscriptionElement = [[removeitemElement attributeForName:@"subscription"] stringValue];
                if ((removeSubscriptionElement!=nil)&&[removeSubscriptionElement isEqualToString:@"remove"]) {
                    [[XmppCoreDataHandler sharedManager] deleteDataModelEntry:[[removeitemElement attributeForName:@"jid"] stringValue]];
                }
            }
        }
        //end
    }
    if (queryElement) {
        NSArray *itemElements = [queryElement elementsForName: @"item"];
        NSMutableArray *mArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[itemElements count]; i++) {
            
            NSString *jid=[[[itemElements objectAtIndex:i] attributeForName:@"jid"] stringValue];
            [mArray addObject:jid];
        }
    }
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if ([message isChatMessageWithBody])
    {
        XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[message from]
                                                                 xmppStream:xmppStream
                                                       managedObjectContext:[self managedObjectContext_roster]];
        NSLog(@"%@",user);
        
        NSXMLElement *innerElementData = [message elementForName:@"data"];
        [[XmppCoreDataHandler sharedManager] insertLocalMessageStorageDataBase:[innerElementData attributeStringValueForName:@"from"] message:message];
        if (![selectedFriendUserId isEqualToString:[innerElementData attributeStringValueForName:@"from"]]){
            
            [self addLocalNotification:[innerElementData attributeStringValueForName:@"senderName"] message:[[message elementForName:@"body"] stringValue] userId:[innerElementData attributeStringValueForName:@"from"]];
            [XMPPUserDefaultManager setXMPPBadgeIndicatorKey:[innerElementData attributeStringValueForName:@"from"]];
        }
        else if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateBackground) {
            [self addLocalNotification:[innerElementData attributeStringValueForName:@"senderName"] message:[[message elementForName:@"body"] stringValue] userId:[innerElementData attributeStringValueForName:@"from"]];
        }
//        else {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"UserHistory" object:message];
//        }
        
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    
    NSString *presenceType = [presence type];
    if  ([presenceType isEqualToString:@"subscribe"]) {
        
        [xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
    }
    NSLog(@" Printing full jid of user %@",presence);
    NSLog(@" Printing full jid of user %@",[[sender myJID] full]);
    NSLog(@"Printing full jid of user %@",[[sender myJID] resource]);
    NSLog(@"From user %@",[[presence from] full]);
     NSLog(@"From user %@",presenceType);
    NSLog(@"From user %@",[[[NSString stringWithFormat:@"%@",[presence from]] componentsSeparatedByString:@"/"] objectAtIndex:0]);

//    int myCount = [[XMPPUserDefaultManager getValue:@"CountValue"] intValue];
    
    
    if (isContactListIsLoaded && xmppUserListArray!=nil && [NSString stringWithFormat:@"%@",[presence from]]!=nil && [xmppUserListArray containsObject:[[[NSString stringWithFormat:@"%@",[presence from]] componentsSeparatedByString:@"/"] objectAtIndex:0]] && [selectedFriendUserId isEqualToString:[[[NSString stringWithFormat:@"%@",[presence from]] componentsSeparatedByString:@"/"] objectAtIndex:0]]) {
        
//        switch (section)
//        {
//            case 0  :
//                label.text = @"Available";
//                label.textColor=[UIColor colorWithRed:13.0/255.0 green:213.0/255.0 blue:178.0/255.0 alpha:1.0];
//                break;
//            case 1  :
//                label.text =  @"Away";
//                label.textColor=[UIColor yellowColor];
//                break;
//            default :
//                label.text =  @"Offline";
//                label.textColor=[UIColor redColor];
//                break;
//        }
        
         XMPPUserCoreDataStorageObject *user=[xmppUserDetailedList objectForKey:[[[NSString stringWithFormat:@"%@",[presence from]] componentsSeparatedByString:@"/"] objectAtIndex:0]];
        if ([presenceType isEqualToString:@"available"]) {
            user.sectionNum=[NSNumber numberWithInt:0];
        }
        else {
            user.sectionNum=[NSNumber numberWithInt:2];
        }
        //Send presence status and set at particular jid in xmppUserDetailedList key
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XmppUserPresenceUpdate" object:nil];
    }
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Registration Successful!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
    if (afterAutenticationRegistration==0) {
        afterAutenticationRegistration=1;
        NSMutableDictionary *registerSuccessDict=[NSMutableDictionary new];
        [registerSuccessDict setObject:@"1" forKey:@"Status"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPDidRegisterResponse" object:registerSuccessDict];
    }
    
}


- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    
    if (afterAutenticationRegistration==0) {
        afterAutenticationRegistration=1;
    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
    
//    NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Failed!" message:regError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    NSMutableDictionary *registerFailureDict=[NSMutableDictionary new];
    [registerFailureDict setObject:@"0" forKey:@"Status"];
    [registerFailureDict setObject:errorCode forKey:@"ErrorCode"];
    [registerFailureDict setObject:error.description forKey:@"ErrorMessage"];
    if([errorCode isEqualToString:@"409"]){
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPDidNotRegisterResponse" object:[NSNumber numberWithInt:XMPP_UserExist]];
        
    }
    else if([errorCode isEqualToString:@"500"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPDidNotRegisterResponse" object:[NSNumber numberWithInt:XMPP_InvalidUserName]];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPDidNotRegisterResponse" object:[NSNumber numberWithInt:XMPP_UserExist]];
    }
    }
}

-(void)methodCalling:(NSMutableDictionary *)profileData {
    
    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
    NSData *pictureData;
    if (nil!=self.userProfileImageDataValue) {
        
//        pictureData = UIImageJPEGRepresentation([UIImage imageWithData:self.userProfileImageDataValue], imageCompressionPercent);
        pictureData=[self reducedImageSize:[UIImage imageWithData:self.userProfileImageDataValue]];
        [newvCardTemp setPhoto:pictureData];
    }

    /*//Other variables
    [newvCardTemp setNickname:@"aaaaaa"];
    NSArray *interestsArray= [[NSArray alloc] initWithObjects:@"food", nil];
    [newvCardTemp setLabels:interestsArray];
    [newvCardTemp setMiddleName:@"Stt"];
    [newvCardTemp setUserStatus:@"I am available"];
    [newvCardTemp setAddress:@"rohitm@ranosys.com"];
    [newvCardTemp setEmailAddresses:[NSMutableArray arrayWithObjects:@"rohitmodi@ranosys.com",@"rohitm@ranosys.com", nil]];
     */
    
    [newvCardTemp setRegisterUserId:[self setProfileDataValue:profileData key:@"xmppRegisterId"]];
    [newvCardTemp setNickname:[self setProfileDataValue:profileData key:@"xmppName"]];
    [newvCardTemp setTelecomsAddress:[self setProfileDataValue:profileData key:@"xmppPhoneNumber"]];
    [newvCardTemp setUserStatus:[self setProfileDataValue:profileData key:@"xmppUserStatus"]];
//    [newvCardTemp setUserStatus:@"old status"];
    [newvCardTemp setDesc:[self setProfileDataValue:profileData key:@"xmppDescription"]];
    [newvCardTemp setAddress:[self setProfileDataValue:profileData key:@"xmppAddress"]];
    [newvCardTemp setEmailAddress:[self setProfileDataValue:profileData key:@"xmppEmailAddress"]];
    [newvCardTemp setBday:[self setProfileDataValue:profileData key:@"xmppUserBirthDay"]];
    [newvCardTemp setGender:[self setProfileDataValue:profileData key:@"xmppGender"]];
    
    [xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
}




- (NSData*)reducedImageSize:(UIImage *)selectedImage {
    
    NSData *imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(selectedImage, 1)];
    
//    int imageSize = imageData.length;
//    NSLog(@"SIZE OF IMAGE: %.2f", (float)imageSize/1024/1024);
    
    selectedImage = [self imageWithRoundedCornersSize:0 usingImage:selectedImage];
    
    imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(selectedImage, 1)];
    
//    imageSize = imageData.length;
//    NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)imageSize/1024/1024);
    CGSize mySize;
//    mySize.height = 512;
//    mySize.width = 512;

    mySize.height = 256;
    mySize.width = 256;
    
    CGFloat oldWidth = selectedImage.size.width;
    CGFloat oldHeight = selectedImage.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? mySize.width / oldWidth : mySize.height / oldHeight;
    
    
    mySize.height = oldHeight * scaleFactor;
    mySize.width = oldWidth * scaleFactor;
    
    
    selectedImage = [self imageWithImage:selectedImage scaledToSize:mySize];
    
    
    NSData *pngData = UIImageJPEGRepresentation(selectedImage, .1);
//    imageSize = pngData.length;
//    NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)imageSize/1024/1024);
//    UIImage *im=[UIImage imageWithData:pngData];
    return pngData;
}

- (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original
{
    CGRect frame = CGRectMake(0, 0, original.size.width, original.size.height);
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(original.size, NO, 1.0);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:cornerRadius] addClip];
    // Draw your image
    [original drawInRect:frame];
    
    // Get the image, here setting the UIImageView image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (NSString *)setProfileDataValue:(NSMutableDictionary *)profileData key:(NSString *)key {

    NSString *value=@"";
    if (nil!=[profileData objectForKey:key]||NULL!=[profileData objectForKey:key]||([[profileData objectForKey:key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0)) {
        
        value=[[profileData objectForKey:key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return value;
}

- (NSString *)checkNilValue:(id)checkValue {
    
    NSString *value=@"";
    if (nil!=checkValue||NULL!=checkValue||([checkValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0)) {
        
        value=[checkValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return value;
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    NSLog(@"a");
}

-(void)editProfileImageUploading:(NSMutableDictionary *)profileData {
    
    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
    NSData *pictureData;
    if (nil!=self.userProfileImageDataValue) {
        
//        pictureData = UIImageJPEGRepresentation([UIImage imageWithData:self.userProfileImageDataValue], imageCompressionPercent);
        pictureData = [self reducedImageSize:[UIImage imageWithData:self.userProfileImageDataValue]];
        [newvCardTemp setPhoto:pictureData];
    }
    NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)pictureData.length/1024/1024);

    
    /*//Other variables
     [newvCardTemp setNickname:@"aaaaaa"];
     NSArray *interestsArray= [[NSArray alloc] initWithObjects:@"food", nil];
     [newvCardTemp setLabels:interestsArray];
     [newvCardTemp setMiddleName:@"Stt"];
     [newvCardTemp setUserStatus:@"I am available"];
     [newvCardTemp setAddress:@"rohitm@ranosys.com"];
     [newvCardTemp setEmailAddresses:[NSMutableArray arrayWithObjects:@"rohitmodi@ranosys.com",@"rohitm@ranosys.com", nil]];
     */
    
    [newvCardTemp setRegisterUserId:[self setProfileDataValue:profileData key:@"xmppRegisterId"]];
    [newvCardTemp setNickname:[self setProfileDataValue:profileData key:@"xmppName"]];
    [newvCardTemp setTelecomsAddress:[self setProfileDataValue:profileData key:@"xmppPhoneNumber"]];
    [newvCardTemp setUserStatus:[self setProfileDataValue:profileData key:@"xmppUserStatus"]];
    //    [newvCardTemp setUserStatus:@"old status"];
    [newvCardTemp setDesc:[self setProfileDataValue:profileData key:@"xmppDescription"]];
    [newvCardTemp setAddress:[self setProfileDataValue:profileData key:@"xmppAddress"]];
    [newvCardTemp setEmailAddress:[self setProfileDataValue:profileData key:@"xmppEmailAddress"]];
    [newvCardTemp setBday:[self setProfileDataValue:profileData key:@"xmppUserBirthDay"]];
    [newvCardTemp setGender:[self setProfileDataValue:profileData key:@"xmppGender"]];
    
    [xmppvCardTempModule updateMyvCardTemp:newvCardTemp];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
    }
}
#pragma mark - end

#pragma mark - XMPPRosterDelegate

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *user = [xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [[[user displayName] componentsSeparatedByString:@"@52.74.174.129@"] objectAtIndex:0];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:jidStrBare
                                                            message:body
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"OK";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
//    if ([myDelegate.myView isEqualToString:@"DashboardXmppUserList"]) {
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPUserListResponse" object:nil];
//    }
}
#pragma mark - end

#pragma mark - Core Data stack
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"XmppStorageModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSLog(@"%@",[self applicationDocumentsDirectory]);
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"xmppUserDemo.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"XmppStorageModel"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

//Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}
#pragma mark - end

#pragma mark - Image save in cache
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)applicationCacheDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (void)createCacheDirectory {
    
    [self createCacheDirectory:folderName];
    [self createCacheDirectory:appMediafolderName];
    [self createCacheDirectory:appProfilePhotofolderName];
    [self createCacheDirectory:appSentReceivePhotofolderName];
    [self createCacheDirectory:appDocumentfolderName];
    [self createCacheDirectory:appMapPhotofolderName];
}

- (void)createCacheDirectory:(NSString *)FolderName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folderPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:FolderName];
    if (![fileManager fileExistsAtPath:folderPath]) {
        
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)saveDataInCacheDirectory:(UIImage *)tempImage folderName:(NSString *)tempFolderName jid:(NSString *)jid {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imagesPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:tempFolderName];
    if (![fileManager fileExistsAtPath:imagesPath]) {
        
        [fileManager createDirectoryAtPath:imagesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [imagesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.jpeg",folderName,[[jid componentsSeparatedByString:@"@"] objectAtIndex:0]]];
    NSData * imageData = UIImageJPEGRepresentation(tempImage, 1.0);
    [imageData writeToFile:filePath atomically:YES];
}

- (NSData *)listionDataFromCacheDirectoryFolderName:(NSString *)tempFolderName jid:(NSString *)jid {
    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:tempFolderName];
    NSString *fileAtPath = [filePath stringByAppendingString:[NSString stringWithFormat:@"/%@_%@.jpeg",folderName,[[jid componentsSeparatedByString:@"@"] objectAtIndex:0]]];
    NSError* error = nil;
    return [NSData dataWithContentsOfFile:fileAtPath options:0 error:&error];
}
#pragma mark - end

#pragma mark - Save send/Receive Images 
- (NSString *)setOtherImageInLocalDB:(UIImage*)image {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpeg",folderName,datestr];
    [self saveImageInLocalDocumentDirectory:fileName image:[self sendReceiveReducedImageSize:image]];
    return fileName;
}

- (void)saveImageInLocalDocumentDirectory:(NSString *)fileName image:(NSData *)imageData {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imagesPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:appSentReceivePhotofolderName];
    if (![fileManager fileExistsAtPath:imagesPath]) {
        
        [fileManager createDirectoryAtPath:imagesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    imagesPath=[imagesPath stringByAppendingPathComponent:fileName];
    NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)imageData.length/1024/1024);
    [imageData writeToFile:imagesPath atomically:YES];
}

- (NSData *)listionSendAttachedImageCacheDirectoryFileName:(NSString *)fileName {
    
    NSString *filePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:appSentReceivePhotofolderName];
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    NSError* error = nil;
    return [NSData dataWithContentsOfFile:fileAtPath options:0 error:&error];
}

- (NSData*)sendReceiveReducedImageSize:(UIImage *)selectedImage {
    
    NSData *imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(selectedImage, 1)];
    
//        int imageSize = imageData.length;
//        NSLog(@"SIZE OF IMAGE: %.2f", (float)imageSize/1024/1024);
    
    selectedImage = [self imageWithRoundedCornersSize:0 usingImage:selectedImage];
    
    imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(selectedImage, 1)];
    
//        imageSize = imageData.length;
//        NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)imageSize/1024/1024);
    CGSize mySize;
    mySize.height = 200;
    mySize.width = 200;
    
    CGFloat oldWidth = selectedImage.size.width;
    CGFloat oldHeight = selectedImage.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? mySize.width / oldWidth : mySize.height / oldHeight;
    
    
    mySize.height = oldHeight * scaleFactor;
    mySize.width = oldWidth * scaleFactor;
    
    
    selectedImage = [self imageWithImage:selectedImage scaledToSize:mySize];
    
    
    NSData *pngData = UIImageJPEGRepresentation(selectedImage, .1);
    //    imageSize = pngData.length;
    //    NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)imageSize/1024/1024);
    //    UIImage *im=[UIImage imageWithData:pngData];
    return pngData;
}
#pragma mark - end

- (NSData *)listionSendAttachedLocationImageCacheDirectoryFileName:(NSString *)fileName {
    
    NSString *filePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:appMapPhotofolderName];
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    NSError* error = nil;
    return [NSData dataWithContentsOfFile:fileAtPath options:0 error:&error];
}

- (NSData*)reducedLocationImageSize:(UIImage *)selectedImage {
    
    NSData *imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(selectedImage, 1)];
    selectedImage = [self imageWithRoundedCornersSize:0 usingImage:selectedImage];
    
    imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(selectedImage, 1)];
    CGSize mySize;
    mySize.height = 100;
    mySize.width = 100;
    
    CGFloat oldWidth = selectedImage.size.width;
    CGFloat oldHeight = selectedImage.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? mySize.width / oldWidth : mySize.height / oldHeight;
    mySize.height = oldHeight * scaleFactor;
    mySize.width = oldWidth * scaleFactor;
    selectedImage = [self imageWithImage:selectedImage scaledToSize:mySize];
    NSData *pngData = UIImageJPEGRepresentation(selectedImage, .1);
    return pngData;
}

- (NSString *)setMapImageInLocalDB:(UIImage*)image {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"Map_%@.jpeg",datestr];
    [self saveMapImageInLocalDocumentDirectory:fileName image:[self reducedLocationImageSize:image]];
    return fileName;
}

- (void)saveMapImageInLocalDocumentDirectory:(NSString *)fileName image:(NSData *)imageData {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imagesPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:appMapPhotofolderName];
    if (![fileManager fileExistsAtPath:imagesPath]) {
        
        [fileManager createDirectoryAtPath:imagesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    imagesPath=[imagesPath stringByAppendingPathComponent:fileName];
    NSLog(@"SIZE OF IMAGE: %.3f Mb", (float)imageData.length/1024/1024);
    [imageData writeToFile:imagesPath atomically:YES];
}

//File transfer
#pragma mark - XMPPIncomingFileTransferDelegate Methods

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
                didFailWithError:(NSError *)error
{
    DDLogVerbose(@"%@: Incoming file transfer failed with error: %@", THIS_FILE, error);
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
               didReceiveSIOffer:(XMPPIQ *)offer
{
    DDLogVerbose(@"%@: Incoming file transfer did receive SI offer. Accepting...", THIS_FILE);
    [sender acceptSIOffer:offer];
}

//- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
//              didSucceedWithData:(NSData *)data
//                           named:(NSString *)name
//{
//    DDLogVerbose(@"%@: Incoming file transfer did succeed.", THIS_FILE);
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                         NSUserDomainMask,
//                                                         YES);
//    NSString *fullPath = [[paths lastObject] stringByAppendingPathComponent:name];
//    [data writeToFile:fullPath options:0 error:nil];
//    
//    DDLogVerbose(@"%@: Data was written to the path: %@", THIS_FILE, fullPath);
//}

- (void)xmppIncomingFileTransferWithDesc:(XMPPIncomingFileTransfer *)sender
                      didSucceedWithData:(NSData *)data
                                   named:(NSString *)name desc:(NSString *)desc date:(NSString *)date time:(NSString *)time to:(NSString *)to from:(NSString *)from senderName:(NSString *)senderName receiverName:(NSString *)receiverName chatType:(NSString *)chatType {
    
    DDLogVerbose(@"%@: Incoming file transfer did succeed.", THIS_FILE);
    NSLog(@"%@",desc);
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
    //                                                         NSUserDomainMask,
    //                                                         YES);
    //    NSString *fullPath = [[paths lastObject] stringByAppendingPathComponent:name];
    //    [data writeToFile:fullPath options:0 error:nil];
    //    saveFileInLocalDocumentDirectory
    
    NSXMLElement *messageData=[self convertedMessage:name date:date time:time to:to from:from senderName:senderName receiverName:receiverName messageString:desc chatType:chatType];
    if (![[XmppCoreDataHandler sharedManager] isFileMessageExist:[NSString stringWithFormat:@"%@",messageData]]) {
        
        NSXMLElement *innerElementData = [messageData elementForName:@"data"];
        
        if ([[innerElementData attributeStringValueForName:@"chatType"] isEqualToString:@"ImageAttachment"]) {
            [self saveImageInLocalDocumentDirectory:name image:data];
        }
        else if ([[innerElementData attributeStringValueForName:@"chatType"] isEqualToString:@"FileAttachment"]) {
            [self saveFileInLocalDocumentDirectory:name file:data];
        }
        [[XmppCoreDataHandler sharedManager] insertLocalMessageStorageDataBase:[innerElementData attributeStringValueForName:@"from"] message:messageData];
        
        if (![selectedFriendUserId isEqualToString:[innerElementData attributeStringValueForName:@"from"]]){
            
            if ([[innerElementData attributeStringValueForName:@"chatType"] isEqualToString:@"ImageAttachment"]) {
                [self addLocalNotification:senderName message:@"Image" userId:[innerElementData attributeStringValueForName:@"from"]];
            }
            else if ([[innerElementData attributeStringValueForName:@"chatType"] isEqualToString:@"FileAttachment"]) {
                [self addLocalNotification:senderName message:@"File" userId:[innerElementData attributeStringValueForName:@"from"]];
            }
            [XMPPUserDefaultManager setXMPPBadgeIndicatorKey:[innerElementData attributeStringValueForName:@"from"]];
            
        }
        else if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateBackground) {
            if ([[innerElementData attributeStringValueForName:@"chatType"] isEqualToString:@"ImageAttachment"]) {
                [self addLocalNotification:senderName message:@"Image" userId:[innerElementData attributeStringValueForName:@"from"]];
            }
            else if ([[innerElementData attributeStringValueForName:@"chatType"] isEqualToString:@"FileAttachment"]) {
                [self addLocalNotification:senderName message:@"File" userId:[innerElementData attributeStringValueForName:@"from"]];
            }
        }

//        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserHistory" object:messageData];
//        }
    }
    //    DDLogVerbose(@"%@: Data was written to the path: %@", THIS_FILE, fullPath);
    
}

- (NSXMLElement *)convertedMessage:(NSString *)imageName date:(NSString *)date time:(NSString *)time to:(NSString *)to from:(NSString *)from senderName:(NSString *)senderName receiverName:(NSString *)receiverName messageString:(NSString *)messageString chatType:(NSString *)chatType {
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    
    [body setStringValue:messageString];
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    NSXMLElement *dataTag = [NSXMLElement elementWithName:@"data"];
    
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:to];
    [message addAttributeWithName:@"from" stringValue:from];
    [message addAttributeWithName:@"progress" stringValue:@"1"];
    
    [dataTag addAttributeWithName:@"xmlns" stringValue:@"main"];
    [dataTag addAttributeWithName:@"chatType" stringValue:chatType];
    
    [dataTag addAttributeWithName:@"to" stringValue:to];
    [dataTag addAttributeWithName:@"fileName" stringValue:imageName];
    
    [dataTag addAttributeWithName:@"from" stringValue:from];
    [dataTag addAttributeWithName:@"time" stringValue:time];
    //        [message addAttributeWithName:@"Name" stringValue:[UserDefaultManager getValue:@"userName"]];
    [dataTag addAttributeWithName:@"date" stringValue:date];
    //        [message addAttributeWithName:@"from-To" stringValue:[NSString stringWithFormat:@"%@-%@",myDelegate.xmppLogedInUserId,friendUserJid]];
    [dataTag addAttributeWithName:@"senderName" stringValue:senderName];
    [dataTag addAttributeWithName:@"receiverName" stringValue:receiverName];
    //    }
    [message addChild:dataTag];
    [message addChild:body];
    return message;
}

- (void)addLocalNotification:(NSString *)title message:(NSString *)message userId:(NSString *)userId {
    
    [self showNotificationViewWithAnimation:userId alertTitle:title alertMessage:message];
    
////    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
////    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
////    localNotification.alertBody = @"Your alert message";
////    localNotification.timeZone = [NSTimeZone defaultTimeZone];
////    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//    
//    
////    NSData *tempImageData=[self listionDataFromCacheDirectoryFolderName:appProfilePhotofolderName jid:userId];
////    if (nil!=tempImageData) {
////        notification.alertLaunchImage=[UIImage imageWithData:tempImageData];
////    }
////    else {
////        
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    notification.alertBody = message;
    notification.alertTitle=title;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 0;
//    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"You have notification(s) pending!"] forKey:@"userInfo"];
//    notification.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//
////    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
////    content.title = [NSString localizedUserNotificationStringForKey:@"Hello!" arguments:nil];
////    content.body = [NSString localizedUserNotificationStringForKey:@"Hello_message_body"
////                                                         arguments:nil];
////    content.sound = [UNNotificationSound defaultSound];
////    
////    // Deliver the notification in five seconds.
////    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
////                                                  triggerWithTimeInterval:5 repeats:NO];
////    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
////                                                                          content:content trigger:trigger];
////    
////    // Schedule the notification.
////    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
//////    [center addNotificationRequest:request completionHandler:nil];
////    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
////        if (error != nil) {
////            NSLog(@"Something went wrong: %@",error);
////        }
////    }];

}

- (void)getAllDocumentListing:(void(^)(NSMutableArray *tempArray))completion {
    
    dispatch_queue_t queue = dispatch_queue_create("documentQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^
                   {
                       NSMutableArray *tempArray=[NSMutableArray new];
                       
                       NSError *error;
                       NSFileManager* fileManager = [NSFileManager defaultManager];
                       NSString *documentsDirectory = [[self applicationCacheDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",self.appDocumentfolderName]];
                       tempArray = [[fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error] mutableCopy];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           completion(tempArray);
                       });
                   });
}

- (NSData *)documentCacheDirectoryFileName:(NSString *)fileName {
    
    NSString *filePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:appDocumentfolderName];
    NSString *fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    NSError* error = nil;
    return [NSData dataWithContentsOfFile:fileAtPath options:0 error:&error];
}

- (NSString *)documentCacheDirectoryPathFileName:(NSString *)fileName {
    
    NSString *filePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:appDocumentfolderName];
    return [filePath stringByAppendingPathComponent:fileName];
}

- (void)saveFileInLocalDocumentDirectory:(NSString *)fileName file:(NSData *)fileData {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:appDocumentfolderName];
    if (![fileManager fileExistsAtPath:filePath]) {
        
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    filePath=[filePath stringByAppendingPathComponent:fileName];
    [fileData writeToFile:filePath atomically:YES];
}

- (void)getThumbnailImagePDF:(NSString *)fileName result:(void(^)(UIImage *tempImage))completion {
    
    dispatch_queue_t queue = dispatch_queue_create("pdfQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^
                   {
                       NSURL* pdfFileUrl = [NSURL fileURLWithPath:[self documentCacheDirectoryPathFileName:fileName]];
                       
                       CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfFileUrl);
                       
                       CGPDFPageRef page = CGPDFDocumentGetPage(pdf, 0 + 1);
                       
                       CGRect aRect =CGRectMake(0, 0, 100, 100);
                       UIGraphicsBeginImageContext(aRect.size);
                       CGContextRef context = UIGraphicsGetCurrentContext();
                       UIImage* thumbnailImage;
                       
                       CGContextSaveGState(context);
                       CGContextTranslateCTM(context, 0.0, aRect.size.height);
                       CGContextScaleCTM(context, 1.0, -1.0);
                       
                       CGContextSetGrayFillColor(context, 1.0, 1.0);
                       CGContextFillRect(context, aRect);
                       
                       
                       CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, aRect, 0, true);
                       
                       CGContextConcatCTM(context, pdfTransform);
                       
                       CGContextDrawPDFPage(context, page);
                       
                       thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
                       
                       CGContextRestoreGState(context);
                       
                       UIGraphicsEndImageContext();
                       CGPDFDocumentRelease(pdf);
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           completion(thumbnailImage);
                       });
                   });
}

#pragma mark - Group chat
- (void)getGroupChatInformation:(XMPPIQ *)iq {

    NSXMLElement *queryElement = [iq elementForName:@"query"];
    if (queryElement!=nil) {
        NSArray *itemElements = [queryElement elementsForName: @"item"];
        NSMutableArray *mArray = [[NSMutableArray alloc] init];
        for (int i=0; i<[itemElements count]; i++) {
            
            NSString *jid=[[[itemElements objectAtIndex:i] attributeForName:@"jid"] stringValue];
            [mArray addObject:jid];
        }

    }
    
}
#pragma mark - end
@end
