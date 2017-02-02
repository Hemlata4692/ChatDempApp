//
//  XmppProfileView.h
//  ChatDemoApp
//
//  Created by Ranosys on 02/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XmppProfileView : UIViewController

- (void)initializeFriendProfile:(NSString*)jid;
- (UIImage *)getFriendProfilePhoto:(NSString *)jid;
- (NSDictionary *)getFriendProfileData:(NSString *)jid;
- (int)getFriendPresenceStatus:(NSString *)jid;

//Notification methods
- (void)XmppUserPresenceUpdateNotify;
- (void)XmppFriendProileUpdateNotify;
@end
