//
//  ChatScreenTableViewCell.m
//  ChatDemoApp
//
//  Created by Ranosys on 14/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "ChatScreenTableViewCell.h"
#import <AVFoundation/AVFoundation.h>

@implementation ChatScreenTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
//FileAttachment
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)displaySingleMessageData:(NSXMLElement *)message profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto chatType:(NSString *)chatType {
    
    [self displaySingleTypeMessageData:message profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto chatType:chatType];
    self.separatorLabel.hidden=false;
}

- (void)displayFirstMessage:(NSXMLElement *)currentMessage nextmessage:(NSXMLElement *)nextmessage profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto chatType:(NSString *)chatType {
    
    [self displaySingleTypeMessageData:currentMessage profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto chatType:chatType];
    NSXMLElement *innerData=[currentMessage elementForName:@"data"];
    NSXMLElement *innerData1=[nextmessage elementForName:@"data"];

    if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
        
        self.halfSeparatorLabel.hidden=false;
    }
    else {
        
        self.separatorLabel.hidden=false;
    }
}

- (void)displaySingleTypeMessageData:(NSXMLElement *)message profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto chatType:(NSString *)chatType {
    
    //Unhide/hide all objects
    self.audioBackView.hidden=true;
    self.playPauseButton.hidden=true;
    self.audioProgress.hidden=true;
    self.audioStartTime.hidden=true;
    self.audioEndTIme.hidden=true;
    self.videoPlayButton.hidden=true;
    
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
    
    if ([chatType isEqualToString:@"VideoAttachment"]) {
        
        self.attachedImageView.hidden=false;
        self.videoPlayButton.hidden=NO;
    }
    
    self.userImage.layer.masksToBounds=YES;
    self.userImage.layer.cornerRadius=30.0;
    
    NSXMLElement *innerData=[message elementForName:@"data"];
    if ([[innerData attributeStringValueForName:@"from"] isEqualToString:myDelegate.xmppLogedInUserId]) {
        self.userImage.image=logedInUserPhoto;
        self.nameLabel.textColor=[UIColor colorWithRed:101.0/255.0 green:123.0/255.0 blue:227.0/255.0 alpha:1.0];
    }
    else {
        self.userImage.image=friendUserPhoto;
        self.nameLabel.textColor=[UIColor colorWithRed:227.0/255.0 green:77.0/255.0 blue:75.0/255.0 alpha:1.0];
    }
    
    self.nameLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints=YES;
    self.attachedImageView.translatesAutoresizingMaskIntoConstraints=YES;
    
    self.nameLabel.numberOfLines=0;
    self.messageLabel.numberOfLines=0;
    
    NSString *nameString;
    if (![[innerData attributeStringValueForName:@"from"] isEqualToString:[NSString stringWithFormat:@"%@",myDelegate.xmppLogedInUserId]]) {
        
        nameString=[innerData attributeStringValueForName:@"senderName"];
    }
    else {
        
        nameString=@"You";
    }
    self.nameLabel.text=[nameString capitalizedString];
    
//    self.nameLabel.text=[[innerData attributeStringValueForName:@"senderName"] capitalizedString];
    if (![chatType isEqualToString:@"AudioAttachment"]&&![chatType isEqualToString:@"VideoAttachment"]) {
        
        self.messageLabel.text=[[message elementForName:@"body"] stringValue];
    }
    else {
    
        self.messageLabel.hidden=YES;
    }
    
    self.nameLabel.frame=CGRectMake(76, 5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"nameHeight"] floatValue]); //Here frame = (Namelabel_x_Space, NameLabel_TopSpace, screenWidth - (Namelabel_x_Space + Namelabel_trailingSpace), NameHeight)

    self.attachedImageView.backgroundColor=[UIColor clearColor];
    self.attachedImageView.layer.cornerRadius=0;
    self.attachedImageView.layer.masksToBounds=YES;
    self.attachedImageView.contentMode=UIViewContentModeScaleToFill;
    
    if ([chatType isEqualToString:@"ImageAttachment"]||[chatType isEqualToString:@"FileAttachment"]||[chatType isEqualToString:@"Location"]||[chatType isEqualToString:@"VideoAttachment"]) {
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
            
            self.attachedImageView.backgroundColor=[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
            self.attachedImageView.layer.cornerRadius=8;
            self.attachedImageView.layer.masksToBounds=YES;
            self.attachedImageView.contentMode=UIViewContentModeScaleAspectFit;
            
            if ([chatType isEqualToString:@"VideoAttachment"]) {
                
                self.videoPlayButton.translatesAutoresizingMaskIntoConstraints=YES;
                self.videoPlayButton.frame=CGRectMake(76+(self.attachedImageView.frame.size.width/2.0)-20, (5+[[innerData attributeStringValueForName:@"nameHeight"] floatValue]+5)+(self.attachedImageView.frame.size.height/2.0)-20, 40, 40);
                self.attachedImageView.image=[self getThumbnailVideoImage:[myDelegate videoPathDocumentCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
            }
            else {
                
                self.videoPlayButton.translatesAutoresizingMaskIntoConstraints=YES;
                self.videoPlayButton.frame=CGRectMake(76+(self.attachedImageView.frame.size.width/2.0)-20, (5+[[innerData attributeStringValueForName:@"nameHeight"] floatValue]+5)+(self.attachedImageView.frame.size.height/2.0)-20, 40, 40);
                self.attachedImageView.image=[UIImage imageWithData:[myDelegate listionSendAttachedImageCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
            }
        }
    }
    else {
        
        self.attachedImageView.frame=CGRectMake(76, (5+[[innerData attributeStringValueForName:@"nameHeight"] floatValue]+5), 200, 0); //Here frame = (AttachedImage_x_Space, (NameLabel_TopSpace + NameLabel_Height + space_Between_NameLabel_And_AttachedImage), AttachedImage_width, AttachedImage_height
    }
    
    if (![chatType isEqualToString:@"AudioAttachment"]&&![chatType isEqualToString:@"VideoAttachment"]) {
        
        self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
    }
    else if ([chatType isEqualToString:@"VideoAttachment"]) {
        
        self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), 0); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
    }
    else {
        
        self.audioBackView.translatesAutoresizingMaskIntoConstraints=true;
        self.playPauseButton.translatesAutoresizingMaskIntoConstraints=true;
        self.audioProgress.translatesAutoresizingMaskIntoConstraints=true;
        self.audioStartTime.translatesAutoresizingMaskIntoConstraints=true;
        self.audioEndTIme.translatesAutoresizingMaskIntoConstraints=true;
        
        self.audioBackView.hidden=false;
        self.playPauseButton.hidden=false;
        self.audioProgress.hidden=false;
        self.audioStartTime.hidden=false;
        self.audioEndTIme.hidden=false;
        
        self.audioBackView.frame=CGRectMake(76, (5+[[innerData attributeStringValueForName:@"nameHeight"] floatValue]+5), [[UIScreen mainScreen] bounds].size.width-86, 48);
        self.playPauseButton.frame=CGRectMake(8,6,36,36);
        self.audioProgress.frame=CGRectMake(50,23,self.audioBackView.frame.size.width-50-8,2);
        self.audioStartTime.frame=CGRectMake(50,27,40,16);
        self.audioEndTIme.frame=CGRectMake(self.audioBackView.frame.size.width-8-40,27,40,16);
        self.audioEndTIme.text=(([[innerData attributeStringValueForName:@"timeDuration"] isEqualToString:@""]||(nil==[innerData attributeStringValueForName:@"timeDuration"]))?@"00:00":[innerData attributeStringValueForName:@"timeDuration"]);
        
        self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), 0); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
    }
    self.dateLabel.text=[self changeTimeFormat:[innerData attributeStringValueForName:@"time"]];
}

