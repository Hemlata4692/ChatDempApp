//
//  DashboardViewController.h
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DashboardXMPP.h"

@interface DashboardViewController : DashboardXMPP

@property(nonatomic,strong) NSMutableDictionary *userDetailedList;
@property(nonatomic,strong) NSMutableArray *userListArray;
@end
