//
//  SettingViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 23/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingTableViewCell.h"

@interface SettingViewController () {

    NSArray *tableViewArray, *tableViewIconArray;
}

@property (strong, nonatomic) IBOutlet UITableView *settingTableView;
@end

@implementation SettingViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"Settings";
    tableViewArray=@[@"Account"];
    [self addBackBarButton];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBackBarButton {
    
    UIBarButtonItem *backBarButton;
    CGRect framing = CGRectMake(0, 0, 25, 25);
    
    UIButton *back = [[UIButton alloc] initWithFrame:framing];
    [back setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backBarButton =[[UIBarButtonItem alloc] initWithCustomView:back];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=backBarButton;
}
#pragma mark - end

#pragma mark - Tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView * headerView;
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 80.0)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIImageView * userImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 50, 50)];
    UILabel * userName = [[UILabel alloc] initWithFrame:CGRectMake(userImage.frame.origin.x+userImage.frame.size.width+8, userImage.frame.origin.y, headerView.frame.size.width - (userImage.frame.origin.x+userImage.frame.size.width+8)-8, 25)];
    UILabel * userStatus = [[UILabel alloc] initWithFrame:CGRectMake(userImage.frame.origin.x+userImage.frame.size.width+8, userImage.frame.origin.y+userName.frame.size.height, headerView.frame.size.width - (userImage.frame.origin.x+userImage.frame.size.width+8)-8, 25)];
    UILabel * separator = [[UILabel alloc] initWithFrame:CGRectMake(0, 79, headerView.frame.size.width, 1)];
    
    userName.backgroundColor = [UIColor clearColor];
    userName.textColor = [UIColor blackColor];
    userName.font = [UIFont systemFontOfSize:17.0];
    userName.text = @"";
    
    userStatus.backgroundColor = [UIColor clearColor];
    userStatus.textColor = [UIColor darkGrayColor];
    userStatus.font = [UIFont systemFontOfSize:15.0];
    userStatus.text = @"";
    
    separator.backgroundColor = [UIColor lightGrayColor];
    
    userImage.layer.masksToBounds=YES;
    userImage.layer.cornerRadius=25;
    userImage.contentMode=UIViewContentModeScaleToFill;
    
    [self getProfileData:myDelegate.xmppLogedInUserId result:^(NSDictionary *tempProfileData) {
        // do something with your BOOL
        
        userName.text=[tempProfileData objectForKey:@"Name"];
        userStatus.text=[tempProfileData objectForKey:@"UserStatus"];
    }];
    
    [self getProfilePhotosJid:myDelegate.xmppLogedInUserId profileImageView:userImage placeholderImage:@"images.png" result:^(UIImage *tempImage) {
        // do something with your BOOL
        if (tempImage!=nil) {
            userImage.image=tempImage;
        }
        else {
            
            userImage.image=[UIImage imageNamed:@"images.png"];
        }
    }];
    
    [headerView addSubview:userName];
    [headerView addSubview:userStatus];
    [headerView addSubview:userImage];
    [headerView addSubview:separator];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return tableViewArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingTableViewCell *cell;
    NSString *simpleTableIdentifier = @"cell";
    cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[SettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.settingTitle.text=[tableViewArray objectAtIndex:indexPath.row];
    return cell;
}
#pragma mark - end

#pragma mark - UIButton actions
- (void)backAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - end
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
