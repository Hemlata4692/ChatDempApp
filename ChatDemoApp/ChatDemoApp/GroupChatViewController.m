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
#import "CustomFilterViewController.h"
#import "UserDefaultManager.h"

@interface GroupChatViewController ()<CustomFilterDelegate> {

    UIImage *groupImageIcon;
}
@end

@implementation GroupChatViewController
@synthesize roomDetail;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=[roomDetail objectForKey:@"roomName"];
    [self addBarButtons];
    [self appDelegateVariableInitializedGroupSubject:[roomDetail objectForKey:@"roomName"] groupNickName:[roomDetail objectForKey:@"roomNickName"] groupDescription:[roomDetail objectForKey:@"roomDescription"] groupJid:[roomDetail objectForKey:@"roomJid"] ownerJid:[roomDetail objectForKey:@"roomOwnerJid"]];
    [self joinChatRoomJid:[roomDetail objectForKey:@"roomJid"] groupNickName:[roomDetail objectForKey:@"roomNickName"]];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self getGroupPhotoJid:[roomDetail objectForKey:@"roomJid"] result:^(UIImage *tempImage) {
        // do something with your BOOL
        
        if (tempImage) {
            
            groupImageIcon=tempImage;
        }
        else {
        
            groupImageIcon=[UIImage imageNamed:@"groupPlaceholderImage.png"];
        }
        [self appDelegateImageVariableInitialized:groupImageIcon];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addBarButtons {
    
    UIBarButtonItem *backBarButton,*menuBarButton;
    CGRect framing = CGRectMake(0, 0, 25, 25);
    
    UIButton *back = [[UIButton alloc] initWithFrame:framing];
    [back setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backBarButton =[[UIBarButtonItem alloc] initWithCustomView:back];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=backBarButton;

    UIButton *menu = [[UIButton alloc] initWithFrame:framing];
    [menu setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
    menuBarButton =[[UIBarButtonItem alloc] initWithCustomView:menu];
    [menu addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=menuBarButton;
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

- (void)menuAction:(id)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustomFilterViewController *filterViewObj =[storyboard instantiateViewControllerWithIdentifier:@"CustomFilterViewController"];
    filterViewObj.delegate=self;
    filterViewObj.tableCellheightValue=70;
    NSMutableDictionary *tempAttachment=[NSMutableDictionary new];
    NSMutableArray *tempAttachmentArra=[NSMutableArray new];
    NSMutableArray *tempAttachmentImageArra=[NSMutableArray new];
    
    if ([self isOwner]) {
        
        [tempAttachment setObject:[NSNumber numberWithInt:1] forKey:@"Add Member"];
        [tempAttachmentArra addObject:@"Add Member"];
        [tempAttachmentImageArra addObject:@"inviteNewMember"];
        [tempAttachment setObject:[NSNumber numberWithInt:2] forKey:@"Delete Group"];
        [tempAttachmentArra addObject:@"Delete Group"];
        [tempAttachmentImageArra addObject:@"deleteGroup"];
        filterViewObj.filterDict=[tempAttachment mutableCopy];
        filterViewObj.filterArray=[tempAttachmentArra mutableCopy];
        filterViewObj.filterImageArray=[tempAttachmentImageArra mutableCopy];
    }
    else {
    
        [tempAttachment setObject:[NSNumber numberWithInt:1] forKey:@"AddNewMember"];
        [tempAttachmentArra addObject:@"Add Member"];
        [tempAttachmentImageArra addObject:@"inviteNewMember"];
        filterViewObj.filterDict=[tempAttachment mutableCopy];
        filterViewObj.filterArray=[tempAttachmentArra mutableCopy];
        filterViewObj.filterImageArray=[tempAttachmentImageArra mutableCopy];
    }
    
    [filterViewObj setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:filterViewObj animated:NO completion:nil];
}

- (void)inviteAction {
    
    GroupInvitationViewController *invitationViewObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupInvitationViewController"];
    invitationViewObj.roomSubject=[roomDetail objectForKey:@"roomName"];
    invitationViewObj.roomNickname=[roomDetail objectForKey:@"roomNickName"];
    invitationViewObj.roomDescription=[roomDetail objectForKey:@"roomDescription"];
    if (![self image:groupImageIcon isEqualTo:[UIImage imageNamed:@"groupPlaceholderImage.png"]]) {
        invitationViewObj.friendImage=groupImageIcon;
    }
    else {
        
        invitationViewObj.friendImage=nil;
    }
    [self.navigationController pushViewController:invitationViewObj animated:YES];
}

- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}
#pragma mark - end

#pragma mark - Group delete
- (void)deleteGroupService {

    [self destroyRoom];
}
#pragma mark - end

#pragma mark - Custom filter delegate
- (void)customFilterDelegateAction:(int)status{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status==1) {
            NSLog(@"1");
            [self inviteAction];            
        }
        else if (status==2) {
            NSLog(@"2");
            
            [myDelegate showIndicator];
            [self performSelector:@selector(deleteGroupService) withObject:nil afterDelay:0.1];
        }
        else if (status==3) {
            NSLog(@"3");
            
        }
        else if (status==4) {
            NSLog(@"3");
            
        }
    });
}
#pragma mark - end

#pragma mark - XMPPGroupChat method
- (void)groupJoined {

    //Group joined
    
}

//Delete group notify
- (void)xmppRoomDeleteSuccess {

    [myDelegate stopIndicator];
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Success"
                                          message:@"Group successfully deleted."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self deallocObservers];
                                   for (UIViewController *controller in self.navigationController.viewControllers) {
                                       
                                       //Do not forget to import AnOldViewController.h
                                       if ([controller isKindOfClass:[DashboardViewController class]]) {
                                           
                                           [self.navigationController popToViewController:controller
                                                                                 animated:YES];
                                           break;
                                       }
                                   }
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alertController addAction:okAction];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)xmppRoomDeleteFail {

    [myDelegate stopIndicator];
    [UserDefaultManager showAlertMessage:@"Fail" message:@"Some thing went wrong, Please try again later."];
}
//end
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
