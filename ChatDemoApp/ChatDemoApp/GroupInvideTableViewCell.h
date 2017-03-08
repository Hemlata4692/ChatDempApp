//
//  GroupInvideTableViewCell.h
//  ChatDemoApp
//
//  Created by Ranosys on 08/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupInvideTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *friendProfilePhoto;
@property (strong, nonatomic) IBOutlet UIImageView *selectedIcon;
@property (strong, nonatomic) IBOutlet UILabel *friendName;
@end
