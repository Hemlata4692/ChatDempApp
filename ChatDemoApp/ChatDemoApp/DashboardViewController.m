//
//  DashboardViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "DashboardViewController.h"
#import "UserDefaultManager.h"
#import "HMSegmentedControl.h"
#import "UserProfileViewController.h"

#import "XMPPvCardTemp.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPvCardCoreDataStorage.h"
#import "ChatScreenViewController.h"

#import "CustomFilterViewController.h"
#import "GroupChatViewController.h"

#import "MyButton.h"

@class XMPPvCardTempModuleStorage;
@interface DashboardViewController () {

    HMSegmentedControl *customSegmentedControl;
    AppDelegateObjectFile *appDelegate;
    
    NSMutableArray *historyChatData;
    NSMutableDictionary *profileLocalDictData;
    
    //Group chat
    NSMutableArray *groupChatListArray;
    //end
}
@property (strong, nonatomic) IBOutlet UITableView *dasboardTableListing;
@end

@implementation DashboardViewController
@synthesize userListArray, userDetailedList;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"Dashboard";
   
    appDelegate = (AppDelegateObjectFile *)[[UIApplication sharedApplication] delegate];
    [self addBarButton];
    [self addSegmentBar];
    
    userListArray=[NSMutableArray new];
    groupChatListArray=[NSMutableArray new];
    userDetailedList=[NSMutableDictionary new];
    historyChatData=[NSMutableArray new];
    
    [myDelegate showIndicator];
    [self performSelector:@selector(userList) withObject:nil afterDelay:0.1];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self deallocGroupChatVariables];
    profileLocalDictData=[NSMutableDictionary new];
    groupChatListArray=[[self fetchGroupChatRommInfoList] mutableCopy];
    if (userListArray.count>0) {
        profileLocalDictData=[self getProfileUsersData];
    }
    [self historyUpdateNotify];
}

