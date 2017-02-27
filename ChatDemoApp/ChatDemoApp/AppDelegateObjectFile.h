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
//#import <XMPPMessageDeliveryReceipts.h>
#import <CoreData/CoreData.h>

//File transfer
#import "XMPPIncomingFileTransfer.h"

@interface AppDelegateObjectFile : UIResponder<XMPPRosterDelegate,XMPPStreamDelegate,
XMPPIncomingFileTransferDelegate>
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
//    XMPPMessageDeliveryReceipts *xmppMessageDeliveryRecipts;
    NSString *xmppPassword;
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
    NSMutableArray *turnSockets;
    
    //File transfer
    XMPPIncomingFileTransfer *xmppIncomingFileTransfer;
}

//Delcare XMPP variables

@property (nonatomic, strong) XMPPPresence *presencexmpp;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;

@property (nonatomic, strong, readonly) XMPPIncomingFileTransfer *xmppIncomingFileTransfer;//File transfer

@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@property(strong, nonatomic)XMPPMessageArchivingCoreDataStorage* xmppMessageArchivingCoreDataStorage;
@property(strong, nonatomic)XMPPMessageArchiving* xmppMessageArchivingModule;

//@property(strong, nonatomic)XMPPMessageDeliveryReceipts *xmppMessageDeliveryRecipts;
//end

//Declaration hostname, port and defaultpassword for complete app
@property(strong, nonatomic)NSString *hostName;
@property(strong, nonatomic)NSString *serverName;
@property(strong, nonatomic)NSString *defaultPassword;
@property(strong, nonatomic)NSString *xmppUniqueId;
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
@property(assign, nonatomic)BOOL isContactListIsLoaded;
@property(assign, nonatomic)BOOL isUpdatePofile;
@property(strong, nonatomic)NSString *selectedFriendUserId;

-(BOOL)connect;
-(void)disconnect;
-(void)editProfileImageUploading:(NSMutableDictionary *)profileData;
-(void)methodCalling:(NSMutableDictionary *)profileData;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

//AppDelegate methods
- (void)didFinishLaunchingMethod;
- (void)enterBackgroundMethod :(UIApplication *)application;
- (void)enterForegroundMethod :(UIApplication *)application;
- (void)enterTerminationMethod :(UIApplication *)application;
//end

//CoreData array
@property (strong) NSMutableArray *xmppUserEntries;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong) NSPersistentContainer *persistentContainer;
- (void)saveContext;
//end

@property(nonatomic,strong) NSMutableDictionary *xmppUserDetailedList;
@property(nonatomic,strong) NSMutableArray *xmppUserListArray;
@property(nonatomic,strong) NSString *xmppLogedInUserId;
@property(nonatomic,strong) NSString *xmppLogedInUserName;
- (NSString *)applicationCacheDirectory;

@property(nonatomic,strong) NSString *folderName;
@property(nonatomic,strong) NSString *appMediafolderName;
@property(nonatomic,strong) NSString *appProfilePhotofolderName;
@property(nonatomic,strong) NSString *appSentReceivePhotofolderName;
@property(nonatomic,strong) NSString *appMapPhotofolderName;

@property(nonatomic,strong) NSString *appDocumentfolderName;

@property(nonatomic,assign) float imageCompressionPercent;
- (void)createCacheDirectory:(NSString *)imageFolderName;
- (void)saveDataInCacheDirectory:(UIImage *)tempImage folderName:(NSString *)tempFolderName jid:(NSString *)jid;
- (NSData *)listionDataFromCacheDirectoryFolderName:(NSString *)tempFolderName jid:(NSString *)jid;

@property(nonatomic,assign) int afterAutentication;
@property(nonatomic,assign) int afterAutenticationRegistration;

//- (void)sendFile:(NSData*)data fileName:(NSString *)fileName jid:(XMPPJID *)jid;


//Check null/nil value
- (NSString *)checkNilValue:(id)checkValue;
- (NSString *)setOtherImageInLocalDB:(UIImage*)image;
- (NSData *)listionSendAttachedImageCacheDirectoryFileName:(NSString *)fileName;

- (NSManagedObjectContext *)managedObjectContext;

- (void)getAllDocumentListing:(void(^)(NSMutableArray *tempArray))completion;
- (NSData *)documentCacheDirectoryFileName:(NSString *)fileName;
- (NSString *)documentCacheDirectoryPathFileName:(NSString *)fileName;
- (void)getThumbnailImagePDF:(NSString *)fileName result:(void(^)(UIImage *tempImage))completion;
- (void)saveFileInLocalDocumentDirectory:(NSString *)fileName file:(NSData *)fileData;

- (NSString *)setMapImageInLocalDB:(UIImage*)image;
- (NSData *)listionSendAttachedLocationImageCacheDirectoryFileName:(NSString *)fileName;
@end
