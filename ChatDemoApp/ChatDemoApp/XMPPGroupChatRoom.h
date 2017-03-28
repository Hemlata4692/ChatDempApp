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
    XMPP_GroupDelete,
    XMPP_GroupInvite
};

@interface XMPPGroupChatRoom : UIViewController {

    NSString *chatRoomName;
    NSString *chatRoomDescription;
    UIImage *chatRoomImage;
    XMPPRoom *xmppRoomVar;
    NSString *chatRoomOwnerId;
    
    NSMutableDictionary *xmppCurrentRoomDetail;
}
//NSString *roomName, *roomDescription;
//UIImage *roomImage;

@property(nonatomic, readonly)NSString *chatRoomName;
@property(nonatomic, readonly)NSString *chatRoomDescription;
@property(nonatomic, readonly)UIImage *chatRoomImage;
@property(nonatomic, readonly)XMPPRoom *xmppRoomVar;
@property(nonatomic, readonly)NSString *chatRoomOwnerId;

@property(nonatomic, readonly)NSMutableDictionary *xmppCurrentRoomDetail;

- (void)deallocObservers;
- (NSArray *)fetchFriendJids;
- (NSMutableDictionary *)fetchFriendDetials;
- (void)getProfilePhotosJid:(NSString *)jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *tempImage)) completion;
- (void)createChatRoom:(UIImage *)groupImage groupDescription:(NSString *)groupDescription groupSubject:(NSString *)groupSubject;
- (void)joinChatRoomJid:(NSString *)groupRoomJid;
- (void)sendGroupInvitation:(NSArray *)inviteFriend;

- (void)newChatGroupCreated:(NSMutableDictionary *)groupInfo;
- (void)groupJoined:(NSMutableArray *)memberList;
- (void)invitationSended;
- (void)getGroupPhotoJid:(NSString *)jid result:(void(^)(UIImage *tempImage)) completion;
- (void)appDelegateVariableInitializedGroupSubject:(NSString *)groupSubject groupDescription:(NSString *)groupDescription groupJid:(NSString *)groupJid ownerJid:(NSString *)ownerJid;
- (void)appDelegateImageVariableInitialized:(UIImage *)groupPhoto;
- (bool)isOwner;
- (void)destroyRoom;
- (void)xmppRoomDeleteSuccess;
- (void)xmppRoomDeleteFail;

//Send group message
- (void)getHistoryGroupChatData:(NSString *)jid;
- (void)sendXmppMessage:(NSString *)roomJid subjectName:(NSString *)subjectName messageString:(NSString *)messageString;
+ (void)getChatProfilePhotoJid:(NSString *)Jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *image)) completion;
- (void)historyData:(NSMutableArray *)result;
- (void)XmppSendMessageResponse:(NSXMLElement *)xmpMessage;

//Send location
- (void)sendLocationXmppMessage:(NSString *)roomJid roomName:(NSString *)roomName messageString:(NSString *)messageString latitude:(NSString *)latitude longitude:(NSString *)longitude;

//Send image
- (void)sendImageAttachment:(NSString *)fileName imageCaption:(NSString *)imageCaption roomName:(NSString *)roomName;

//Send document
- (void)sendDocumentAttachment:(NSString *)fileName roomName:(NSString *)roomName;

//File transfer notify methods
- (void)sendFileSuccessDelegate:(NSXMLElement *)message uniquiId:(NSString *)uniqueId;
- (void)sendFileFailDelegate:(NSXMLElement *)message uniquiId:(NSString *)uniqueId;
- (void)sendFileProgressDelegate:(NSXMLElement *)message;

@end
