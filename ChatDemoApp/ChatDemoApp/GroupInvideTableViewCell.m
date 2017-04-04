//
//  GroupInvideTableViewCell.m
//  ChatDemoApp
//
//  Created by Ranosys on 08/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "GroupInvideTableViewCell.h"

@implementation GroupInvideTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)displayContactInformation:(NSMutableDictionary *)contactInfo isSelected:(bool)isSelected isAlreadyAdded:(bool)isAlreadyAdded presenceStatus:(int)presenceStatus {

    self.friendProfilePhoto.layer.masksToBounds=YES;
    self.friendProfilePhoto.layer.cornerRadius=20;
    self.presenceIndicator.layer.cornerRadius=7;
    self.presenceIndicator.layer.masksToBounds=YES;
    
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

    if(isSelected) {
    
        self.selectedIcon.hidden=NO;
    }
    else {
        
        self.selectedIcon.hidden=YES;
    }
    
    if (isAlreadyAdded) {
        self.alreadyAddedIcon.hidden=NO;
    }
    else {
        self.alreadyAddedIcon.hidden=YES;
    }
    self.friendName.text=[contactInfo objectForKey:@"Name"];
}
@end
