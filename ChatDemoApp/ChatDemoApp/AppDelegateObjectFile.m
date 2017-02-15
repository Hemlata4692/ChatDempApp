//
//  AppDelegateObjectFile.m
//  ChatDemoApp
//
//  Created by Ranosys on 18/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "AppDelegateObjectFile.h"

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

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface AppDelegateObjectFile()

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

@synthesize portNumber, hostName, serverName, defaultPassword, xmppUniqueId;
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
@synthesize appSentPhotofolderName;
@synthesize appReceivePhotofolderName;
@synthesize appDocumentfolderName;
//end

@synthesize afterAutentication,afterAutenticationRegistration;

#pragma mark - Intialze XMPP connection
- (void)didFinishLaunchingMethod {

    isUpdatePofile=false;
    //Create cache folders
    folderName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    appMediafolderName=[NSString stringWithFormat:@"%@/%@_Media",folderName,folderName];
    appProfilePhotofolderName=[NSString stringWithFormat:@"%@/%@_ProfilePhotos",appMediafolderName,folderName];
    appSentPhotofolderName=[NSString stringWithFormat:@"%@/%@_Photos/%@_Sent",appMediafolderName,folderName,folderName];
    appReceivePhotofolderName=[NSString stringWithFormat:@"%@/%@_Photos/%@_Receive",appMediafolderName,folderName,folderName];
    appDocumentfolderName=[NSString stringWithFormat:@"%@/%@_Documents",folderName,folderName];
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
    
//    if (nil!=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PasswordRequired"] && NULL!=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PasswordRequired"] && ![[NSBundle mainBundle] objectForInfoDictionaryKey:@"PasswordRequired"]) {
        defaultPassword = @"password";
//    }
    
    xmppUniqueId=@"Zebra123456";
    userProfileImageData = [[UIImageView alloc] init];
    
    userHistoryArr = [NSMutableArray new];
    userProfileImage = [NSMutableDictionary new];
    
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
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
    if (([XMPPUserDefaultManager getValue:@"LoginCred"] != nil)) {
//        [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"zebra@%@",hostName] key:@"LoginCred"];
//        [XMPPUserDefaultManager setValue:@"password" key:@"PassCred"];
//        [self connect];
    }
//    else {
//    [self connect];
//    }
}
#pragma mark - end

#pragma mark - Background/Foreground/Termination mode XMPP coding
- (void)enterBackgroundMethod :(UIApplication *)application {
    //    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    //    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
#if TARGET_IPHONE_SIMULATOR
    DDLogError(@"The iPhone simulator does not process background network traffic. "
               @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
#endif
    
    if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)])
    {
        [application setKeepAliveTimeout:600 handler:^{
            
            DDLogVerbose(@"KeepAliveHandler");
            
            // Do other keep alive stuff here.
        }];
    }
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
    
    
    
    
    
    //File transfer
    
    
