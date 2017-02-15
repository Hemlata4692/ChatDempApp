//
//  ChatScreenTableViewCell.m
//  ChatDemoApp
//
//  Created by Ranosys on 14/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "ChatScreenTableViewCell.h"

@implementation ChatScreenTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)displaySingleMessageData:(NSXMLElement *)message profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto {
    
    [self displaySingleTypeMessageData:message profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto];
    self.separatorLabel.hidden=false;
}

- (void)displayFirstMessage:(NSXMLElement *)currentMessage nextmessage:(NSXMLElement *)nextmessage profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto {
    
    [self displaySingleTypeMessageData:currentMessage profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto];
    NSXMLElement *innerData=[currentMessage elementForName:@"data"];
    NSXMLElement *innerData1=[nextmessage elementForName:@"data"];

    if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
        
        self.halfSeparatorLabel.hidden=false;
    }
    else {
        
        self.separatorLabel.hidden=false;
    }
}

- (void)displaySingleTypeMessageData:(NSXMLElement *)message profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto {
    
    //Unhide/hide all objects
    self.userImage.hidden=false;
    self.nameLabel.hidden=false;
    self.messageLabel.hidden=false;
    self.dateLabel.hidden=false;
    self.separatorLabel.hidden=true;
    self.halfSeparatorLabel.hidden=true;
    
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
    //    self.dateLabel.translatesAutoresizingMaskIntoConstraints=YES;
    
    self.nameLabel.numberOfLines=0;
    self.messageLabel.numberOfLines=0;
    
    self.nameLabel.text=[[innerData attributeStringValueForName:@"senderName"] capitalizedString];
    self.messageLabel.text=[[message elementForName:@"body"] stringValue];
    
    self.nameLabel.frame=CGRectMake(76, 5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"nameHeight"] floatValue]); //Here frame = (Namelabel_x_Space, NameLabel_TopSpace, screenWidth - (Namelabel_x_Space + Namelabel_trailingSpace), NameHeight)
    self.messageLabel.frame=CGRectMake(76, (5+[[innerData attributeStringValueForName:@"nameHeight"] floatValue]+10), [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]); //Here frame = (MessageLabel_x_Space, (NameLabel_TopSpace + NameLabel_Height + space_Between_NameLabel_And_MessageLabel), screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
    
    self.dateLabel.text=[self changeTimeFormat:[innerData attributeStringValueForName:@"time"]];
}

- (void)displayMultipleMessage:(NSXMLElement *)currentMessage nextmessage:(NSXMLElement *)nextmessage previousMessage:(NSXMLElement *)previousMessage profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto {
    
    //Unhide/hide all objects
    self.userImage.hidden=true;
    self.nameLabel.hidden=true;
    self.messageLabel.hidden=false;
    self.dateLabel.hidden=false;
    self.separatorLabel.hidden=true;
    self.halfSeparatorLabel.hidden=true;
    
    NSXMLElement *innerData=[currentMessage elementForName:@"data"];
    NSXMLElement *innerData1=[nextmessage elementForName:@"data"];
    NSXMLElement *innerData2=[previousMessage elementForName:@"data"];
    
    if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData2 attributeStringValueForName:@"from"]] && [[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
        
        self.halfSeparatorLabel.hidden=false;
        self.messageLabel.translatesAutoresizingMaskIntoConstraints=YES;
        self.messageLabel.numberOfLines=0;
        self.messageLabel.text=[[[currentMessage elementForName:@"body"] stringValue] capitalizedString];
        self.messageLabel.frame=CGRectMake(76, 5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]); //Here frame = (MessageLabel_x_Space, MessageLabel_TopSpace, screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
    }
    else if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData2 attributeStringValueForName:@"from"]] && ![[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
        
        self.separatorLabel.hidden=false;
        self.messageLabel.translatesAutoresizingMaskIntoConstraints=YES;
        self.messageLabel.numberOfLines=0;
        self.messageLabel.text=[[[currentMessage elementForName:@"body"] stringValue] capitalizedString];
        self.messageLabel.frame=CGRectMake(76, 5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]); //Here frame = (MessageLabel_x_Space, MessageLabel_TopSpace, screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
    }
    else /*if (![[currentMessage attributeStringValueForName:@"from"] isEqualToString:[previousMessage attributeStringValueForName:@"from"]] && [[currentMessage attributeStringValueForName:@"from"] isEqualToString:[nextmessage attributeStringValueForName:@"from"]])*/ {
        
        [self displayFirstMessage:currentMessage nextmessage:nextmessage profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto];
    }
    self.dateLabel.text=[self changeTimeFormat:[innerData attributeStringValueForName:@"time"]];
}

- (void)displayLastMessage:(NSXMLElement *)currentMessage previousMessage:(NSXMLElement *)previousMessage profileImageView:(UIImage *)logedInUserPhoto friendProfileImageView:(UIImage *)friendUserPhoto {
    
    //Unhide/hide all objects
    self.userImage.hidden=false;
    self.nameLabel.hidden=false;
    self.messageLabel.hidden=false;
    self.dateLabel.hidden=false;
    self.separatorLabel.hidden=true;
    self.halfSeparatorLabel.hidden=true;
    
    NSXMLElement *innerData=[currentMessage elementForName:@"data"];
    NSXMLElement *innerData1=[previousMessage elementForName:@"data"];
    
    if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
        
        self.userImage.hidden=true;
        self.nameLabel.hidden=true;
        
        self.messageLabel.translatesAutoresizingMaskIntoConstraints=YES;
        self.messageLabel.numberOfLines=0;
        NSLog(@"%f %@",[[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue], [innerData attributeStringValueForName:@"messageBodyHeight"]);
        self.messageLabel.frame=CGRectMake(76, 5, [[UIScreen mainScreen] bounds].size.width - (76+8), [[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]); //Here frame = (MessageLabel_x_Space, MessageLabel_TopSpace, screenWidth - (MessageLabel_x_Space + MessageLabel_trailingSpace), MessageLabelHeight
        self.messageLabel.text=[[[currentMessage elementForName:@"body"] stringValue] capitalizedString];
    }
    else {
        
        [self displaySingleTypeMessageData:currentMessage profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto];
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
@end
