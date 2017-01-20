//
//  AppDelegateObjectFile.h
//  ChatDemoApp
//
//  Created by Ranosys on 18/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "XMPP.h"
#import "XMPPFramework.h"
#import "TURNSocket.h"
#import "XMPPMessageArchivingCoreDataStorage.h"

@interface AppDelegateObjectFile : UIResponder<XMPPRosterDelegate>
{
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    NSString *xmppPassword;
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
    NSMutableArray *turnSockets;
}

//Delcare XMPP variables
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property(strong, nonatomic)XMPPMessageArchivingCoreDataStorage* xmppMessageArchivingCoreDataStorage;
@property(strong, nonatomic)XMPPMessageArchiving* xmppMessageArchivingModule;
//end

//Declaration hostname, port and defaultpassword for complete app
@property(strong, nonatomic)NSString *hostName;
@property(strong, nonatomic)NSString *serverName;
@property(strong, nonatomic)NSString *defaultPassword;
@property(assign, nonatomic)int portNumber;
//end

@property(strong, nonatomic)NSMutableArray *UserListArray;
@property(strong, nonatomic)NSMutableArray *groupListArray;
@property(strong, nonatomic)NSString *chatUser;
@property(strong, nonatomic)NSMutableArray *userHistoryArr;
@property(strong, nonatomic)NSMutableDictionary *userProfileImage;
@property(strong, nonatomic)UIImageView *userProfileImageData;
@property(strong, nonatomic)NSData *userProfileImageDataValue;
@property(strong, nonatomic)NSString *myView;

-(BOOL)connect;
-(void)disconnect;
-(void)addBadgeIcon:(NSString*)badgeValue;
-(void)editProfileImageUploading:(UIImage*)editProfileImge;
-(void)addBadgeIconLastTab;
-(void)removeBadgeIconLastTab;
-(void)methodCalling;
- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

//AppDelegate methods
- (void)didFinishLaunchingMethod;
- (void)enterBackgroundMethod :(UIApplication *)application;
- (void)enterForegroundMethod :(UIApplication *)application;
- (void)enterTerminationMethod :(UIApplication *)application;
//end

































@end
