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
#import "DashboardTableViewCell.h"

@class XMPPvCardTempModuleStorage;
@interface DashboardViewController () {

    HMSegmentedControl *customSegmentedControl;
    
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
   
    [self addBarButton];
    [self addSegmentBar];
    
    userListArray=[NSMutableArray new];
    groupChatListArray=[NSMutableArray new];
    userDetailedList=[NSMutableDictionary new];
    historyChatData=[NSMutableArray new];
    self.dasboardTableListing.hidden=YES;
    
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
    
    Internet *internet=[[Internet alloc] init];
    if ([internet start]) {
        
        [myDelegate stopIndicator];
        [self xmppOfflineUserConnect];
    }
    else {
        [self xmppUserConnect];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Table view delegates
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    /*
    //This is used to listed according to presence(offline/online)
    return [[[self fetchedResultsController] sections] count];
    //end
     */
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    DashboardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[DashboardTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    if (customSegmentedControl.selectedSegmentIndex==2) {

        NSLog(@"%@",[userListArray objectAtIndex:indexPath.row]);
        [cell displayContactListUserData:[[profileLocalDictData objectForKey:[userListArray objectAtIndex:indexPath.row]] mutableCopy] jid:[userListArray objectAtIndex:indexPath.row] index:(int)indexPath.row];
        [cell.profileBtn addTarget:self action:@selector(friendProfileAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (customSegmentedControl.selectedSegmentIndex==0) {
        
        [cell displayHistoryListUserData:[historyChatData objectAtIndex:indexPath.row] index:(int)indexPath.row];
        [cell.profileBtn addTarget:self action:@selector(friendProfileAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        
        //Group content
        [cell displayGroupListData:[[groupChatListArray objectAtIndex:indexPath.row] mutableCopy]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if (customSegmentedControl.selectedSegmentIndex==2) {
        
        [self didSelectAtContactList:(int)indexPath.row];
    }
    else if (customSegmentedControl.selectedSegmentIndex==0) {
        
        [self didSelectAtHistoryList:(int)indexPath.row];
    }
    else {
        
        [self didSelectAtGroupList:(int)indexPath.row];
    }
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
    customSegmentedControl.selectionIndicatorColor = [UIColor clearColor];
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
- (IBAction)friendProfileAction:(UIButton *)sender {
    
    int tagValue=(int)[sender tag];
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
            if (![[innerData attributeStringValueForName:@"from"] isEqualToString:myDelegate.xmppLogedInUserId]) {
                
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
    profileObj.friendId=myDelegate.xmppLogedInUserId;
    [self.navigationController pushViewController:profileObj animated:YES];
}

- (void)reloadAction :(id)sender {
    
    Internet *internet=[[Internet alloc] init];
    if (![internet start]) {
        self.dasboardTableListing.hidden=YES;
        profileLocalDictData=[NSMutableDictionary new];
        [myDelegate showIndicator];
        [self performSelector:@selector(reloadUserData) withObject:nil afterDelay:0.1];
    }
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
            Internet *internet=[[Internet alloc] init];
            if (![internet start]) {
                
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"Alert"
                                                      message:@"Logging out will clear your current history."
                                                      preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               [UserDefaultManager removeValue:@"userName"];
                                               [self userLogout];
                                               UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                               myDelegate.navigationController = [storyboard instantiateViewControllerWithIdentifier:@"loginNavigation"];
                                               myDelegate.window.rootViewController = myDelegate.navigationController;
                                               
                                               [alertController dismissViewControllerAnimated:YES completion:nil];
                                           }];
                
                UIAlertAction *cancelAction = [UIAlertAction
                                               actionWithTitle:@"CANCEL"
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action)
                                               {
                                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                                               }];
                [alertController addAction:cancelAction];
                [alertController addAction:okAction];
                [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertController animated:YES completion:nil];
            }
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

//Group chat
- (void)getListOfGroupsNotify:(NSMutableArray *)groupInfo {
    
    [myDelegate stopIndicator];
    
    self.dasboardTableListing.hidden=NO;
    customSegmentedControl.selectedSegmentIndex=0;
    [self.dasboardTableListing reloadData];
    
    //After complete loading show segment bottom lin
    customSegmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    //end
    
    groupChatListArray=[groupInfo mutableCopy];
    [self.dasboardTableListing reloadData];
}
#pragma mark - end

#pragma mark - DashboardXMPP method
- (void)xmppUserListResponse:(NSMutableDictionary *)xmppUserDetails xmppUserListIds:(NSMutableArray *)xmppUserListIds {
    
    [self addBarButton];
    userDetailedList=[xmppUserDetails mutableCopy];
    userListArray=[xmppUserListIds mutableCopy];
    
    customSegmentedControl.selectedSegmentIndex=2;
    [self.dasboardTableListing reloadData];
    //    profileLocalDictData=[self getProfileUsersData];
    [self getProfileData1:^(NSDictionary *tempProfileData) {
        // do something with your BOOL
        profileLocalDictData=[tempProfileData mutableCopy];
        Internet *internet=[[Internet alloc] init];
        if ([internet start]) {
            
            [myDelegate stopIndicator];
            self.dasboardTableListing.hidden=NO;
            customSegmentedControl.selectedSegmentIndex=0;
            //After complete loading show segment bottom lin
            customSegmentedControl.selectionIndicatorColor = [UIColor whiteColor];
            //end
            [self.dasboardTableListing reloadData];
        }
        else {
            [self getListOfGroups];
        }
        
    }];
}

//Refresh connection
- (void)XMPPReloadConnection {
    
    profileLocalDictData=[NSMutableDictionary new];
    [myDelegate showIndicator];
    [self performSelector:@selector(reloadUserData) withObject:nil afterDelay:0.1];
}
#pragma mark - end

#pragma mark - DidSelect table view cell action perform
- (void)didSelectAtContactList:(int)index {
    
    ChatScreenViewController *profileObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatScreenViewController"];
    profileObj.friendUserJid=[userListArray objectAtIndex:index];
    profileObj.friendUserName=[[profileLocalDictData objectForKey:[userListArray objectAtIndex:index]] objectForKey:@"Name"];
    //    profileObj.loginUserName=[[profileLocalDictData objectForKey:myDelegate.xmppLogedInUserId] objectForKey:@"Name"];
    [self.navigationController pushViewController:profileObj animated:YES];
}

- (void)didSelectAtHistoryList:(int)index {
    
    NSXMLElement *historyElement=[historyChatData objectAtIndex:index];
    if ([self isChatTypeMessageElement:historyElement]) {
        
        [self didSelectAtHistoryListOneToOneChatType:[historyElement elementForName:@"data"]];
    }
    else {
        
        //Group content click
        [self didSelectAtHistoryListGroupChatType:[historyElement elementForName:@"data"]];
    }
}

- (void)didSelectAtHistoryListOneToOneChatType:(NSXMLElement *)innerData {
    
    ChatScreenViewController *profileObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatScreenViewController"];
    
    if (![[innerData attributeStringValueForName:@"from"] isEqualToString:myDelegate.xmppLogedInUserId]) {
        
        profileObj.friendUserJid=[innerData attributeStringValueForName:@"from"];
        profileObj.friendUserName=[[innerData attributeStringValueForName:@"senderName"] capitalizedString];
    }
    else {
        
        profileObj.friendUserJid=[innerData attributeStringValueForName:@"to"];
        profileObj.friendUserName=[[innerData attributeStringValueForName:@"receiverName"] capitalizedString];
    }
    [self.navigationController pushViewController:profileObj animated:YES];
}

- (void)didSelectAtHistoryListGroupChatType:(NSXMLElement *)innerData {
    
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

- (void)didSelectAtGroupList:(int)index {
    
    //Group content click
    GroupChatViewController *groupChatObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
    groupChatObj.roomDetail=[[groupChatListArray objectAtIndex:index] mutableCopy];
    [self.navigationController pushViewController:groupChatObj animated:YES];
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