//    _fileTransfer = [[XMPPOutgoingFileTransfer alloc] initWithDispatchQueue:dispatch_get_main_queue()];
////    _fileTransfer.disableIBB = NO;
////    _fileTransfer.disableSOCKS5 = NO;
//    
//    [_fileTransfer activate:xmppStream];
//    [_fileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
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
//    if (nil!=[XMPPUserDefaultManager getValue:@"LoginCred"] && ![[XMPPUserDefaultManager getValue:@"LoginCred"] isEqualToString:[NSString stringWithFormat:@"zebra@%@",hostName]]) {
//    if (isRegisterCalled==0) {
//        isRegisterCalled=1;
         [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPDidNotAuthenticatedResponse" object:nil];
//    }
    
//    }
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
    if (vcardInfo!=nil) {
        NSXMLElement *registerUserInfo = [vcardInfo elementForName:@"RegisterUserId"];
        if (registerUserInfo!=nil) {
            NSLog(@"%@",[registerUserInfo stringValue]);
            [self insertEntryInXmppUserModel:[registerUserInfo stringValue] xmppName:[[vcardInfo elementForName:@"NICKNAME"] stringValue] xmppPhoneNumber:[[vcardInfo elementForName:@"TEL"] stringValue] xmppUserStatus:[[vcardInfo elementForName:@"USERSTATUS"] stringValue] xmppDescription:[[vcardInfo elementForName:@"DESC"] stringValue] xmppAddress:[[vcardInfo elementForName:@"ADDRESS"] stringValue] xmppEmailAddress:[[vcardInfo elementForName:@"EMAILADDRESS"] stringValue] xmppUserBirthDay:[[vcardInfo elementForName:@"BDAY"] stringValue] xmppGender:[[vcardInfo elementForName:@"GENDER"] stringValue]];
//            if (isContactListIsLoaded && xmppUserListArray!=nil && [selectedFriendUserId isEqualToString:[registerUserInfo stringValue]]) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPProfileUpdation" object:nil];
//            }
            if (isContactListIsLoaded && xmppUserListArray!=nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPProfileUpdation" object:nil];
            }
        }
    }
    
    NSXMLElement *addQueryElement = [iq elementForName:@"query"];
    if (addQueryElement!=nil) {
        NSXMLElement *removeitemElement = [addQueryElement elementForName:@"item"];
        if (removeitemElement!=nil) {
//            <iq xmlns="jabber:client" type="set" id="58-481" to="5555666664@192.168.1.171/6wwe5f57fz"><query xmlns="jabber:iq:roster"><item jid="1245217896@192.168.1.171" name="ros" subscription="both"><group>Ranosys</group></item></query></iq>
            NSString *addSubscriptionElement = [[removeitemElement attributeForName:@"subscription"] stringValue];
            NSString *addSetAttribut = [[iq attributeForName:@"type"] stringValue];
            if ((addSubscriptionElement!=nil)&&[addSubscriptionElement isEqualToString:@"both"]&&[addSetAttribut isEqualToString:@"set"]) {
                [self insertNewUserEntryInXmppUserModel:[[removeitemElement attributeForName:@"jid"] stringValue] xmppName:[[removeitemElement attributeForName:@"name"] stringValue] xmppPhoneNumber:@"" xmppUserStatus:@"" xmppDescription:@"" xmppAddress:@"" xmppEmailAddress:@"" xmppUserBirthDay:@"" xmppGender:@""];
            }
        }
    }
    
    NSXMLElement *removeQueryElement = [iq elementForName:@"query"];
    if (removeQueryElement!=nil) {
         NSXMLElement *removeitemElement = [removeQueryElement elementForName:@"item"];
        if (removeitemElement!=nil) {
            NSString *removeSubscriptionElement = [[removeitemElement attributeForName:@"subscription"] stringValue];
            if ((removeSubscriptionElement!=nil)&&[removeSubscriptionElement isEqualToString:@"remove"]) {
                [self deleteDataModelEntry:[[removeitemElement attributeForName:@"jid"] stringValue]];
            }
        }
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

- (void)deleteDataModelEntry:(NSString *)registredUserId {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSMutableArray *results = [[NSMutableArray alloc]init];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"xmppRegisterId == %@", registredUserId];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"UserEntry"];
    [fetchRequest setPredicate:pred];
    results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count > 0) {
        
        [context deleteObject:[results objectAtIndex:0]];
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        [self removeLocalUserChat:registredUserId];
        if (isContactListIsLoaded) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"XmppNewUserAdded" object:nil];
        }
    }
}

- (void)removeLocalUserChat:(NSString *)userId {

    //Remove local dataBase user chat
    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];
    
    NSEntityDescription *messageEntity = [storage messageEntity:moc];
    NSFetchRequest *fetchRequest1 = [[NSFetchRequest alloc] init];
    [fetchRequest1 setEntity:entityDescription];
    NSString *predicateFrmt = @"bareJidStr == %@";
    fetchRequest1.entity = messageEntity;
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFrmt, userId];
    fetchRequest1.predicate = predicate;
    NSArray *messages_new = [moc executeFetchRequest:fetchRequest1 error:&error];
    
    for (NSManagedObject *object in messages_new) {
        [moc deleteObject:object];
    }
    
    if (![moc save:&error])
    {
        NSLog(@"Error deleting movie, %@", [error userInfo]);
    }
    //end
}

