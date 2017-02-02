//
//  XmppProfileView.h
//  ChatDemoApp
//
//  Created by Ranosys on 02/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XmppProfileView : UIViewController

@property(nonatomic,readonly) NSString *xmppRegisterId;
@property(nonatomic,readonly) NSString *xmppName;
@property(nonatomic,readonly) NSString *xmppPhoneNumber;
@property(nonatomic,readonly) NSString *xmppUserStatus;
@property(nonatomic,readonly) NSString *xmppDescription;
@property(nonatomic,readonly) NSString *xmppAddress;
@property(nonatomic,readonly) NSString *xmppEmailAddress;
@property(nonatomic,readonly) NSString *xmppUserBirthDay;
@property(nonatomic,readonly) NSString *xmppGender;

- (void)initializeFriendProfile:(NSString*)jid;
- (UIImage *)getFriendProfilePhoto:(NSString *)jid;
- (NSDictionary *)getProfileData:(NSString *)jid;
- (NSDictionary *)getEditProfileData:(NSString *)jid;
- (int)getFriendPresenceStatus:(NSString *)jid;
- (void)userUpdateProfileUsingVCard:(NSMutableDictionary*)profileData profilePlaceholder:(NSString *)profilePlaceholder profileImageView:(UIImage *)profileImageView;

//Notification methods
- (void)XmppUserPresenceUpdateNotify;
- (void)XmppProileUpdateNotify;
- (void)XMPPvCardTempModuleDidUpdateMyvCardSuccessResponse;
- (void)XMPPvCardTempModuleDidUpdateMyvCardFailResponse;
@end