- (void)displayMultipleMessage:(NSXMLElement *)currentMessage nextmessage:(NSXMLElement *)nextmessage previousMessage:(NSXMLElement *)previousMessage profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto chatType:(NSString *)chatType {
    
    //Unhide/hide all objects
    self.audioBackView.hidden=true;
    self.playPauseButton.hidden=true;
    self.audioProgress.hidden=true;
    self.audioStartTime.hidden=true;
    self.audioEndTIme.hidden=true;
    self.videoPlayButton.hidden=true;
    
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
    
    if ([chatType isEqualToString:@"VideoAttachment"]) {
        
        self.attachedImageView.hidden=false;
        self.videoPlayButton.hidden=NO;
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
        
        self.attachedImageView.backgroundColor=[UIColor clearColor];
        self.attachedImageView.layer.cornerRadius=0;
        self.attachedImageView.layer.masksToBounds=YES;
        self.attachedImageView.contentMode=UIViewContentModeScaleToFill;
        
        if ([chatType isEqualToString:@"ImageAttachment"]||[chatType isEqualToString:@"FileAttachment"]||[chatType isEqualToString:@"Location"]||[chatType isEqualToString:@"VideoAttachment"]) {
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
                self.attachedImageView.backgroundColor=[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
                self.attachedImageView.layer.cornerRadius=8;
                self.attachedImageView.layer.masksToBounds=YES;
                self.attachedImageView.contentMode=UIViewContentModeScaleAspectFit;
                
                if ([chatType isEqualToString:@"VideoAttachment"]) {
                    
                    self.videoPlayButton.translatesAutoresizingMaskIntoConstraints=YES;
                    self.videoPlayButton.frame=CGRectMake(76+(self.attachedImageView.frame.size.width/2.0)-20, 5.0+(self.attachedImageView.frame.size.height/2.0)-20, 40, 40);
                    
                    self.attachedImageView.image=[self getThumbnailVideoImage:[myDelegate videoPathDocumentCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
                }
                else {
                    self.attachedImageView.image=[UIImage imageWithData:[myDelegate listionSendAttachedImageCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
                }
            }
        }
        else {
            
            self.attachedImageView.frame=CGRectMake(76, 5, 200, 0); //Here frame = (AttachedImage_x_Space, (NameLabel_TopSpace + NameLabel_Height + space_Between_NameLabel_And_AttachedImage), AttachedImage_width, AttachedImage_height
        }
        
        if (![chatType isEqualToString:@"AudioAttachment"]&&![chatType isEqualToString:@"VideoAttachment"]) {
            
            self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
        }
        else if ([chatType isEqualToString:@"VideoAttachment"]) {
            
            self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), 0); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
        }
        else {
            
            self.audioBackView.translatesAutoresizingMaskIntoConstraints=true;
            self.playPauseButton.translatesAutoresizingMaskIntoConstraints=true;
            self.audioProgress.translatesAutoresizingMaskIntoConstraints=true;
            self.audioStartTime.translatesAutoresizingMaskIntoConstraints=true;
            self.audioEndTIme.translatesAutoresizingMaskIntoConstraints=true;
            
            self.audioBackView.hidden=false;
            self.playPauseButton.hidden=false;
            self.audioProgress.hidden=false;
            self.audioStartTime.hidden=false;
            self.audioEndTIme.hidden=false;
            
            self.audioBackView.frame=CGRectMake(76, 5, [[UIScreen mainScreen] bounds].size.width-86, 48);
            self.playPauseButton.frame=CGRectMake(8,6,36,36);
            self.audioProgress.frame=CGRectMake(50,23,self.audioBackView.frame.size.width-50-8,2);
            self.audioStartTime.frame=CGRectMake(50,27,40,16);
            self.audioEndTIme.frame=CGRectMake(self.audioBackView.frame.size.width-8-40,27,40,16);
            self.audioEndTIme.text=(([[innerData attributeStringValueForName:@"timeDuration"] isEqualToString:@""]||(nil==[innerData attributeStringValueForName:@"timeDuration"]))?@"00:00":[innerData attributeStringValueForName:@"timeDuration"]);
            
            self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), 0); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
        }
    }
    else if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData2 attributeStringValueForName:@"from"]] && ![[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
        
        self.separatorLabel.hidden=false;
        self.messageLabel.translatesAutoresizingMaskIntoConstraints=YES;
        self.attachedImageView.translatesAutoresizingMaskIntoConstraints=YES;
        self.messageLabel.numberOfLines=0;
        self.messageLabel.text=[[currentMessage elementForName:@"body"] stringValue];
        
        self.attachedImageView.backgroundColor=[UIColor clearColor];
        self.attachedImageView.layer.cornerRadius=0;
        self.attachedImageView.layer.masksToBounds=YES;
        self.attachedImageView.contentMode=UIViewContentModeScaleToFill;
        
        if ([chatType isEqualToString:@"ImageAttachment"]||[chatType isEqualToString:@"FileAttachment"]||[chatType isEqualToString:@"Location"]||[chatType isEqualToString:@"VideoAttachment"]) {
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
                
                self.attachedImageView.backgroundColor=[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
                self.attachedImageView.layer.cornerRadius=8;
                self.attachedImageView.layer.masksToBounds=YES;
                self.attachedImageView.contentMode=UIViewContentModeScaleAspectFit;
                
                if ([chatType isEqualToString:@"VideoAttachment"]) {
                    
                    self.videoPlayButton.translatesAutoresizingMaskIntoConstraints=YES;
                    self.videoPlayButton.frame=CGRectMake(76+(self.attachedImageView.frame.size.width/2.0)-20, 5.0+(self.attachedImageView.frame.size.height/2.0)-20, 40, 40);
                    self.attachedImageView.image=[self getThumbnailVideoImage:[myDelegate videoPathDocumentCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
                }
                else {
                    self.attachedImageView.image=[UIImage imageWithData:[myDelegate listionSendAttachedImageCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
                }
            }
        }
        else {
            
            self.attachedImageView.frame=CGRectMake(76, 5, 200, 0); //Here frame = (AttachedImage_x_Space, (NameLabel_TopSpace + NameLabel_Height + space_Between_NameLabel_And_AttachedImage), AttachedImage_width, AttachedImage_height
        }
        
        if (![chatType isEqualToString:@"AudioAttachment"]&&![chatType isEqualToString:@"VideoAttachment"]) {
            
            self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
        }
        else if ([chatType isEqualToString:@"VideoAttachment"]) {
            
            self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), 0); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
        }
        else {
            
            self.audioBackView.translatesAutoresizingMaskIntoConstraints=true;
            self.playPauseButton.translatesAutoresizingMaskIntoConstraints=true;
            self.audioProgress.translatesAutoresizingMaskIntoConstraints=true;
            self.audioStartTime.translatesAutoresizingMaskIntoConstraints=true;
            self.audioEndTIme.translatesAutoresizingMaskIntoConstraints=true;
            
            self.audioBackView.hidden=false;
            self.playPauseButton.hidden=false;
            self.audioProgress.hidden=false;
            self.audioStartTime.hidden=false;
            self.audioEndTIme.hidden=false;
            
            self.audioBackView.frame=CGRectMake(76, 5, [[UIScreen mainScreen] bounds].size.width-86, 48);
            self.playPauseButton.frame=CGRectMake(8,6,36,36);
            self.audioProgress.frame=CGRectMake(50,23,self.audioBackView.frame.size.width-50-8,2);
            self.audioStartTime.frame=CGRectMake(50,27,40,16);
            self.audioEndTIme.frame=CGRectMake(self.audioBackView.frame.size.width-8-40,27,40,16);
            self.audioEndTIme.text=(([[innerData attributeStringValueForName:@"timeDuration"] isEqualToString:@""]||(nil==[innerData attributeStringValueForName:@"timeDuration"]))?@"00:00":[innerData attributeStringValueForName:@"timeDuration"]);
            
            self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), 0); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
        }
    }
    else /*if (![[currentMessage attributeStringValueForName:@"from"] isEqualToString:[previousMessage attributeStringValueForName:@"from"]] && [[currentMessage attributeStringValueForName:@"from"] isEqualToString:[nextmessage attributeStringValueForName:@"from"]])*/ {
        
        [self displayFirstMessage:currentMessage nextmessage:nextmessage profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto chatType:chatType];
    }
    self.dateLabel.text=[self changeTimeFormat:[innerData attributeStringValueForName:@"time"]];
}

