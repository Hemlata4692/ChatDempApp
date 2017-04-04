//
//  DashboardTableViewCell.h
//  ChatDemoApp
//
//  Created by Ranosys on 03/04/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashboardTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIButton *profileBtn;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *badgeLabel;

- (void)displayContactListUserData:(NSMutableDictionary *)userProfileData jid:(NSString *)jid index:(int)index;
- (void)displayHistoryListUserData:(NSXMLElement *)historyElement index:(int)index;
- (void)displayGroupListData:(NSMutableDictionary *)groupDataDic;
@end