- (void)insertNewUserEntryInXmppUserModel:(NSString *)registredUserId xmppName:(NSString *)xmppName xmppPhoneNumber:(NSString *)xmppPhoneNumber xmppUserStatus:(NSString *)xmppUserStatus xmppDescription:(NSString *)xmppDescription xmppAddress:(NSString *)xmppAddress xmppEmailAddress:(NSString *)xmppEmailAddress xmppUserBirthDay:(NSString *)xmppUserBirthDay xmppGender:(NSString *)xmppGender {
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSMutableArray *results = [[NSMutableArray alloc]init];
    NSPredicate *pred;
    
    pred = [NSPredicate predicateWithFormat:@"xmppRegisterId == %@", registredUserId];
    NSLog(@"predicate: %@",pred);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"UserEntry"];
    [fetchRequest setPredicate:pred];
    results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (results.count == 0) {
        NSManagedObject *xmppDataEntry = [NSEntityDescription insertNewObjectForEntityForName:@"UserEntry" inManagedObjectContext:context];
        [xmppDataEntry setValue:registredUserId forKey:@"xmppRegisterId"];
        [xmppDataEntry setValue:xmppName forKey:@"xmppName"];
        [xmppDataEntry setValue:xmppPhoneNumber forKey:@"xmppPhoneNumber"];
        [xmppDataEntry setValue:xmppUserStatus forKey:@"xmppUserStatus"];
        [xmppDataEntry setValue:xmppDescription forKey:@"xmppDescription"];
        [xmppDataEntry setValue:xmppAddress forKey:@"xmppAddress"];
        [xmppDataEntry setValue:xmppEmailAddress forKey:@"xmppEmailAddress"];
        [xmppDataEntry setValue:xmppUserBirthDay forKey:@"xmppUserBirthDay"];
        [xmppDataEntry setValue:xmppGender forKey:@"xmppGender"];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        [xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:registredUserId] ignoreStorage:YES];
        if (isContactListIsLoaded) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"XmppNewUserAdded" object:nil];
        }
    }
}

