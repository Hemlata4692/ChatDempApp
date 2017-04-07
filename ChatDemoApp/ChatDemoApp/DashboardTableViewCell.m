//
//  DashboardTableViewCell.m
//  ChatDemoApp
//
//  Created by Ranosys on 03/04/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "DashboardTableViewCell.h"

#import "XMPPUserDefaultManager.h"
#import "DashboardXMPP.h"

@interface DashboardTableViewCell() {

    DashboardXMPP *dashBoardXmppObj;
}
@end

@implementation DashboardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    dashBoardXmppObj=[[DashboardXMPP alloc] init];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Display cell data
//Set contact list user data
- (void)displayContactListUserData:(NSMutableDictionary *)userProfileData jid:(NSString *)jid index:(int)index presenceStatus:(int)presenceStatus {
    
    self.badgeLabel.hidden=YES;
    self.profileBtn.hidden=NO;
    self.timeLabel.hidden=YES;
    self.profileBtn.tag=(int)index;
    self.userImage.layer.cornerRadius=20;
    self.userImage.layer.masksToBounds=YES;
    self.presenceIndicator.hidden=NO;
    self.presenceIndicator.layer.cornerRadius=7;
    self.presenceIndicator.layer.masksToBounds=YES;
    
    self.nameLabel.text = [userProfileData objectForKey:@"Name"];
    self.statusLabel.text=[userProfileData objectForKey:@"UserStatus"];
    NSLog(@" userStatus:%@ \n phoneNumber:%@ Desc:%@ \n address:%@ \n emailid:%@ \n birthDay:%@ \n gender:%@",[userProfileData objectForKey:@"UserStatus"],[userProfileData objectForKey:@"PhoneNumber"],[userProfileData objectForKey:@"Description"],[userProfileData objectForKey:@"Address"],[userProfileData objectForKey:@"EmailAddress"],[userProfileData objectForKey:@"UserBirthDay"],[userProfileData objectForKey:@"Gender"]);
    [self configurePhotoForCell:self jid:jid];
    
    self.presenceIndicator.layer.borderWidth=1.5;
    self.presenceIndicator.layer.borderColor=[UIColor whiteColor].CGColor;
    switch (presenceStatus) {
        case 0:     // online/available
            self.presenceIndicator.backgroundColor=[UIColor colorWithRed:0.0/255.0 green:160.0/255.0 blue:0.0/255.0 alpha:1.0];
            break;
        default:    //offline
            self.presenceIndicator.backgroundColor=[UIColor redColor];
            break;
    }
}

