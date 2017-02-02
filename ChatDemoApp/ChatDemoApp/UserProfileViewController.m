//
//  UserProfileViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 02/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "UserProfileViewController.h"
#import "EditProfileViewController.h"

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
    _presenceStatus.layer.cornerRadius=5;
    _presenceStatus.layer.masksToBounds=YES;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self initializeFriendProfile:self.friendId];
    if ([self.friendId isEqualToString:myDelegate.xmppLogedInUserId]) {
        [self addBarButton];
    }
    [self setCurrentProfileView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Custom accessors
- (void)setCurrentProfileView {

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
        
        if ([self.friendId isEqualToString:myDelegate.xmppLogedInUserId]) {
            friendProfileDic=[self getEditProfileData:self.friendId];
        }
        else {
            friendProfileDic=[self getProfileData:self.friendId];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.userName.text=[friendProfileDic objectForKey:@"Name"];
            self.userStatus.text=[friendProfileDic objectForKey:@"UserStatus"];
            self.phoneNumber.text=[friendProfileDic objectForKey:@"PhoneNumber"];
            
            NSLog(@" Desc:%@ \n address:%@ \n emailid:%@ \n birthDay:%@ \n gender:%@",[friendProfileDic objectForKey:@"Description"],[friendProfileDic objectForKey:@"Address"],[friendProfileDic objectForKey:@"EmailAddress"],[friendProfileDic objectForKey:@"UserBirthDay"],[friendProfileDic objectForKey:@"Gender"]);
        });
    });
}

- (void)addBarButton {
    
    UIBarButtonItem *backBarButton, *editBarButton;
    CGRect framing = CGRectMake(0, 0, 25, 25);
    
    UIButton *back = [[UIButton alloc] initWithFrame:framing];
    [back setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backBarButton =[[UIBarButtonItem alloc] initWithCustomView:back];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=backBarButton;
    
    UIButton *edit = [[UIButton alloc] initWithFrame:framing];
    [edit setImage:[UIImage imageNamed:@"editProfile"] forState:UIControlStateNormal];
    editBarButton =[[UIBarButtonItem alloc] initWithCustomView:edit];
    [edit addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.rightBarButtonItem=editBarButton;
}
#pragma mark - end
- (void)backAction {

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editAction {
    
    EditProfileViewController *editProfileObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
    [self.navigationController pushViewController:editProfileObj animated:YES];
}
#pragma mark - UIButton actions

#pragma mark - end

#pragma mark - XMPPProfileView methods
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

- (void)XmppProileUpdateNotify {

    
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
