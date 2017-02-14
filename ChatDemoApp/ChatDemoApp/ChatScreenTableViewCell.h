//
//  ChatScreenTableViewCell.h
//  ChatDemoApp
//
//  Created by Ranosys on 14/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatScreenTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *separatorLabel;
@property (strong, nonatomic) IBOutlet UILabel *halfSeparatorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userImage;

- (void)displaySingleMessageData:(NSXMLElement *)message profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto;
- (void)displayMultipleMessage:(NSXMLElement *)currentMessage nextmessage:(NSXMLElement *)nextmessage previousMessage:(NSXMLElement *)previousMessage profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto;
- (void)displayFirstMessage:(NSXMLElement *)currentMessage nextmessage:(NSXMLElement *)nextmessage profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto;
- (void)displayLastMessage:(NSXMLElement *)currentMessage previousMessage:(NSXMLElement *)previousMessage profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto;
@end