- (void)userList {
    
    [self xmppUserConnect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Table view delegates
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    
    if (customSegmentedControl.selectedSegmentIndex==2) {
        return userListArray.count;
    }
    else if (customSegmentedControl.selectedSegmentIndex==0) {
        return historyChatData.count;
    }
    else {
        return groupChatListArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    /*
    //This is used to listed according to presence(offline/online)
    return [[[self fetchedResultsController] sections] count];
    //end
     */
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    UILabel* nameLabel = (UILabel*)[cell viewWithTag:1];
    UIImageView *userImage = (UIImageView*)[cell viewWithTag:2];
    MyButton* profileBtn = (MyButton*)[cell viewWithTag:3];
    UILabel* statusLabel = (UILabel*)[cell viewWithTag:4];
    UILabel* dateLabel = (UILabel*)[cell viewWithTag:5];
    UILabel* badgeLabel = (UILabel*)[cell viewWithTag:6];
    
    badgeLabel.hidden=YES;
    profileBtn.hidden=NO;
    if (customSegmentedControl.selectedSegmentIndex==2) {

        NSLog(@"%@",[userListArray objectAtIndex:indexPath.row]);
        NSMutableDictionary *profileDic=[[profileLocalDictData objectForKey:[userListArray objectAtIndex:indexPath.row]] mutableCopy];
        
        dateLabel.hidden=YES;
        profileBtn.Tag=(int)indexPath.row;
        [profileBtn addTarget:self action:@selector(friendProfileAction:) forControlEvents:UIControlEventTouchUpInside];
        userImage.layer.cornerRadius=20;
        userImage.layer.masksToBounds=YES;
        
        nameLabel.text = [profileDic objectForKey:@"Name"];
        statusLabel.text=[profileDic objectForKey:@"UserStatus"];
        NSLog(@" userStatus:%@ \n phoneNumber:%@ Desc:%@ \n address:%@ \n emailid:%@ \n birthDay:%@ \n gender:%@",[profileDic objectForKey:@"UserStatus"],[profileDic objectForKey:@"PhoneNumber"],[profileDic objectForKey:@"Description"],[profileDic objectForKey:@"Address"],[profileDic objectForKey:@"EmailAddress"],[profileDic objectForKey:@"UserBirthDay"],[profileDic objectForKey:@"Gender"]);
        [self configurePhotoForCell:cell jid:[userListArray objectAtIndex:indexPath.row]];
    }
    else if (customSegmentedControl.selectedSegmentIndex==0) {
        
        badgeLabel.layer.masksToBounds=YES;
        badgeLabel.layer.cornerRadius=10;
        
        NSXMLElement *historyElement=[historyChatData objectAtIndex:indexPath.row];
        NSXMLElement *innerData=[historyElement elementForName:@"data"];
        //        NSMutableDictionary *profileDic;
        
        if (![[innerData attributeStringValueForName:@"from"] isEqualToString:appDelegate.xmppLogedInUserId]) {
            
            //            profileDic=[[profileLocalDictData objectForKey:[historyElement attributeStringValueForName:@"from"]] mutableCopy];
            if ([self isChatTypeMessageElement:historyElement]) {
                 [self configurePhotoForCell:cell jid:[innerData attributeStringValueForName:@"from"]];
            }
            else {
                userImage.image=[UIImage imageNamed:@"groupPlaceholderImage.png"];
            }
           
            nameLabel.text = [[innerData attributeStringValueForName:@"senderName"] capitalizedString];
            if ([[XMPPUserDefaultManager getXMPPBadgeIndicatorValue:[innerData attributeStringValueForName:@"from"]] intValue]!=0) {
                badgeLabel.hidden=NO;
                badgeLabel.text=[XMPPUserDefaultManager getXMPPBadgeIndicatorValue:[innerData attributeStringValueForName:@"from"]];
            }
        }
        else {
            
            //            profileDic=[[profileLocalDictData objectForKey:[historyElement attributeStringValueForName:@"to"]] mutableCopy];
            
            if ([self isChatTypeMessageElement:historyElement]) {
                [self configurePhotoForCell:cell jid:[innerData attributeStringValueForName:@"to"]];
            }
            else {
                userImage.image=[UIImage imageNamed:@"groupPlaceholderImage.png"];
            }
            
            nameLabel.text = [[innerData attributeStringValueForName:@"receiverName"] capitalizedString];
            if ([[XMPPUserDefaultManager getXMPPBadgeIndicatorValue:[innerData attributeStringValueForName:@"to"]] intValue]!=0) {
                badgeLabel.hidden=NO;
                badgeLabel.text=[XMPPUserDefaultManager getXMPPBadgeIndicatorValue:[innerData attributeStringValueForName:@"to"]];
            }
        }
        
        dateLabel.hidden=NO;
        profileBtn.Tag=(int)indexPath.row;
        [profileBtn addTarget:self action:@selector(friendProfileAction:) forControlEvents:UIControlEventTouchUpInside];
        userImage.layer.cornerRadius=20;
        userImage.layer.masksToBounds=YES;
        
        statusLabel.text=[[historyElement elementForName:@"body"] stringValue];
        dateLabel.text=[self changeTimeFormat:[innerData attributeStringValueForName:@"time"]];
        //        NSLog(@" userStatus:%@ \n phoneNumber:%@ Desc:%@ \n address:%@ \n emailid:%@ \n birthDay:%@ \n gender:%@",[profileDic objectForKey:@"UserStatus"],[profileDic objectForKey:@"PhoneNumber"],[profileDic objectForKey:@"Description"],[profileDic objectForKey:@"Address"],[profileDic objectForKey:@"EmailAddress"],[profileDic objectForKey:@"UserBirthDay"],[profileDic objectForKey:@"Gender"]);
    }
    else {
        //Group content
        NSMutableDictionary *groupDataDic=[[groupChatListArray objectAtIndex:indexPath.row] mutableCopy];
        
        dateLabel.hidden=YES;
        profileBtn.hidden=YES;
        userImage.layer.cornerRadius=20;
        userImage.layer.masksToBounds=YES;
        
        nameLabel.text = [groupDataDic objectForKey:@"roomName"];
        statusLabel.text=[groupDataDic objectForKey:@"roomDescription"];
        [self configureGroupPhotoForCell:cell jid:[groupDataDic objectForKey:@"roomJid"]];
    }
    return cell;
}

- (NSString *)changeTimeFormat:(NSString *)timeString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:timeString];
    [dateFormatter setDateFormat:@"hh:mm a"];
    return [dateFormatter stringFromDate:date];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    if (customSegmentedControl.selectedSegmentIndex==2) {
        
    ChatScreenViewController *profileObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatScreenViewController"];
    profileObj.friendUserJid=[userListArray objectAtIndex:indexPath.row];
    profileObj.friendUserName=[[profileLocalDictData objectForKey:[userListArray objectAtIndex:indexPath.row]] objectForKey:@"Name"];
//    profileObj.loginUserName=[[profileLocalDictData objectForKey:appDelegate.xmppLogedInUserId] objectForKey:@"Name"];
    [self.navigationController pushViewController:profileObj animated:YES];
    }
    else if (customSegmentedControl.selectedSegmentIndex==0) {
    
        NSXMLElement *historyElement=[historyChatData objectAtIndex:indexPath.row];
         NSXMLElement *innerData=[historyElement elementForName:@"data"];
        
        if ([self isChatTypeMessageElement:historyElement]) {
            
            ChatScreenViewController *profileObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatScreenViewController"];
            
            if (![[innerData attributeStringValueForName:@"from"] isEqualToString:appDelegate.xmppLogedInUserId]) {
                
                profileObj.friendUserJid=[innerData attributeStringValueForName:@"from"];
                profileObj.friendUserName=[[innerData attributeStringValueForName:@"senderName"] capitalizedString];
            }
            else {
                
                profileObj.friendUserJid=[innerData attributeStringValueForName:@"to"];
                profileObj.friendUserName=[[innerData attributeStringValueForName:@"receiverName"] capitalizedString];
            }
            [self.navigationController pushViewController:profileObj animated:YES];
        }
        else {
        
            //Group content click
            GroupChatViewController *groupChatObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomJid == %@", [NSString stringWithFormat:@"%@",[innerData attributeStringValueForName:@"to"]]];
            NSArray *filteredarray = [groupChatListArray filteredArrayUsingPredicate:predicate];
            
            if (filteredarray.count>0) {
                
                NSUInteger index = [groupChatListArray indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
                    return [predicate evaluateWithObject:obj];
                }];
                groupChatObj.roomDetail=[[groupChatListArray objectAtIndex:index] mutableCopy];
            }
            else {
                
                NSMutableDictionary *roomData=[NSMutableDictionary new];
                [roomData setObject:[NSNumber numberWithBool:false] forKey:@"isPhoto"];
                [roomData setObject:@"" forKey:@"roomDescription"];
                [roomData setObject:[innerData attributeStringValueForName:@"to"] forKey:@"roomJid"];
                [roomData setObject:[innerData attributeStringValueForName:@"receiverName"] forKey:@"roomName"];
                [roomData setObject:@"" forKey:@"roomOwnerJid"];
                groupChatObj.roomDetail=[roomData mutableCopy];
            }
            
            
            [self.navigationController pushViewController:groupChatObj animated:YES];

        }
    }
    else {
    
        //Group content click
        GroupChatViewController *groupChatObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
        groupChatObj.roomDetail=[[groupChatListArray objectAtIndex:indexPath.row] mutableCopy];
        [self.navigationController pushViewController:groupChatObj animated:YES];
    }
}

