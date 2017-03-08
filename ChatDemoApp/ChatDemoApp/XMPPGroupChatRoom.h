//
//  XMPPGroupChatRoom.h
//  ChatDemoApp
//
//  Created by Ranosys on 07/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, GroupChatType){
    XMPP_GroupCreate
};

@interface XMPPGroupChatRoom : UIViewController


- (NSArray *)fetchFriendJids;
- (NSMutableDictionary *)fetchFriendDetials;
- (void)getProfilePhotosJid:(NSString *)jid profileImageView:(UIImageView *)profileImageView placeholderImage:(NSString *)placeholderImage result:(void(^)(UIImage *tempImage)) completion;
@end
