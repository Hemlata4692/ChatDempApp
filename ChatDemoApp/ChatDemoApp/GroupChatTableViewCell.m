//
//  GroupChatTableViewCell.m
//  ChatDemoApp
//
//  Created by Ranosys on 23/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "GroupChatTableViewCell.h"

@implementation GroupChatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//FileAttachment
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)displaySingleMessageData:(NSXMLElement *)message profileImageView:(UIImage *)logedInUserPhoto chatType:(NSString *)chatType memberColor:(NSMutableDictionary *)memberColor {
    
    [self displaySingleTypeMessageData:message profileImageView:logedInUserPhoto chatType:chatType memberColor:memberColor];
    self.separatorLabel.hidden=false;
}

- (void)displayFirstMessage:(NSXMLElement *)currentMessage nextmessage:(NSXMLElement *)nextmessage profileImageView:(UIImage *)logedInUserPhoto chatType:(NSString *)chatType memberColor:(NSMutableDictionary *)memberColor {
    
    [self displaySingleTypeMessageData:currentMessage profileImageView:logedInUserPhoto chatType:chatType memberColor:memberColor];
    NSXMLElement *innerData=[currentMessage elementForName:@"data"];
    NSXMLElement *innerData1=[nextmessage elementForName:@"data"];
    
    if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
        
        self.halfSeparatorLabel.hidden=false;
    }
    else {
        
        self.separatorLabel.hidden=false;
    }
}

