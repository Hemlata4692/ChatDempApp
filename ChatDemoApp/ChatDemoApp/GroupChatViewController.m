//
//  GroupChatViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 07/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "GroupChatViewController.h"
#import "GroupInvitationViewController.h"
#import "DashboardViewController.h"

@interface GroupChatViewController ()

@end

@implementation GroupChatViewController
@synthesize roomDetail;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=[roomDetail objectForKey:@"roomName"];
    [self addBarButtons];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self joinChatRoomJid:[roomDetail objectForKey:@"roomJid"] groupNickName:[roomDetail objectForKey:@"roomNickName"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBarButtons {
    
    UIBarButtonItem *backBarButton,*inviteBarButton;
    CGRect framing = CGRectMake(0, 0, 25, 25);
    
    UIButton *back = [[UIButton alloc] initWithFrame:framing];
    [back setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backBarButton =[[UIBarButtonItem alloc] initWithCustomView:back];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=backBarButton;
    
    UIButton *invite = [[UIButton alloc] initWithFrame:framing];
    [invite setImage:[UIImage imageNamed:@"addMemberIcon"] forState:UIControlStateNormal];
    inviteBarButton =[[UIBarButtonItem alloc] initWithCustomView:invite];
    [invite addTarget:self action:@selector(inviteAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem=inviteBarButton;
}
#pragma mark - end

#pragma mark - IBActions
- (void)backAction {
    
    [self deallocObservers];
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        //Do not forget to import AnOldViewController.h
        if ([controller isKindOfClass:[DashboardViewController class]]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }
}

- (void)inviteAction {
    
    
//    if (![self image:self.groupImage.imageView.image isEqualTo:[UIImage imageNamed:@"groupPlaceholderImage.png"]]) {
//        invitationViewObj.friendImage=self.groupImage.imageView.image;
//    }
//    else {
//        
//        invitationViewObj.friendImage=nil;
//    }
    
    [self getGroupPhotoJid:[roomDetail objectForKey:@"roomJid"] result:^(UIImage *tempImage) {
        // do something with your BOOL
        GroupInvitationViewController *invitationViewObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupInvitationViewController"];
        invitationViewObj.roomSubject=[roomDetail objectForKey:@"roomName"];
        invitationViewObj.roomNickname=[roomDetail objectForKey:@"roomNickName"];
        invitationViewObj.roomDescription=[roomDetail objectForKey:@"roomDescription"];
        [self.navigationController pushViewController:invitationViewObj animated:YES];
    }];
    
    
//    [self sendGroupInvitation:@[[NSString stringWithFormat:@"0000000000@%@//Smack",myDelegate.serverName,[[myDelegate.xmppStream myJID] resource]]]];
}
#pragma mark - end

#pragma mark - XMPPGroupChat method
- (void)groupJoined {

    //Group joined
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
