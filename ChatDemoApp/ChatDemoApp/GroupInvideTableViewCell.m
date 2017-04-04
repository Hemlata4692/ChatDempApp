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

- (void)displayContactInformation:(NSMutableDictionary *)contactInfo isSelected:(bool)isSelected isAlreadyAdded:(bool)isAlreadyAdded {

    self.friendProfilePhoto.layer.masksToBounds=YES;
    self.friendProfilePhoto.layer.cornerRadius=20;
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