- (void)insertEntryInXmppUserModel:(NSString *)registredUserId xmppName:(NSString *)xmppName xmppPhoneNumber:(NSString *)xmppPhoneNumber xmppUserStatus:(NSString *)xmppUserStatus xmppDescription:(NSString *)xmppDescription xmppAddress:(NSString *)xmppAddress xmppEmailAddress:(NSString *)xmppEmailAddress xmppUserBirthDay:(NSString *)xmppUserBirthDay xmppGender:(NSString *)xmppGender {

    NSManagedObjectContext *context = [self managedObjectContext];
    NSMutableArray *results = [[NSMutableArray alloc]init];
    NSPredicate *pred;
    
    pred = [NSPredicate predicateWithFormat:@"xmppRegisterId == %@", registredUserId];
    NSLog(@"predicate: %@",pred);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"UserEntry"];
    [fetchRequest setPredicate:pred];
    results = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];

    if (results.count > 0) {
         NSManagedObject* xmppDataEntry = [results objectAtIndex:0];
        [xmppDataEntry setValue:registredUserId forKey:@"xmppRegisterId"];
        [xmppDataEntry setValue:xmppName forKey:@"xmppName"];
        [xmppDataEntry setValue:xmppPhoneNumber forKey:@"xmppPhoneNumber"];
        [xmppDataEntry setValue:xmppUserStatus forKey:@"xmppUserStatus"];
        [xmppDataEntry setValue:xmppDescription forKey:@"xmppDescription"];
        [xmppDataEntry setValue:xmppAddress forKey:@"xmppAddress"];
        [xmppDataEntry setValue:xmppEmailAddress forKey:@"xmppEmailAddress"];
        [xmppDataEntry setValue:xmppUserBirthDay forKey:@"xmppUserBirthDay"];
        [xmppDataEntry setValue:xmppGender forKey:@"xmppGender"];
        [context save:nil];
    } else {
        NSManagedObject *xmppDataEntry = [NSEntityDescription insertNewObjectForEntityForName:@"UserEntry" inManagedObjectContext:context];
        [xmppDataEntry setValue:registredUserId forKey:@"xmppRegisterId"];
        [xmppDataEntry setValue:xmppName forKey:@"xmppName"];
        [xmppDataEntry setValue:xmppPhoneNumber forKey:@"xmppPhoneNumber"];
        [xmppDataEntry setValue:xmppUserStatus forKey:@"xmppUserStatus"];
        [xmppDataEntry setValue:xmppDescription forKey:@"xmppDescription"];
        [xmppDataEntry setValue:xmppAddress forKey:@"xmppAddress"];
        [xmppDataEntry setValue:xmppEmailAddress forKey:@"xmppEmailAddress"];
        [xmppDataEntry setValue:xmppUserBirthDay forKey:@"xmppUserBirthDay"];
        [xmppDataEntry setValue:xmppGender forKey:@"xmppGender"];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
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
        
        
//        [message addAttributeWithName:@"fromTo" stringValue:[NSString stringWithFormat:@"%@-%@",[message attributeStringValueForName:@"to"],[[[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"] objectAtIndex:0]]];
        
        [xmppMessageArchivingCoreDataStorage archiveMessage:message outgoing:NO xmppStream:[self xmppStream]];
//        NSString *keyName = [[[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"] objectAtIndex:0];
//        if ([[XMPPUserDefaultManager getValue:@"CountData"] objectForKey:keyName] == nil) {
//            int tempCount = 1;
//            
//            NSMutableDictionary *tempDict = [[XMPPUserDefaultManager getValue:@"CountData"] mutableCopy];
//            [tempDict setObject:[NSString stringWithFormat:@"%d",tempCount] forKey:keyName];
//            [XMPPUserDefaultManager setValue:tempDict key:@"CountData"];
//        }
//        else{
//            int tempCount = [[[XMPPUserDefaultManager getValue:@"CountData"] objectForKey:keyName] intValue];
//            tempCount = tempCount + 1;
//            NSMutableDictionary *tempDict = [[XMPPUserDefaultManager getValue:@"CountData"] mutableCopy];
//            [tempDict setObject:[NSString stringWithFormat:@"%d",tempCount] forKey:keyName];
//            [XMPPUserDefaultManager setValue:tempDict key:@"CountData"];
//        }
        
//        NSArray* fromUser = [[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
        NSXMLElement *innerElementData = [message elementForName:@"data"];
        
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

//        NSLog(@"%@",appDelegate.chatUser);
        if ([selectedFriendUserId isEqualToString:[innerElementData attributeStringValueForName:@"from"]]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserHistory" object:message];
        }
//        else if ([appDelegate.chatUser isEqualToString:@"ChatScreen"]){  //this is use for History chat screen if already open
//            [self addBadgeIcon:[NSString stringWithFormat:@"%d",[[XMPPUserDefaultManager getValue:@"BadgeCount"] intValue] + 1 ]];
//            [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"%d",[[XMPPUserDefaultManager getValue:@"BadgeCount"] intValue] + 1 ] key:@"BadgeCount"];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatScreenHistory" object:nil];
//        }
//        else{
//            [self addBadgeIcon:[NSString stringWithFormat:@"%d",[[XMPPUserDefaultManager getValue:@"BadgeCount"] intValue] + 1 ]];
//            [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"%d",[[XMPPUserDefaultManager getValue:@"BadgeCount"] intValue] + 1 ] key:@"BadgeCount"];
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
    
    
//    XMPPPresence *presence = [XMPPPresence presence];
    //    NSString *string = [notification object]; // object contains some random string.
//    NSXMLElement *status = [NSXMLElement elementWithName:@"status" stringValue:@"my status"];
//     NSXMLElement *emailId = [NSXMLElement elementWithName:@"emailId" stringValue:@"my status"];
//     NSXMLElement *name = [NSXMLElement elementWithName:@"name" stringValue:@"my status"];
//    [presencexmpp addChild:status];
//    [presencexmpp addChild:[NSXMLElement elementWithName:@"emailId" stringValue:@"my status"]];
//    [presencexmpp addChild:[NSXMLElement elementWithName:@"name" stringValue:@"my status"]];
//    NSLog(@"presence info :- %@",presencexmpp);
//    [[self xmppStream] sendElement:presencexmpp];
    
    
//    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
//    
//    [[self xmppStream] sendElement:presence];
}