//Set user history data
- (void)displayHistoryListUserData:(NSXMLElement *)historyElement index:(int)index {
    
    self.badgeLabel.hidden=YES;
    self.profileBtn.hidden=NO;
    self.badgeLabel.layer.masksToBounds=YES;
    self.badgeLabel.layer.cornerRadius=10;
    self.presenceIndicator.hidden=YES;
    
    NSXMLElement *innerData=[historyElement elementForName:@"data"];
    
    if (![[innerData attributeStringValueForName:@"from"] isEqualToString:myDelegate.xmppLogedInUserId]) {
        
        if ([dashBoardXmppObj isChatTypeMessageElement:historyElement]) {
            if ([[XMPPUserDefaultManager getXMPPBadgeIndicatorValue:[innerData attributeStringValueForName:@"from"]] intValue]!=0) {
                self.badgeLabel.hidden=NO;
                self.badgeLabel.text=[XMPPUserDefaultManager getXMPPBadgeIndicatorValue:[innerData attributeStringValueForName:@"from"]];
            }
            [self configurePhotoForCell:self jid:[innerData attributeStringValueForName:@"from"]];
        }
        else {
            if ([[XMPPUserDefaultManager getXMPPBadgeIndicatorValue:[innerData attributeStringValueForName:@"to"]] intValue]!=0) {
                self.badgeLabel.hidden=NO;
                self.badgeLabel.text=[XMPPUserDefaultManager getXMPPBadgeIndicatorValue:[innerData attributeStringValueForName:@"to"]];
            }
            self.userImage.image=[UIImage imageNamed:@"groupPlaceholderImage.png"];
        }
        
        self.nameLabel.text = [[innerData attributeStringValueForName:@"senderName"] capitalizedString];
    }
    else {
        
        if ([dashBoardXmppObj isChatTypeMessageElement:historyElement]) {
            [self configurePhotoForCell:self jid:[innerData attributeStringValueForName:@"to"]];
        }
        else {
            self.userImage.image=[UIImage imageNamed:@"groupPlaceholderImage.png"];
        }
        
        self.nameLabel.text = [[innerData attributeStringValueForName:@"receiverName"] capitalizedString];
        if ([[XMPPUserDefaultManager getXMPPBadgeIndicatorValue:[innerData attributeStringValueForName:@"to"]] intValue]!=0) {
            self.badgeLabel.hidden=NO;
            self.badgeLabel.text=[XMPPUserDefaultManager getXMPPBadgeIndicatorValue:[innerData attributeStringValueForName:@"to"]];
        }
    }
    
    self.timeLabel.hidden=NO;
    self.profileBtn.tag=index;
    self.userImage.layer.cornerRadius=20;
    self.userImage.layer.masksToBounds=YES;
    
    if ([[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"FileAttachment"]) {
        self.statusLabel.text=@"File \U0001F4D1";
    }
    else if ([[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"ImageAttachment"]) {
        self.statusLabel.text=@"Photo \U0001F4F7";
    }
    else if ([[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"Location"]) {
        self.statusLabel.text=@"Location \U0001F4CD";//earth 1F4CC //other pin 1F30F
    }
    else if ([[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"AudioAttachment"]) {
        self.statusLabel.text=@"Audio \U0001F50A";
    }
    else {
        self.statusLabel.text=[[historyElement elementForName:@"body"] stringValue];
    }
    //        statusLabel.text=[[historyElement elementForName:@"body"] stringValue];
    self.timeLabel.text=[self changeTimeFormat:[innerData attributeStringValueForName:@"time"]];
    //        NSLog(@" userStatus:%@ \n phoneNumber:%@ Desc:%@ \n address:%@ \n emailid:%@ \n birthDay:%@ \n gender:%@",[profileDic objectForKey:@"UserStatus"],[profileDic objectForKey:@"PhoneNumber"],[profileDic objectForKey:@"Description"],[profileDic objectForKey:@"Address"],[profileDic objectForKey:@"EmailAddress"],[profileDic objectForKey:@"UserBirthDay"],[profileDic objectForKey:@"Gender"]);
}

//Set user group chat data
- (void)displayGroupListData:(NSMutableDictionary *)groupDataDic {
    
    self.presenceIndicator.hidden=YES;
    self.timeLabel.hidden=YES;
    self.profileBtn.hidden=YES;
    self.userImage.layer.cornerRadius=20;
    self.userImage.layer.masksToBounds=YES;
    
    self.nameLabel.text = [groupDataDic objectForKey:@"roomName"];
    self.statusLabel.text=[groupDataDic objectForKey:@"roomDescription"];
    [self configureGroupPhotoForCell:self jid:[groupDataDic objectForKey:@"roomJid"]];
}
#pragma mark - end

#pragma mark - Set user images
//Group chat
- (void)configureGroupPhotoForCell:(DashboardTableViewCell *)cell jid:(NSString *)jid {
    
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    [dashBoardXmppObj getGroupPhotoJid:jid profileImageView:self.userImage placeholderImage:@"groupPlaceholderImage.png" result:^(UIImage *tempImage) {
        // do something with your BOOL
        if (tempImage!=nil) {
            self.userImage.image=tempImage;
        }
        else {
            
            self.userImage.image=[UIImage imageNamed:@"groupPlaceholderImage.png"];
        }
    }];
}

//One to one chat
- (void)configurePhotoForCell:(DashboardTableViewCell *)cell jid:(NSString *)jid {
    
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    [dashBoardXmppObj getProfilePhotosJid:jid profileImageView:cell.userImage placeholderImage:@"images.png" result:^(UIImage *tempImage) {
        // do something with your BOOL
        if (tempImage!=nil) {
            cell.userImage.image=tempImage;
        }
        else {
            
            cell.userImage.image=[UIImage imageNamed:@"images.png"];
        }
    }];
}
#pragma mark - end

#pragma mark - Change time format
- (NSString *)changeTimeFormat:(NSString *)timeString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:timeString];
    [dateFormatter setDateFormat:@"hh:mm a"];
    return [dateFormatter stringFromDate:date];
}
#pragma mark - end
@end
