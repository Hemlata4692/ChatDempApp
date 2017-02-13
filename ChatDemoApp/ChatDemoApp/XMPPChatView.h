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
@end