- (void)configurePhotoForCell:(UITableViewCell *)cell jid:(NSString *)jid {
    
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    UIImageView *userImage = (UIImageView*)[cell viewWithTag:2];
    [self getProfilePhotosJid:jid profileImageView:userImage placeholderImage:@"images.png" result:^(UIImage *tempImage) {
        // do something with your BOOL
        if (tempImage!=nil) {
            userImage.image=tempImage;
        }
        else {
            
            userImage.image=[UIImage imageNamed:@"images.png"];
        }
    }];
}
#pragma mark - end

#pragma mark - Custom accessors
- (void)addSegmentBar {
    
    customSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:
                              @[@"History", @"Groups", @"Contacts"]];
    customSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    customSegmentedControl.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    customSegmentedControl.backgroundColor=[UIColor darkGrayColor];
    customSegmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    customSegmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    customSegmentedControl.selectionIndicatorHeight = 3.0;
    customSegmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;//
    customSegmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    customSegmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Helvetica-Bold" size:16], NSFontAttributeName,
                                [UIColor grayColor].CGColor, NSForegroundColorAttributeName, nil];
    
    [customSegmentedControl setTitleTextAttributes:attributes];
    
    [customSegmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:customSegmentedControl];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    
//    if (segmentedControl.selectedSegmentIndex == 0) {
//        [self.dasboardTableListing reloadData];
//    }
//    else if (segmentedControl.selectedSegmentIndex == 2) {
        [self.dasboardTableListing reloadData];
//    }
}

