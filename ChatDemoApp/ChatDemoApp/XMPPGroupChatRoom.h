//
//  XMPPGroupChatRoom.h
//  ChatDemoApp
//
//  Created by Ranosys on 07/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, GroupChatType){
    XMPP_GroupNull,
    XMPP_GroupCreate,
    XMPP_GroupJoin,
    XMPP_GroupDetail,
    XMPP_GroupDelete
};

@interface XMPPGroupChatRoom : UIViewController {

    NSString *chatRoomName;
    NSString *chatRoomDescription;
    NSString *chatRoomNickName;
    UIImage *chatRoomImage;
    XMPPRoom *xmppRoomVar;
    NSString *chatRoomOwnerId;
    
    NSMutableDictionary *xmppCurrentRoomDetail;
}
//NSString *roomName, *roomDescription, *roomNickName;
//UIImage *roomImage;

@property(nonatomic, readonly)NSString *chatRoomName;
@property(nonatomic, readonly)NSString *chatRoomDescription;
@property(nonatomic, readonly)NSString *chatRoomNickName;
@property(nonatomic, readonly)UIImage *chatRoomImage;
@property(nonatomic, readonly)XMPPRoom *xmppRoomVar;
@property(nonatomic, readonly)NSString *chatRoomOwnerId;

@property(nonatomic, readonly)NSMutableDictionary *xmppCurrentRoomDetail;

- (void)deallocObservers;
- (NSArray *)fetchFriendJids;
- (NSMutableDictionary *)fetchFriendDetials;
- (void)getProfilePhotosJid:(NSString *)jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *tempImage)) completion;
- (void)createChatRoom:(UIImage *)groupImage groupNickName:(NSString *)groupNickName groupDescription:(NSString *)groupDescription groupSubject:(NSString *)groupSubject;
- (void)joinChatRoomJid:(NSString *)groupRoomJid groupNickName:(NSString *)groupNickName;
- (void)sendGroupInvitation:(NSArray *)inviteFriend;

- (void)newChatGroupCreated:(NSMutableDictionary *)groupInfo;
- (void)groupJoined;
- (void)invitationSended;
- (void)getGroupPhotoJid:(NSString *)jid result:(void(^)(UIImage *tempImage)) completion;
- (void)appDelegateVariableInitializedGroupSubject:(NSString *)groupSubject groupNickName:(NSString *)groupNickName groupDescription:(NSString *)groupDescription groupJid:(NSString *)groupJid ownerJid:(NSString *)ownerJid;
- (void)appDelegateImageVariableInitialized:(UIImage *)groupPhoto;
- (bool)isOwner;
- (void)destroyRoom;
- (void)xmppRoomDeleteSuccess;
- (void)xmppRoomDeleteFail;
@end
