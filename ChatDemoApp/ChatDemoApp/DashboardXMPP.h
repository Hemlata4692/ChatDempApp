//
//  DashboardXMPP.h
//  ChatDemoApp
//
//  Created by Ranosys on 31/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "XMPPUserDefaultManager.h"

@interface DashboardXMPP : UIViewController<NSFetchedResultsControllerDelegate> {

    NSFetchedResultsController *fetchedResultsController;
}
//@property(nonatomic,strong) NSMutableDictionary *xmppUserDetailedList;
//@property(nonatomic,strong) NSMutableArray *xmppUserListArray;

//Post notification method declaration
- (void)updateProfileInformation;
- (void)xmppUserListResponse:(NSMutableDictionary *)xmppUserDetails xmppUserListIds:(NSMutableArray *)xmppUserListIds;
- (void)getProfileData:(NSString *)jid result:(void(^)(NSDictionary *tempProfileData)) completion;
- (void)getProfileData1:(void(^)(NSDictionary *tempProfileData)) completion;
- (NSDictionary *)getProfileDicData:(NSString *)jid;
- (NSMutableDictionary *)getProfileUsersData;
- (void)xmppUserRefreshResponse;
- (void)xmppUserConnect;
- (void)xmppOfflineUserConnect;
- (void)xmppNewUserAddedNotify;
- (void)xmppPresenceUpdateNotify;
- (void)historyUpdateNotify;
- (void)getProfilePhotosJid:(NSString *)jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *tempImage)) completion;
//end
//Check presence
- (int)getPresenceStatus:(NSString *)jid;

- (NSFetchedResultsController *)fetchedResultsController;

//This method is used for logout user
- (void)userXMPPLogout;

//Fetch chat history
- (void)fetchAllHistoryChat:(void(^)(NSMutableArray *tempHistoryData))completion;

//Group chat
- (void)deallocGroupChatVariables;
- (NSMutableArray *)fetchGroupChatRommInfoList;
- (void)getListOfGroups;
- (void)getListOfGroupsNotify:(NSMutableArray *)groupInfo;
- (void)getGroupPhotoJid:(NSString *)jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *tempImage)) completion;
//end

- (BOOL)isChatTypeMessageElement:(NSXMLElement *)message;
- (BOOL)isGroupChatTypeMessageElement:(NSXMLElement *)message;


- (void)XMPPReloadConnection;
@end
