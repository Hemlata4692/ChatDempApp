//
//  DashboardXMPP.h
//  ChatDemoApp
//
//  Created by Ranosys on 31/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DashboardXMPP : UIViewController<NSFetchedResultsControllerDelegate> {

    NSFetchedResultsController *fetchedResultsController;
}
//@property(nonatomic,strong) NSMutableDictionary *xmppUserDetailedList;
//@property(nonatomic,strong) NSMutableArray *xmppUserListArray;

//Post notification method declaration
- (void)updateProfileInformation;
- (void)xmppUserListResponse:(NSMutableDictionary *)xmppUserDetails xmppUserListIds:(NSMutableArray *)xmppUserListIds;
- (NSDictionary *)getProfileData:(NSString *)jid;
- (void)xmppUserRefreshResponse;
- (void)xmppUserConnect;
- (void)xmppNewUserAddedNotify;
//end

- (NSFetchedResultsController *)fetchedResultsController;

//This method is used for logout user
- (void)userLogout;
@end