- (void)addBarButton {
    
    UIBarButtonItem *profileBarButton;
    CGRect framing = CGRectMake(0, 0, 30, 30.0);
    UIButton *profile = [[UIButton alloc] initWithFrame:framing];
    //    [logout setTitle:@"Logout" forState:UIControlStateNormal];
    [profile setImage:[UIImage imageNamed:@"profile"] forState:UIControlStateNormal];
    profileBarButton =[[UIBarButtonItem alloc] initWithCustomView:profile];
    [profile addTarget:self action:@selector(profileAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:profileBarButton, nil];
    
    UIBarButtonItem *menuBarButton, *reloadBarButton;
    UIButton *menu = [[UIButton alloc] initWithFrame:framing];
    [menu setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
    menuBarButton =[[UIBarButtonItem alloc] initWithCustomView:menu];
    [menu addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *reload = [[UIButton alloc] initWithFrame:framing];
    //    [group setTitle:@"Group" forState:UIControlStateNormal];
    [reload setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
    reloadBarButton =[[UIBarButtonItem alloc] initWithCustomView:reload];
    [reload addTarget:self action:@selector(reloadAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:menuBarButton,reloadBarButton, nil];
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)friendProfileAction:(MyButton *)sender {
    
    int tagValue=(int)[sender Tag];
    if (customSegmentedControl.selectedSegmentIndex==2) {
        
        UserProfileViewController *profileObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
        profileObj.friendId=[userListArray objectAtIndex:tagValue];
        [self.navigationController pushViewController:profileObj animated:YES];
    }
    else if (customSegmentedControl.selectedSegmentIndex==0) {
        
        NSXMLElement *historyElement=[historyChatData objectAtIndex:tagValue];
        NSXMLElement *innerData=[historyElement elementForName:@"data"];
        
        if ([self isChatTypeMessageElement:historyElement]) {
            UserProfileViewController *profileObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
            if (![[innerData attributeStringValueForName:@"from"] isEqualToString:appDelegate.xmppLogedInUserId]) {
                
                profileObj.friendId=[innerData attributeStringValueForName:@"from"];
            }
            else {
                
                profileObj.friendId=[innerData attributeStringValueForName:@"to"];
            }
            [self.navigationController pushViewController:profileObj animated:YES];
        }
    }
    else {
        //Group content
    }
}

- (void)profileAction :(id)sender {
    
    UserProfileViewController *profileObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    profileObj.friendId=appDelegate.xmppLogedInUserId;
    [self.navigationController pushViewController:profileObj animated:YES];
}

- (void)reloadAction :(id)sender {
    
    profileLocalDictData=[NSMutableDictionary new];
    [myDelegate showIndicator];
    [self performSelector:@selector(reloadUserData) withObject:nil afterDelay:0.1];
}

- (void)reloadUserData {
    
    [self xmppUserRefreshResponse];
}

- (void)menuAction:(id)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CustomFilterViewController *filterViewObj =[storyboard instantiateViewControllerWithIdentifier:@"CustomFilterViewController"];
    filterViewObj.delegate=self;
    filterViewObj.tableCellheightValue=70;
    NSMutableDictionary *tempAttachment=[NSMutableDictionary new];
    NSMutableArray *tempAttachmentArra=[NSMutableArray new];
    NSMutableArray *tempAttachmentImageArra=[NSMutableArray new];
    [tempAttachment setObject:[NSNumber numberWithInt:1] forKey:@"Status"];
    [tempAttachmentArra addObject:@"Status"];
    [tempAttachmentImageArra addObject:@"editStatus"];
    [tempAttachment setObject:[NSNumber numberWithInt:2] forKey:@"New Group"];
    [tempAttachmentArra addObject:@"New Group"];
    [tempAttachmentImageArra addObject:@"group"];
    [tempAttachment setObject:[NSNumber numberWithInt:3] forKey:@"Settings"];
    [tempAttachmentArra addObject:@"Settings"];
    [tempAttachmentImageArra addObject:@"settings"];
    [tempAttachment setObject:[NSNumber numberWithInt:4] forKey:@"Logout"];
    [tempAttachmentArra addObject:@"Logout"];
    [tempAttachmentImageArra addObject:@"logout"];
    filterViewObj.filterDict=[tempAttachment mutableCopy];
    filterViewObj.filterArray=[tempAttachmentArra mutableCopy];
    filterViewObj.filterImageArray=[tempAttachmentImageArra mutableCopy];
    
    [filterViewObj setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:filterViewObj animated:NO completion:nil];
}
#pragma mark - end

#pragma mark - Custom filter delegate
- (void)customFilterDelegateAction:(int)status{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status==1) {
            NSLog(@"1");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *objStatusView = [storyboard instantiateViewControllerWithIdentifier:@"EditUserStatusViewController"];
            [self.navigationController pushViewController:objStatusView animated:YES];
        }
        else if (status==2) {
            NSLog(@"2");
            
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *objGroupView = [storyboard instantiateViewControllerWithIdentifier:@"GroupChatFormViewController"];
            [self.navigationController pushViewController:objGroupView animated:YES];
        }
        else if (status==3) {
            NSLog(@"3");
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *objSettingView = [storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
            [self.navigationController pushViewController:objSettingView animated:YES];
        }
        else if (status==4) {
            NSLog(@"4");
            [UserDefaultManager removeValue:@"userName"];
            [self userLogout];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            myDelegate.navigationController = [storyboard instantiateViewControllerWithIdentifier:@"loginNavigation"];
            myDelegate.window.rootViewController = myDelegate.navigationController;
        }
    });
}
#pragma mark - end

#pragma mark - Post notification handler
- (void)historyUpdateNotify{
    
    [self fetchAllHistoryChat:^(NSMutableArray *tempHistoryData) {
        // do something with your BOOL
        
        historyChatData=[tempHistoryData mutableCopy];
        [self.dasboardTableListing reloadData];
    }];
}

- (void)updateProfileInformation {

    profileLocalDictData=[self getProfileUsersData];
    [self.dasboardTableListing reloadData];
}

- (void)xmppNewUserAddedNotify {

    self.navigationItem.leftBarButtonItem=nil;
    self.navigationItem.leftBarButtonItems=nil;
    self.navigationItem.rightBarButtonItem=nil;
    self.navigationItem.rightBarButtonItems=nil;
    
    UIBarButtonItem *profileBarButton;
    CGRect framing = CGRectMake(0, 0, 30, 30.0);
    UIButton *profile = [[UIButton alloc] initWithFrame:framing];
    //    [logout setTitle:@"Logout" forState:UIControlStateNormal];
    [profile setImage:[UIImage imageNamed:@"profile"] forState:UIControlStateNormal];
    profileBarButton =[[UIBarButtonItem alloc] initWithCustomView:profile];
    [profile addTarget:self action:@selector(profileAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:profileBarButton, nil];
    
    UIBarButtonItem *menuBarButton, *reloadBarButton;
    UIButton *menu = [[UIButton alloc] initWithFrame:framing];
    [menu setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
    menuBarButton =[[UIBarButtonItem alloc] initWithCustomView:menu];
    [menu addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *reload = [[UIButton alloc] initWithFrame:framing];
    //    [group setTitle:@"Group" forState:UIControlStateNormal];
    [reload setImage:[UIImage imageNamed:@"reloadRed"] forState:UIControlStateNormal];
    reloadBarButton =[[UIBarButtonItem alloc] initWithCustomView:reload];
    [reload addTarget:self action:@selector(reloadAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:menuBarButton,reloadBarButton, nil];
}
#pragma mark - end

- (void)xmppUserListResponse:(NSMutableDictionary *)xmppUserDetails xmppUserListIds:(NSMutableArray *)xmppUserListIds {
    
    [self addBarButton];
    userDetailedList=[xmppUserDetails mutableCopy];
    userListArray=[xmppUserListIds mutableCopy];
    
    //    profileLocalDictData=[self getProfileUsersData];
    [self getProfileData1:^(NSDictionary *tempProfileData) {
        // do something with your BOOL
        profileLocalDictData=[tempProfileData mutableCopy];
        [self getListOfGroups];
    }];
}

#pragma mark - Group chat
- (void)configureGroupPhotoForCell:(UITableViewCell *)cell jid:(NSString *)jid {
    
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    UIImageView *userImage = (UIImageView*)[cell viewWithTag:2];
    [self getGroupPhotoJid:jid profileImageView:userImage placeholderImage:@"groupPlaceholderImage.png" result:^(UIImage *tempImage) {
        // do something with your BOOL
        if (tempImage!=nil) {
            userImage.image=tempImage;
        }
        else {
            
            userImage.image=[UIImage imageNamed:@"groupPlaceholderImage.png"];
        }
    }];
}

- (void)getListOfGroupsNotify:(NSMutableArray *)groupInfo {

    [myDelegate stopIndicator];
    groupChatListArray=[groupInfo mutableCopy];
    [self.dasboardTableListing reloadData];
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