- (void)displaySingleTypeMessageData:(NSXMLElement *)message profileImageView:(UIImage *)logedInUserPhoto chatType:(NSString *)chatType memberColor:(NSMutableDictionary *)memberColor {
    
    //Unhide/hide all objects
    self.userImage.hidden=false;
    self.nameLabel.hidden=false;
    self.messageLabel.hidden=false;
    self.dateLabel.hidden=false;
    self.separatorLabel.hidden=true;
    self.halfSeparatorLabel.hidden=true;
    self.attachedImageView.image=[UIImage imageNamed:@""];
    
    if ([chatType isEqualToString:@"ImageAttachment"]||[chatType isEqualToString:@"FileAttachment"]||[chatType isEqualToString:@"Location"]) {
        self.attachedImageView.hidden=false;
    }
    else {
        
        self.attachedImageView.hidden=true;
    }
    
    self.userImage.layer.masksToBounds=YES;
    self.userImage.layer.cornerRadius=30.0;
    
    NSXMLElement *innerData=[message elementForName:@"data"];
    if ([[innerData attributeStringValueForName:@"from"] isEqualToString:myDelegate.xmppLogedInUserId]) {
//        self.userImage.image=logedInUserPhoto;
        [self getProfileImageUsingJid:[innerData attributeStringValueForName:@"from"] cellImage:self.userImage];
        self.nameLabel.textColor=[UIColor colorWithRed:101.0/255.0 green:123.0/255.0 blue:227.0/255.0 alpha:1.0];
    }
    else {
//        self.userImage.image=friendUserPhoto;
        [self getProfileImageUsingJid:[innerData attributeStringValueForName:@"from"] cellImage:self.userImage];
        self.nameLabel.textColor=[memberColor objectForKey:[innerData attributeStringValueForName:@"from"]];
    }
    
    self.nameLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.attachedImageView.translatesAutoresizingMaskIntoConstraints=YES;
    
    self.nameLabel.numberOfLines=0;
    self.messageLabel.numberOfLines=0;
    
    self.nameLabel.text=[[innerData attributeStringValueForName:@"senderName"] capitalizedString];
    self.messageLabel.text=[[message elementForName:@"body"] stringValue];
    
    self.nameLabel.frame=CGRectMake(76, 5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"nameHeight"] floatValue]); //Here frame = (Namelabel_x_Space, NameLabel_TopSpace, screenWidth - (Namelabel_x_Space + Namelabel_trailingSpace), NameHeight)
    
    if ([chatType isEqualToString:@"ImageAttachment"]||[chatType isEqualToString:@"FileAttachment"]||[chatType isEqualToString:@"Location"]) {
        self.attachedImageView.frame=CGRectMake(76, (5+[[innerData attributeStringValueForName:@"nameHeight"] floatValue]+5), 200, 128); //Here frame = (AttachedImage_x_Space, (NameLabel_TopSpace + NameLabel_Height + space_Between_NameLabel_And_AttachedImage), AttachedImage_width, AttachedImage_height
        if ([chatType isEqualToString:@"FileAttachment"]) {
            
            self.attachedImageView.image=[UIImage imageNamed:@"pdf_placeholder.png"];
            [myDelegate getThumbnailImagePDF:[innerData attributeStringValueForName:@"fileName"] result:^(UIImage *tempImage) {
                // do something with your BOOL
                self.attachedImageView.image=tempImage;
            }];
        }
        else if ([chatType isEqualToString:@"Location"]) {
            
            self.attachedImageView.image=[UIImage imageNamed:@"locationPlaceholder.jpg"];
        }
        else {
            self.attachedImageView.image=[UIImage imageWithData:[myDelegate listionSendAttachedImageCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
        }
    }
    else {
        
        self.attachedImageView.frame=CGRectMake(76, (5+[[innerData attributeStringValueForName:@"nameHeight"] floatValue]+5), 200, 0); //Here frame = (AttachedImage_x_Space, (NameLabel_TopSpace + NameLabel_Height + space_Between_NameLabel_And_AttachedImage), AttachedImage_width, AttachedImage_height
    }
    
    self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
    
    self.dateLabel.text=[self changeTimeFormat:[innerData attributeStringValueForName:@"time"]];
}

- (void)displayMultipleMessage:(NSXMLElement *)currentMessage nextmessage:(NSXMLElement *)nextmessage previousMessage:(NSXMLElement *)previousMessage profileImageView:(UIImage *)logedInUserPhoto chatType:(NSString *)chatType memberColor:(NSMutableDictionary *)memberColor {
    
    //Unhide/hide all objects
    self.userImage.hidden=true;
    self.nameLabel.hidden=true;
    self.messageLabel.hidden=false;
    self.dateLabel.hidden=false;
    self.separatorLabel.hidden=true;
    self.halfSeparatorLabel.hidden=true;
    
    if ([chatType isEqualToString:@"ImageAttachment"]||[chatType isEqualToString:@"FileAttachment"]||[chatType isEqualToString:@"Location"]) {
        self.attachedImageView.hidden=false;
    }
    else {
        
        self.attachedImageView.hidden=true;
    }
    
    NSXMLElement *innerData=[currentMessage elementForName:@"data"];
    NSXMLElement *innerData1=[nextmessage elementForName:@"data"];
    NSXMLElement *innerData2=[previousMessage elementForName:@"data"];
    
    if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData2 attributeStringValueForName:@"from"]] && [[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
        
        self.halfSeparatorLabel.hidden=false;
        self.messageLabel.translatesAutoresizingMaskIntoConstraints=YES;
        self.attachedImageView.translatesAutoresizingMaskIntoConstraints=YES;
        self.messageLabel.numberOfLines=0;
        self.messageLabel.text=[[currentMessage elementForName:@"body"] stringValue];
        
        if ([chatType isEqualToString:@"ImageAttachment"]||[chatType isEqualToString:@"FileAttachment"]||[chatType isEqualToString:@"Location"]) {
            self.attachedImageView.frame=CGRectMake(76, 5, 200, 128); //Here frame = (AttachedImage_x_Space, attachedImageView_TopSpace, AttachedImage_width, AttachedImage_height
            
            if ([chatType isEqualToString:@"FileAttachment"]) {
                
                self.attachedImageView.image=[UIImage imageNamed:@"pdf_placeholder.png"];
                [myDelegate getThumbnailImagePDF:[innerData attributeStringValueForName:@"fileName"] result:^(UIImage *tempImage) {
                    // do something with your BOOL
                    self.attachedImageView.image=tempImage;
                }];
            }
            else if ([chatType isEqualToString:@"Location"]) {
                
                self.attachedImageView.image=[UIImage imageNamed:@"locationPlaceholder.jpg"];
            }
            else {
                self.attachedImageView.image=[UIImage imageWithData:[myDelegate listionSendAttachedImageCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
            }
        }
        else {
            
            self.attachedImageView.frame=CGRectMake(76, 5, 200, 0); //Here frame = (AttachedImage_x_Space, (NameLabel_TopSpace + NameLabel_Height + space_Between_NameLabel_And_AttachedImage), AttachedImage_width, AttachedImage_height
        }
        
        self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
    }
    else if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData2 attributeStringValueForName:@"from"]] && ![[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
        
        self.separatorLabel.hidden=false;
        self.messageLabel.translatesAutoresizingMaskIntoConstraints=YES;
        self.attachedImageView.translatesAutoresizingMaskIntoConstraints=YES;
        self.messageLabel.numberOfLines=0;
        self.messageLabel.text=[[currentMessage elementForName:@"body"] stringValue];
        
        if ([chatType isEqualToString:@"ImageAttachment"]||[chatType isEqualToString:@"FileAttachment"]||[chatType isEqualToString:@"Location"]) {
            self.attachedImageView.frame=CGRectMake(76, 5, 200, 128); //Here frame = (AttachedImage_x_Space, attachedImageView_TopSpace, AttachedImage_width, AttachedImage_height
            if ([chatType isEqualToString:@"FileAttachment"]) {
                
                self.attachedImageView.image=[UIImage imageNamed:@"pdf_placeholder.png"];
                [myDelegate getThumbnailImagePDF:[innerData attributeStringValueForName:@"fileName"] result:^(UIImage *tempImage) {
                    // do something with your BOOL
                    self.attachedImageView.image=tempImage;
                }];
            }
            else if ([chatType isEqualToString:@"Location"]) {
                
                self.attachedImageView.image=[UIImage imageNamed:@"locationPlaceholder.jpg"];
            }
            else {
                self.attachedImageView.image=[UIImage imageWithData:[myDelegate listionSendAttachedImageCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
            }
        }
        else {
            
            self.attachedImageView.frame=CGRectMake(76, 5, 200, 0); //Here frame = (AttachedImage_x_Space, (NameLabel_TopSpace + NameLabel_Height + space_Between_NameLabel_And_AttachedImage), AttachedImage_width, AttachedImage_height
        }
        
        self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
    }
    else /*if (![[currentMessage attributeStringValueForName:@"from"] isEqualToString:[previousMessage attributeStringValueForName:@"from"]] && [[currentMessage attributeStringValueForName:@"from"] isEqualToString:[nextmessage attributeStringValueForName:@"from"]])*/ {
        
        [self displayFirstMessage:currentMessage nextmessage:nextmessage profileImageView:logedInUserPhoto chatType:chatType memberColor:memberColor];
    }
    self.dateLabel.text=[self changeTimeFormat:[innerData attributeStringValueForName:@"time"]];
}

- (void)displayLastMessage:(NSXMLElement *)currentMessage previousMessage:(NSXMLElement *)previousMessage profileImageView:(UIImage *)logedInUserPhoto chatType:(NSString *)chatType memberColor:(NSMutableDictionary *)memberColor {
    
    //Unhide/hide all objects
    self.userImage.hidden=false;
    self.nameLabel.hidden=false;
    self.messageLabel.hidden=false;
    self.dateLabel.hidden=false;
    self.separatorLabel.hidden=true;
    self.halfSeparatorLabel.hidden=true;
    
    if ([chatType isEqualToString:@"ImageAttachment"]||[chatType isEqualToString:@"FileAttachment"]||[chatType isEqualToString:@"Location"]) {
        self.attachedImageView.hidden=false;
    }
    else {
        
        self.attachedImageView.hidden=true;
    }
    
    NSXMLElement *innerData=[currentMessage elementForName:@"data"];
    NSXMLElement *innerData1=[previousMessage elementForName:@"data"];
    
    if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
        
        self.userImage.hidden=true;
        self.nameLabel.hidden=true;
        
        self.messageLabel.translatesAutoresizingMaskIntoConstraints=YES;
        self.attachedImageView.translatesAutoresizingMaskIntoConstraints=YES;
        self.messageLabel.numberOfLines=0;
        NSLog(@"%f %@",[[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue], [innerData attributeStringValueForName:@"messageBodyHeight"]);
        
        if ([chatType isEqualToString:@"ImageAttachment"]||[chatType isEqualToString:@"FileAttachment"]||[chatType isEqualToString:@"Location"]) {
            self.attachedImageView.frame=CGRectMake(76, 5, 200, 128); //Here frame = (AttachedImage_x_Space, attachedImageView_TopSpace, AttachedImage_width, AttachedImage_height
            
            if ([chatType isEqualToString:@"FileAttachment"]) {
                
                self.attachedImageView.image=[UIImage imageNamed:@"pdf_placeholder.png"];
                [myDelegate getThumbnailImagePDF:[innerData attributeStringValueForName:@"fileName"] result:^(UIImage *tempImage) {
                    // do something with your BOOL
                    self.attachedImageView.image=tempImage;
                }];
            }
            else if ([chatType isEqualToString:@"Location"]) {
                
                self.attachedImageView.image=[UIImage imageNamed:@"locationPlaceholder.jpg"];
            }
            else {
                self.attachedImageView.image=[UIImage imageWithData:[myDelegate listionSendAttachedImageCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
            }
        }
        else {
            
            self.attachedImageView.frame=CGRectMake(76, 5, 200, 0); //Here frame = (AttachedImage_x_Space, (NameLabel_TopSpace + NameLabel_Height + space_Between_NameLabel_And_AttachedImage), AttachedImage_width, AttachedImage_height
        }
        
        self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
        self.messageLabel.text=[[currentMessage elementForName:@"body"] stringValue];
    }
    else {
        
        [self displaySingleTypeMessageData:currentMessage profileImageView:logedInUserPhoto chatType:chatType memberColor:memberColor];
    }
    self.dateLabel.text=[self changeTimeFormat:[innerData attributeStringValueForName:@"time"]];
    self.separatorLabel.hidden=false;
}

- (NSString *)changeTimeFormat:(NSString *)timeString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:timeString];
    [dateFormatter setDateFormat:@"hh:mm a"];
    return [dateFormatter stringFromDate:date];
}

- (void)getProfileImageUsingJid:(NSString *)jid cellImage:(UIImageView *)cellImageView {

    __block UIImageView *weakRef = cellImageView;
    [XMPPGroupChatRoom getChatProfilePhotoJid:jid profileImageView:cellImageView placeholderImage:@"images.png" result:^(UIImage *tempImage) {
        
        weakRef.image=tempImage;
    }];
}

@end