- (NSData*)reducedImageSize:(UIImage *)selectedImage {
    
//    UIImage *cropped =[cropperView getCroppedImage];
//    //	[delegate imageCropper:self didFinishCroppingWithImage:cropped];
//    if(self.resultImgView)
//        [self.resultImgView removeFromSuperview];
//    
//    self.resultImgView = [[[UIImageView alloc]  initWithFrame:CGRectMake(20, 80, 250, 250)] autorelease];
//    self.resultImgView.image = cropped;
//    self.resultImgView.backgroundColor = [UIColor darkGrayColor];
//    self.resultImgView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.resultImgView.layer setMasksToBounds:YES];
//    self.resultImgView.layer.cornerRadius = self.resultImgView.frame.size.width/2;
//    self.resultImgView.clipsToBounds = YES;
    
    
    
    //    [self.view addSubview:self.resultImgView];
    
    NSData *imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(selectedImage, 1)];
    
//    int imageSize = imageData.length;
//    NSLog(@"SIZE OF IMAGE: %.2f", (float)imageSize/1024/1024);
    
    selectedImage = [self imageWithRoundedCornersSize:0 usingImage:selectedImage];
    
    imageData = [[NSData alloc] initWithData:UIImageJPEGRepresentation(selectedImage, 1)];
    
//    imageSize = imageData.length;
//    NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)imageSize/1024/1024);
    CGSize mySize;
    mySize.height = 512;
    mySize.width = 512;
    
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
    
    
    //    XMPPPresence *presence = [XMPPPresence presence];
    //    NSString *string = [notification object]; // object contains some random string.
    //    NSXMLElement *status = [NSXMLElement elementWithName:@"status" stringValue:@"my status"];
    //     NSXMLElement *emailId = [NSXMLElement elementWithName:@"emailId" stringValue:@"my status"];
    //     NSXMLElement *name = [NSXMLElement elementWithName:@"name" stringValue:@"my status"];
    //    [presencexmpp addChild:status];
    //    [presencexmpp addChild:[NSXMLElement elementWithName:@"emailId" stringValue:@"my status"]];
    //    [presencexmpp addChild:[NSXMLElement elementWithName:@"name" stringValue:@"my status"]];
    //    NSLog(@"presence info :- %@",presencexmpp);
    //    [[self xmppStream] sendElement:presencexmpp];
    
    
    //    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    //
    //    [[self xmppStream] sendElement:presence];
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