- (void)displayLastMessage:(NSXMLElement *)currentMessage previousMessage:(NSXMLElement *)previousMessage profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto chatType:(NSString *)chatType {
    
    //Unhide/hide all objects
    self.audioBackView.hidden=true;
    self.playPauseButton.hidden=true;
    self.audioProgress.hidden=true;
    self.audioStartTime.hidden=true;
    self.audioEndTIme.hidden=true;
    self.videoPlayButton.hidden=true;
    
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
    
    if ([chatType isEqualToString:@"VideoAttachment"]) {
        
        self.attachedImageView.hidden=false;
        self.videoPlayButton.hidden=NO;
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
        self.messageLabel.text=[[currentMessage elementForName:@"body"] stringValue];
        
        self.attachedImageView.backgroundColor=[UIColor clearColor];
        self.attachedImageView.layer.cornerRadius=0;
        self.attachedImageView.layer.masksToBounds=YES;
        self.attachedImageView.contentMode=UIViewContentModeScaleToFill;
        
        if ([chatType isEqualToString:@"ImageAttachment"]||[chatType isEqualToString:@"FileAttachment"]||[chatType isEqualToString:@"Location"]||[chatType isEqualToString:@"VideoAttachment"]) {
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
                self.attachedImageView.backgroundColor=[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
                self.attachedImageView.layer.cornerRadius=8;
                self.attachedImageView.layer.masksToBounds=YES;
                self.attachedImageView.contentMode=UIViewContentModeScaleAspectFit;
                
                if ([chatType isEqualToString:@"VideoAttachment"]) {
                    
                    self.videoPlayButton.translatesAutoresizingMaskIntoConstraints=YES;
                    self.videoPlayButton.frame=CGRectMake(76+(self.attachedImageView.frame.size.width/2.0)-20, 5.0+(self.attachedImageView.frame.size.height/2.0)-20, 40, 40);
                    
                    self.attachedImageView.image=[self getThumbnailVideoImage:[myDelegate videoPathDocumentCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
                }
                else {
                    self.attachedImageView.image=[UIImage imageWithData:[myDelegate listionSendAttachedImageCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
                }
                
            }
        }
        else {
            
            self.attachedImageView.frame=CGRectMake(76, 5, 200, 0); //Here frame = (AttachedImage_x_Space, (NameLabel_TopSpace + NameLabel_Height + space_Between_NameLabel_And_AttachedImage), AttachedImage_width, AttachedImage_height
        }
        
        if (![chatType isEqualToString:@"AudioAttachment"]&&![chatType isEqualToString:@"VideoAttachment"]) {
            
            self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
        }
        else if ([chatType isEqualToString:@"VideoAttachment"]) {
            
            self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), 0); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
        }
        else {
            
            self.audioBackView.translatesAutoresizingMaskIntoConstraints=true;
            self.playPauseButton.translatesAutoresizingMaskIntoConstraints=true;
            self.audioProgress.translatesAutoresizingMaskIntoConstraints=true;
            self.audioStartTime.translatesAutoresizingMaskIntoConstraints=true;
            self.audioEndTIme.translatesAutoresizingMaskIntoConstraints=true;
            
            self.audioBackView.hidden=false;
            self.playPauseButton.hidden=false;
            self.audioProgress.hidden=false;
            self.audioStartTime.hidden=false;
            self.audioEndTIme.hidden=false;
            
            self.audioBackView.frame=CGRectMake(76, 5, [[UIScreen mainScreen] bounds].size.width-86, 48);
            self.playPauseButton.frame=CGRectMake(8,6,36,36);
            self.audioProgress.frame=CGRectMake(50,23,self.audioBackView.frame.size.width-50-8,2);
            self.audioStartTime.frame=CGRectMake(50,27,40,16);
            self.audioEndTIme.frame=CGRectMake(self.audioBackView.frame.size.width-8-40,27,40,16);
            self.audioEndTIme.text=(([[innerData attributeStringValueForName:@"timeDuration"] isEqualToString:@""]||(nil==[innerData attributeStringValueForName:@"timeDuration"]))?@"00:00":[innerData attributeStringValueForName:@"timeDuration"]);
            
            self.messageLabel.frame=CGRectMake(76, self.attachedImageView.frame.origin.y + self.attachedImageView.frame.size.height+5, [[UIScreen mainScreen] bounds].size.width - (76+8), 0); //Here frame = (MessageLabel_x_Space, (attachedImageView_TopSpace + attachedImageView_Height + space_Between_attachedImageView_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
        }
    }
    else {
        
        [self displaySingleTypeMessageData:currentMessage profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto chatType:chatType];
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

- (UIImage*)getThumbnailVideoImage:(NSString *)videoFilePath {
    //get thumbnail image from video
    NSURL *videoURl = [NSURL fileURLWithPath:videoFilePath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURl options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 2);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    return [[UIImage alloc] initWithCGImage:imgRef];
}
@end
