//
//  XMPPChatView.h
//  ChatDemoApp
//
//  Created by Ranosys on 06/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XMPPChatView : UIViewController


//Set/Get profile images
- (void)getChatProfilePhotoFriendJid:(NSString *)friendJid profileImageView:(UIImage *)profileImageView friendProfileImageView:(UIImage *)friendProfileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(NSArray *imageArray)) completion;
- (void)getHistoryChatData:(NSString *)jid;
- (void)initializeFriendProfile:(NSString*)jid;
- (int)getPresenceStatus:(NSString *)jid;

//Call child view controller method
- (void)historyData:(NSMutableArray *)result;

//Notification observer handler
- (void)XmppUserPresenceUpdateNotify;

//Send text message
- (void)sendXmppMessage:(NSString *)friendJid friendName:(NSString *)friendName messageString:(NSString *)messageString;
- (void)XmppSendMessageResponse:(NSXMLElement *)xmpMessage;
@end