#pragma mark - Add badge icon
-(void)addBadgeIcon:(NSString*)badgeValue{
    
    //    if ([badgeValue intValue] < 1) {
    //        [self removeBadgeIcon];
    //    }
    //    else{
    //        for (UILabel *subview in myDelegate.tabBarView.tabBar.subviews)
    //        {
    //            if ([subview isKindOfClass:[UILabel class]])
    //            {
    //                if (subview.tag == 2365) {
    //                    [subview removeFromSuperview];
    //                }
    //            }
    //        }
    //
    //        UILabel *a = [[UILabel alloc] init];
    //        a.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width/5) + (([UIScreen mainScreen].bounds.size.width/5)/2) , 0, 25, 20);
    //        a.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:83.0/255.0 blue:77.0/255.0 alpha:1.0];
    //        a.layer.cornerRadius = 10;
    //        a.layer.masksToBounds = YES;
    //        a.text = badgeValue;
    //        a.tag = 2365;
    //        a.textAlignment = NSTextAlignmentCenter;
    //        [a setFont:[UIFont fontWithName:@"Roboto-Regular" size:10.0]];
    //        a.textColor = [UIColor whiteColor];
    //        [myDelegate.tabBarView.tabBar addSubview:a];
    //    }
    
}
-(void)addBadgeIconLastTab
{
    
    //    for (UILabel *subview in myDelegate.tabBarView.tabBar.subviews)
    //    {
    //        if ([subview isKindOfClass:[UILabel class]])
    //        {
    //            if (subview.tag == 3365) {
    //                [subview removeFromSuperview];
    //            }
    //        }
    //    }
    //
    //    UILabel *notificationBadge = [[UILabel alloc] init];
    //    notificationBadge.frame = CGRectMake((([UIScreen mainScreen].bounds.size.width/5)*4) + (([UIScreen mainScreen].bounds.size.width/5)/2) + 8 , 8, 8, 8);
    //    notificationBadge.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:83.0/255.0 blue:77.0/255.0 alpha:1.0];
    //    notificationBadge.layer.cornerRadius = 5;
    //    notificationBadge.layer.masksToBounds = YES;
    //    notificationBadge.tag = 3365;
    //    [myDelegate.tabBarView.tabBar addSubview:notificationBadge];
}
#pragma mark - end

#pragma mark - Remove badge icon
-(void)removeBadgeIcon{
    //    for (UILabel *subview in myDelegate.tabBarView.tabBar.subviews)
    //    {
    //        if ([subview isKindOfClass:[UILabel class]])
    //        {
    //            if (subview.tag == 2365) {
    //                [subview removeFromSuperview];
    //            }
    //        }
    //    }
}

-(void)removeBadgeIconLastTab
{
    //    for (UILabel *subview in myDelegate.tabBarView.tabBar.subviews)
    //    {
    //        if ([subview isKindOfClass:[UILabel class]])
    //        {
    //            if (subview.tag == 3365) {
    //                [subview removeFromSuperview];
    //            }
    //        }
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
    [self createCacheDirectory:appSentPhotofolderName];
    [self createCacheDirectory:appReceivePhotofolderName];
    [self createCacheDirectory:appDocumentfolderName];
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
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imagesPath = [[self applicationCacheDirectory] stringByAppendingPathComponent:appSentPhotofolderName];
    if (![fileManager fileExistsAtPath:imagesPath]) {
        
        [fileManager createDirectoryAtPath:imagesPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSData * imageData = [self sendReceiveReducedImageSize:image];
    imagesPath=[imagesPath stringByAppendingPathComponent:fileName];
    NSLog(@"SIZE OF IMAGE: %.2f Mb", (float)imageData.length/1024/1024);
    [imageData writeToFile:imagesPath atomically:YES];
    return fileName;
}

- (NSData *)listionSendAttachedImageCacheDirectoryFileName:(NSString *)fileName {
    
    NSString *filePath = [[self applicationCacheDirectory] stringByAppendingPathComponent:appSentPhotofolderName];
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

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
              didSucceedWithData:(NSData *)data
                           named:(NSString *)name
{
    DDLogVerbose(@"%@: Incoming file transfer did succeed.", THIS_FILE);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *fullPath = [[paths lastObject] stringByAppendingPathComponent:name];
    [data writeToFile:fullPath options:0 error:nil];
    
    DDLogVerbose(@"%@: Data was written to the path: %@", THIS_FILE, fullPath);
}
@end
