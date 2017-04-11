//
//  GroupChatTableViewCell.h
//  ChatDemoApp
//
//  Created by Ranosys on 23/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPGroupChatRoom.h"

@interface GroupChatTableViewCell : UITableViewCell {

    XMPPGroupChatRoom *xmppGroupChatRoomObj;
}

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *separatorLabel;
@property (strong, nonatomic) IBOutlet UILabel *halfSeparatorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UIImageView *attachedImageView;

@property (strong, nonatomic) IBOutlet UIView *audioBackView;
@property (strong, nonatomic) IBOutlet UIButton *playPauseButton;
@property (strong, nonatomic) IBOutlet UIProgressView *audioProgress;
@property (strong, nonatomic) IBOutlet UILabel *audioStartTime;
@property (strong, nonatomic) IBOutlet UILabel *audioEndTIme;
@property (strong, nonatomic) IBOutlet UIButton *videoPlayButton;

- (void)displaySingleMessageData:(NSXMLElement *)message profileImageView:(UIImage *)logedInUserPhoto chatType:(NSString *)chatType memberColor:(NSMutableDictionary *)memberColor;
- (void)displayMultipleMessage:(NSXMLElement *)currentMessage nextmessage:(NSXMLElement *)nextmessage previousMessage:(NSXMLElement *)previousMessage profileImageView:(UIImage *)logedInUserPhoto chatType:(NSString *)chatType memberColor:(NSMutableDictionary *)memberColor;
- (void)displayFirstMessage:(NSXMLElement *)currentMessage nextmessage:(NSXMLElement *)nextmessage profileImageView:(UIImage *)logedInUserPhoto chatType:(NSString *)chatType memberColor:(NSMutableDictionary *)memberColor;
- (void)displayLastMessage:(NSXMLElement *)currentMessage previousMessage:(NSXMLElement *)previousMessage profileImageView:(UIImage *)logedInUserPhoto chatType:(NSString *)chatType memberColor:(NSMutableDictionary *)memberColor;
@end















