//
//  UserProfileViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 02/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "UserProfileViewController.h"

@interface UserProfileViewController () {

    NSDictionary *friendProfileDic;
}

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *userStatus;
@property (strong, nonatomic) IBOutlet UILabel *phoneNumber;
@property (strong, nonatomic) IBOutlet UILabel *presenceStatus;
@end

@implementation UserProfileViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"Contact Info";
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self initializeFriendProfile:self.friendId];
    UIImage *tempPhoto=[self getFriendProfilePhoto:self.friendId];
    if (tempPhoto!=nil) {
        self.profileImage.image=tempPhoto;
    }
    else {
    
        self.profileImage.image=[UIImage imageNamed:@"images.png"];
    }
    
    _presenceStatus.hidden=YES;
    switch ([self getFriendPresenceStatus:self.friendId]) {
        case 0:     // online/available
            _presenceStatus.backgroundColor=[UIColor greenColor];
            break;
        default:    //offline
            _presenceStatus.backgroundColor=[UIColor redColor];
            break;
    }
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    dispatch_async(queue, ^{
        
        friendProfileDic=[self getFriendProfileData:self.friendId];
        dispatch_async(dispatch_get_main_queue(), ^{
           
            self.userName.text=[friendProfileDic objectForKey:@"Name"];
            self.userStatus.text=[friendProfileDic objectForKey:@"PhoneNumber"];
            self.phoneNumber.text=[friendProfileDic objectForKey:@"UserStatus"];
            
            NSLog(@" Desc:%@ \n address:%@ \n emailid:%@ \n birthDay:%@ \n gender:%@",[friendProfileDic objectForKey:@"Description"],[friendProfileDic objectForKey:@"Address"],[friendProfileDic objectForKey:@"EmailAddress"],[friendProfileDic objectForKey:@"UserBirthDay"],[friendProfileDic objectForKey:@"Gender"]);
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

- (void)XmppUserPresenceUpdateNotify {

    switch ([self getFriendPresenceStatus:self.friendId]) {
        case 0:     // online/available
            _presenceStatus.backgroundColor=[UIColor greenColor];
            break;
        default:    //offline
            _presenceStatus.backgroundColor=[UIColor redColor];
            break;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
