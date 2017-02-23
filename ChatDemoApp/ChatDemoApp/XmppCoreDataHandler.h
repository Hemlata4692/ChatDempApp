//
//  XmppCoreDataHandler.h
//  ChatDemoApp
//
//  Created by Ranosys on 21/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegateObjectFile.h"

@interface XmppCoreDataHandler : NSObject
@property(nonatomic,retain)AppDelegateObjectFile *xmppAppDelegateObj;

//Shared instance
+ (id)sharedManager;

- (void)deleteDataModelEntry:(NSString *)registredUserId;
- (void)insertNewUserEntryInXmppUserModel:(NSString *)registredUserId xmppName:(NSString *)xmppName xmppPhoneNumber:(NSString *)xmppPhoneNumber xmppUserStatus:(NSString *)xmppUserStatus xmppDescription:(NSString *)xmppDescription xmppAddress:(NSString *)xmppAddress xmppEmailAddress:(NSString *)xmppEmailAddress xmppUserBirthDay:(NSString *)xmppUserBirthDay xmppGender:(NSString *)xmppGender;
- (void)insertEntryInXmppUserModel:(NSString *)registredUserId xmppName:(NSString *)xmppName xmppPhoneNumber:(NSString *)xmppPhoneNumber xmppUserStatus:(NSString *)xmppUserStatus xmppDescription:(NSString *)xmppDescription xmppAddress:(NSString *)xmppAddress xmppEmailAddress:(NSString *)xmppEmailAddress xmppUserBirthDay:(NSString *)xmppUserBirthDay xmppGender:(NSString *)xmppGender;

//Manage local chat database
- (void)insertLocalMessageStorageDataBase:(NSString *)bareJidStr message:(NSXMLElement *)message;
- (void)insertLocalImageMessageStorageDataBase:(NSString *)bareJidStr message:(NSXMLElement *)message uniquiId:(NSString *)uniquiId;
- (void)removeLocalMessageStorageDataBase:(NSString *)userId;
- (NSArray *)readAllLocalMessageStorageDatabase;
- (NSArray *)readLocalMessageStorageDatabaseBareJidStr:(NSString *)bareJidStr;
- (void)updateLocalMessageStorageDatabaseBareJidStr:(NSString *)bareJidStr message:(NSXMLElement *)message uniquiId:(NSString *)uniquiId;
- (BOOL)isFileMessageExist:(NSString *)message;
//end

//DashboardXmpp storage methods
- (NSDictionary *)getProfileDicData:(NSString *)jid;
- (NSMutableDictionary *)getProfileUsersData;
//end
@end
