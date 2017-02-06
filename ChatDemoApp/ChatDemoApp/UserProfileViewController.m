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
    else {
        [self addBackBarButton];
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

    [self setProfileImageUsingCompletionBlock];
    _presenceStatus.hidden=YES;
    switch ([self getPresenceStatus:self.friendId]) {
        case 0:     // online/available
            _presenceStatus.backgroundColor=[UIColor greenColor];
            break;
        default:    //offline
            _presenceStatus.backgroundColor=[UIColor redColor];
            break;
    }
    
    if ([self.friendId isEqualToString:myDelegate.xmppLogedInUserId]) {
        [self setEditProfileDataUsingCompletionBlock];
    }
    else {
        [self setFriendProfileDataUsingCompletionBlock];
    }
    
//    dispatch_queue_t queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_PRIORITY_DEFAULT);
//    dispatch_async(queue1, ^{
//        
//        if ([self.friendId isEqualToString:myDelegate.xmppLogedInUserId]) {
//            friendProfileDic=[self getEditProfileData:self.friendId];
//        }
//        else {
//            friendProfileDic=[self getProfileData:self.friendId];
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            self.userName.text=[friendProfileDic objectForKey:@"Name"];
//            self.userStatus.text=[friendProfileDic objectForKey:@"UserStatus"];
//            self.phoneNumber.text=[friendProfileDic objectForKey:@"PhoneNumber"];
//            
//            NSLog(@" Desc:%@ \n address:%@ \n emailid:%@ \n birthDay:%@ \n gender:%@",[friendProfileDic objectForKey:@"Description"],[friendProfileDic objectForKey:@"Address"],[friendProfileDic objectForKey:@"EmailAddress"],[friendProfileDic objectForKey:@"UserBirthDay"],[friendProfileDic objectForKey:@"Gender"]);
//        });
//    });
}

- (void)setEditProfileDataUsingCompletionBlock {
    
    [self getEditProfileData:myDelegate.xmppLogedInUserId result:^(NSDictionary *tempProfileData) {
        // do something with your BOOL
        friendProfileDic=tempProfileData;
        self.userName.text=[friendProfileDic objectForKey:@"Name"];
        self.userStatus.text=[friendProfileDic objectForKey:@"UserStatus"];
        self.phoneNumber.text=[friendProfileDic objectForKey:@"PhoneNumber"];
        
        NSLog(@" Desc:%@ \n address:%@ \n emailid:%@ \n birthDay:%@ \n gender:%@",[friendProfileDic objectForKey:@"Description"],[friendProfileDic objectForKey:@"Address"],[friendProfileDic objectForKey:@"EmailAddress"],[friendProfileDic objectForKey:@"UserBirthDay"],[friendProfileDic objectForKey:@"Gender"]);
    }];
}

- (void)setFriendProfileDataUsingCompletionBlock {
    
    [self getProfileData:self.friendId result:^(NSDictionary *tempProfileData) {
        // do something with your BOOL
        friendProfileDic=tempProfileData;
        self.userName.text=[friendProfileDic objectForKey:@"Name"];
        self.userStatus.text=[friendProfileDic objectForKey:@"UserStatus"];
        self.phoneNumber.text=[friendProfileDic objectForKey:@"PhoneNumber"];
        
        NSLog(@" Desc:%@ \n address:%@ \n emailid:%@ \n birthDay:%@ \n gender:%@",[friendProfileDic objectForKey:@"Description"],[friendProfileDic objectForKey:@"Address"],[friendProfileDic objectForKey:@"EmailAddress"],[friendProfileDic objectForKey:@"UserBirthDay"],[friendProfileDic objectForKey:@"Gender"]);
    }];
}

- (void)setProfileImageUsingCompletionBlock {

    [self getProfilePhoto:self.friendId profileImageView:self.profileImage placeholderImage:@"images.png" result:^(UIImage *tempImage) {
        // do something with your BOOL
        if (tempImage!=nil) {
            self.profileImage.image=tempImage;
        }
        else {
            
            self.profileImage.image=[UIImage imageNamed:@"images.png"];
        }
    }];
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

    switch ([self getPresenceStatus:self.friendId]) {
        case 0:     // online/available
            _presenceStatus.backgroundColor=[UIColor greenColor];
            break;
        default:    //offline
            _presenceStatus.backgroundColor=[UIColor redColor];
            break;
    }
}

//- (void)XmppProileUpdateNotify {
//
//    if ([self.friendId isEqualToString:myDelegate.xmppLogedInUserId]) {
//        [self setEditProfileDataUsingCompletionBlock];
//    }
//    else {
//        [self setFriendProfileDataUsingCompletionBlock];
//    }
//}
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
