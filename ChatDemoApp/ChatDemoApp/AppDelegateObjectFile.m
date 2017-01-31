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

#pragma mark - Intialze XMPP connection
- (void)didFinishLaunchingMethod {

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
        [self connect];
    }
//    else {
//    [self connect];
//    }
    
    
//    // Fetch the user entries from persistent data store
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserEntry"];
//    xmppUserEntries = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];

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
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    [self goOnline];
    
    if ([xmppStream isAuthenticated]) {
        
        NSLog(@"authenticated");
//        [xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:@"test11@administrator"] ignoreStorage:YES];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPDidAuthenticatedResponse" object:nil];
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule{
    NSLog(@"succes");
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error{
    NSLog(@"fail");
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
//    if (nil!=[XMPPUserDefaultManager getValue:@"LoginCred"] && ![[XMPPUserDefaultManager getValue:@"LoginCred"] isEqualToString:[NSString stringWithFormat:@"zebra@%@",hostName]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPDidNotAuthenticatedResponse" object:nil];
//    }
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
    NSArray *successStoryArray = [vcardInfo elementsForName:@"EMAILADDRESS"];
    NSLog(@"successStoryArray: %@", successStoryArray);
    
//    <iq xmlns="jabber:client" type="set" id="100-166" to="1111111111@192.168.1.171/8nbo21q8fn"><query xmlns="jabber:iq:roster"><item jid="9999666666@192.168.1.171" name="p" subscription="both"><group>Ranosys</group></item></query></iq>
//    <iq xmlns="jabber:client" type="set" id="827-142" to="1111111111@192.168.1.171/8nbo21q8fn"><query xmlns="jabber:iq:roster"><item jid="5555888888@192.168.1.171" subscription="remove"></item></query></iq>
    
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
        
        
        [message addAttributeWithName:@"fromTo" stringValue:[NSString stringWithFormat:@"%@-%@",[message attributeStringValueForName:@"to"],[[[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"] objectAtIndex:0]]];
        
        [xmppMessageArchivingCoreDataStorage archiveMessage:message outgoing:NO xmppStream:[self xmppStream]];
        NSString *keyName = [[[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"] objectAtIndex:0];
        if ([[XMPPUserDefaultManager getValue:@"CountData"] objectForKey:keyName] == nil) {
            int tempCount = 1;
            
            NSMutableDictionary *tempDict = [[XMPPUserDefaultManager getValue:@"CountData"] mutableCopy];
            [tempDict setObject:[NSString stringWithFormat:@"%d",tempCount] forKey:keyName];
            [XMPPUserDefaultManager setValue:tempDict key:@"CountData"];
        }
        else{
            int tempCount = [[[XMPPUserDefaultManager getValue:@"CountData"] objectForKey:keyName] intValue];
            tempCount = tempCount + 1;
            NSMutableDictionary *tempDict = [[XMPPUserDefaultManager getValue:@"CountData"] mutableCopy];
            [tempDict setObject:[NSString stringWithFormat:@"%d",tempCount] forKey:keyName];
            [XMPPUserDefaultManager setValue:tempDict key:@"CountData"];
        }
        
        NSArray* fromUser = [[message attributeStringValueForName:@"from"] componentsSeparatedByString:@"/"];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

        NSLog(@"%@",appDelegate.chatUser);
        if ([appDelegate.chatUser isEqualToString:[fromUser objectAtIndex:0]]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserHistory" object:message];
        }
        else if ([appDelegate.chatUser isEqualToString:@"ChatScreen"]){  //this is use for History chat screen if already open
            [self addBadgeIcon:[NSString stringWithFormat:@"%d",[[XMPPUserDefaultManager getValue:@"BadgeCount"] intValue] + 1 ]];
            [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"%d",[[XMPPUserDefaultManager getValue:@"BadgeCount"] intValue] + 1 ] key:@"BadgeCount"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatScreenHistory" object:nil];
        }
        else{
            [self addBadgeIcon:[NSString stringWithFormat:@"%d",[[XMPPUserDefaultManager getValue:@"BadgeCount"] intValue] + 1 ]];
            [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"%d",[[XMPPUserDefaultManager getValue:@"BadgeCount"] intValue] + 1 ] key:@"BadgeCount"];
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    
    NSString *presenceType = [presence type];
    if  ([presenceType isEqualToString:@"subscribe"]) {
        
        [xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
    }
    NSLog(@" Printing full jid of user %@",[[sender myJID] full]);
    NSLog(@"Printing full jid of user %@",[[sender myJID] resource]);
    NSLog(@"From user %@",[[presence from] full]);
    
    int myCount = [[XMPPUserDefaultManager getValue:@"CountValue"] intValue];
    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    if ((myCount == 1)&&nil!=self.userProfileImageDataValue) {
//        [XMPPUserDefaultManager setValue:[NSString stringWithFormat:@"%d",myCount+1] key:@"CountValue"];
//        [self performSelector:@selector(methodCalling) withObject:nil afterDelay:0.1];
//    }
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Registration Successful!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
    NSMutableDictionary *registerSuccessDict=[NSMutableDictionary new];
    [registerSuccessDict setObject:@"1" forKey:@"Status"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPDidRegisterResponse" object:registerSuccessDict];
}


- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    
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

-(void)methodCalling:(NSMutableDictionary *)profileData {
    
    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
    NSData *pictureData;
    if (nil!=self.userProfileImageDataValue) {
        
        pictureData = UIImageJPEGRepresentation([UIImage imageWithData:self.userProfileImageDataValue], 1.0);
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

- (NSString *)setProfileDataValue:(NSMutableDictionary *)profileData key:(NSString *)key {

    NSString *value=@"";
    if (nil!=[profileData objectForKey:key]||NULL!=[profileData objectForKey:key]||([[profileData objectForKey:key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0)) {
        
        value=[[profileData objectForKey:key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return value;
}

- (NSString *)setProfileDataValuae:value1 key:(NSString *)key {
    
    NSString *value=@"";
//    if (nil!=[profileData objectForKey:key]||NULL!=[profileData objectForKey:key]||([[profileData objectForKey:key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length != 0)) {
    
        value=value1;
//    }
    return value;
}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid{
    NSLog(@"a");
}

-(void)editProfileImageUploading{
    
//    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
//    XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
//    NSData *pictureData = UIImageJPEGRepresentation(editProfileImge, 0.5);
//    
//    [newvCardTemp setPhoto:pictureData];
//    XMPPvCardCoreDataStorage * xmppvCardStorage1 = [XMPPvCardCoreDataStorage sharedInstance];
//    XMPPvCardTempModule * xmppvCardTempModule1 = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage1];
//    [xmppvCardTempModule1  activate:[self xmppStream]];
//    [xmppvCardTempModule1 updateMyvCardTemp:newvCardTemp];
    
    NSXMLElement *vCardXML = [NSXMLElement elementWithName:@"vCard" xmlns:@"vcard-temp"];
    XMPPvCardTemp *newvCardTemp = [XMPPvCardTemp vCardTempFromElement:vCardXML];
//    NSData *pictureData;
//    if (nil!=self.userProfileImageDataValue) {
//        
//        pictureData = UIImageJPEGRepresentation([UIImage imageWithData:self.userProfileImageDataValue], 1.0);
//        [newvCardTemp setPhoto:pictureData];
//    }
    
    /*//Other variables
     [newvCardTemp setNickname:@"aaaaaa"];
     NSArray *interestsArray= [[NSArray alloc] initWithObjects:@"food", nil];
     [newvCardTemp setLabels:interestsArray];
     [newvCardTemp setMiddleName:@"Stt"];
     [newvCardTemp setUserStatus:@"I am available"];
     [newvCardTemp setAddress:@"rohitm@ranosys.com"];
     [newvCardTemp setEmailAddresses:[NSMutableArray arrayWithObjects:@"rohitmodi@ranosys.com",@"rohitm@ranosys.com", nil]];
     */
    
//    [newvCardTemp setRegisterUserId:[self setProfileDataValue:profileData key:@"xmppRegisterId"]];
//    [newvCardTemp setNickname:[self setProfileDataValue:profileData key:@"xmppName"]];
//    [newvCardTemp setTelecomsAddress:[self setProfileDataValue:profileData key:@"xmppPhoneNumber"]];
    [newvCardTemp setUserStatus:@"tenth status"];
//    [newvCardTemp setDesc:[self setProfileDataValue:profileData key:@"xmppDescription"]];
//    [newvCardTemp setAddress:[self setProfileDataValue:profileData key:@"xmppAddress"]];
    [newvCardTemp setEmailAddress:@"newemail@c.com"];
    [newvCardTemp setNickname:@"newemail@c.com"];
//    [newvCardTemp setBday:[self setProfileDataValue:profileData key:@"xmppUserBirthDay"]];
//    [newvCardTemp setGender:[self setProfileDataValue:profileData key:@"xmppGender"]];
    
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
    if ([myDelegate.myView isEqualToString:@"UserListView"]) {
        
        
        [myDelegate stopIndicator];
    }
    
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


//- (NSManagedObjectContext *)managedObjectContext
//{
//    NSManagedObjectContext *context = nil;
//    id delegate = [[UIApplication sharedApplication] delegate];
//    if ([delegate performSelector:@selector(managedObjectContext)]) {
//        context = [delegate managedObjectContext];
//    }
//    return context;
//}

//[[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPvCardTempModuleDidUpdateMyvCardSuccess" object:nil];
//}
//
//- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error{
//    //The vCard failed to update so we fetch the current one from the server
//    [_xmppvCardTempModule fetchvCardTempForJID:[xmppStream myJID] ignoreStorage:YES];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"XMPPvCardTempModuleDidUpdateMyvCardFail" object:nil];



//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPvCardTempModuleDidUpdateMyvCardSuccess) name:@"XMPPvCardTempModuleDidUpdateMyvCardSuccess" object:nil];
//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(XMPPvCardTempModuleDidUpdateMyvCardFail) name:@"XMPPvCardTempModuleDidUpdateMyvCardFail" object:nil];











@end
