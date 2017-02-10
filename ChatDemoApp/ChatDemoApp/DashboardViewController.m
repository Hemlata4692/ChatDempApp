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

@class XMPPvCardTempModuleStorage;
@interface DashboardViewController () {

    HMSegmentedControl *customSegmentedControl;
    AppDelegateObjectFile *appDelegate;
    
    NSMutableArray *historyChatData;
    NSMutableDictionary *profileLocalDictData;
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
    userDetailedList=[NSMutableDictionary new];
    [myDelegate showIndicator];
    [self performSelector:@selector(userList) withObject:nil afterDelay:0.1];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    profileLocalDictData=[NSMutableDictionary new];
    historyChatData=[NSMutableArray new];
    if (userListArray.count>0) {
        profileLocalDictData=[self getProfileUsersData];
    }
    [self.dasboardTableListing reloadData];
//
//        //        NSData *photoData1 = [[myDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:@"1234567890@ranosys"]];
//        //        UIImage *imagetemp=[UIImage imageWithData:photoData1];
//        //        NSLog(@"d");
//        //         NSLog(@"a");
////        XMPPvCardTemp *newvCardTemp = [[myDelegate xmppvCardTempModule] vCardTempForJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"2222222222@%@",myDelegate.hostName]] shouldFetch:YES];
////        
////        NSLog(@"%@",newvCardTemp.userStatus);
////        NSLog(@"%@",newvCardTemp.emailAddress);
//    }
  
}

- (void)userList {
    
    [self xmppUserConnect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - XMPP delegates
//- (XMPPStream *)xmppStream
//{
//    return [myDelegate xmppStream];
//}
//- (NSFetchedResultsController *)fetchedResultsController
//{
//    if (fetchedResultsController == nil)
//    {
//        NSManagedObjectContext *moc = [myDelegate managedObjectContext_roster];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
//                                                  inManagedObjectContext:moc];
//        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
//        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
//        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        [fetchRequest setEntity:entity];
//        [fetchRequest setSortDescriptors:sortDescriptors];
//        [fetchRequest setFetchBatchSize:10];
//        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
//                                                                       managedObjectContext:moc
//                                                                         sectionNameKeyPath:@"sectionNum"
//                                                                                  cacheName:nil];
//        [fetchedResultsController setDelegate:self];
//        NSError *error = nil;
//        if (![fetchedResultsController performFetch:&error])
//        {
//            //error
//        }
//    }
//    return fetchedResultsController;
//}
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
////    endty=[NSMutableArray new];
////    NSArray *sections = [[self fetchedResultsController] sections];
////    for (int i = 0 ; i< [[[self fetchedResultsController] sections] count];i++) {
////        for (int j = 0; j<[[sections objectAtIndex:i] numberOfObjects]; j++) {
////
////                    [endty addObject:[[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]]];
//// 
////            }
////        }
////NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName"
////                                                                 ascending:YES];
////    //
////    NSArray *results = [endty
////                        sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
//    
//    [self.dasboardTableListing reloadData];
//}
#pragma mark - end

#pragma mark - Table view delegates
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 0.01;
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
//{
////    if (isSearch)
////    {
////        if (searchResultArray.count<1) {
////            noRecordsLabel.hidden=NO;
////            noRecordsLabel.text=@"No records found.";
////            return searchResultArray.count;
////        }
////        else
////        {
////            noRecordsLabel.hidden=YES;
////            return searchResultArray.count;
////        }
////    }
////    else
////    {
////        if (userListArr.count<1)
////        {
////            noRecordsLabel.hidden=NO;
////            noRecordsLabel.text=@"No friends added.";
////            return userListArr.count;
////        }
////        else
////        {
////            noRecordsLabel.hidden=YES;
////            return userListArr.count;
////        }
////    }
//    return 5;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    /*
    //This is used to listed according to presence(offline/online)
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (sectionIndex < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        return sectionInfo.numberOfObjects;
    }
    //end
    return 0;
    //return 5;
     */
    if (customSegmentedControl.selectedSegmentIndex==1) {
        return userListArray.count;
    }
    else {
        return 0;
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

/*
//This is used to listed according to presence(offline/online)
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView;
    //This is used to listed according to presence(offline/online)
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (section < [sections count])
    {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 46.0)];
        headerView.backgroundColor = [UIColor whiteColor];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.frame.size.width, 46)];
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        
        int section = [sectionInfo.name intValue];
        switch (section)
        {
            case 0  :
                label.text = @"Available";
                label.textColor=[UIColor colorWithRed:13.0/255.0 green:213.0/255.0 blue:178.0/255.0 alpha:1.0];
                break;
            case 1  :
                label.text =  @"Away";
                label.textColor=[UIColor yellowColor];
                break;
            default :
                label.text =  @"Offline";
                label.textColor=[UIColor redColor];
                break;
        }
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0];
        label.backgroundColor=[UIColor clearColor];
        
        [headerView addSubview:label];
    }
    else{
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0)];
        headerView.backgroundColor = [UIColor clearColor];
        
    }
    //end
    return headerView;
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    if (customSegmentedControl.selectedSegmentIndex==1) {
        UILabel* nameLabel = (UILabel*)[cell viewWithTag:1];
//        if (![[profileLocalDictData allKeys] containsObject:[userListArray objectAtIndex:indexPath.row]]) {
//            
//             nameLabel.backgroundColor=[UIColor lightGrayColor];
//            [self getProfileData:[userListArray objectAtIndex:indexPath.row] result:^(NSDictionary *tempProfileData) {
//                // do something with your BOOL
//                if (nil!=tempProfileData) {
//                    [profileLocalDictData setObject:tempProfileData forKey:[userListArray objectAtIndex:indexPath.row]];
//                    nameLabel.text = [tempProfileData objectForKey:@"Name"];
//                    nameLabel.backgroundColor=[UIColor clearColor];
//                }
//            }];
//        }
//        NSDictionary *profileDic=[self getProfileDicData:[userListArray objectAtIndex:indexPath.row]];
        NSLog(@"%@",[userListArray objectAtIndex:indexPath.row]);
        NSMutableDictionary *profileDic=[[profileLocalDictData objectForKey:[userListArray objectAtIndex:indexPath.row]] mutableCopy];
        
        UIImageView *userImage = (UIImageView*)[cell viewWithTag:2];
        UIButton* profileBtn = (UIButton*)[cell viewWithTag:3];
        profileBtn.tag=indexPath.row;
        
        [profileBtn addTarget:self action:@selector(friendProfileAction:) forControlEvents:UIControlEventTouchUpInside];
        userImage.layer.cornerRadius=20;
        userImage.layer.masksToBounds=YES;
        
        
        nameLabel.text = [profileDic objectForKey:@"Name"];
        NSLog(@" userStatus:%@ \n phoneNumber:%@ Desc:%@ \n address:%@ \n emailid:%@ \n birthDay:%@ \n gender:%@",[profileDic objectForKey:@"UserStatus"],[profileDic objectForKey:@"PhoneNumber"],[profileDic objectForKey:@"Description"],[profileDic objectForKey:@"Address"],[profileDic objectForKey:@"EmailAddress"],[profileDic objectForKey:@"UserBirthDay"],[profileDic objectForKey:@"Gender"]);
        [self configurePhotoForCell:cell jid:[userListArray objectAtIndex:indexPath.row]];
    }
    return cell;
}
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                      reuseIdentifier:CellIdentifier];
//    }
////    UIImageView *userImage = (UIImageView*)[cell viewWithTag:2];
////    userImage.layer.cornerRadius = 20;
////    userImage.layer.masksToBounds = YES;
////    userImage.layer.borderWidth=1.5f;
////    userImage.layer.borderColor=[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0].CGColor;
////    UILabel* nameLabel = (UILabel*)[cell viewWithTag:1];
//    XMPPUserCoreDataStorageObject *user;
////    if (isSearch)
////    {
////        if (searchResultArray.count!=0)
////        {
////            user = [searchResultArray objectAtIndex:indexPath.row];
////        }
////        else
////        {
////            noRecordsLabel.hidden=NO;
////            noRecordsLabel.text=@"No records found.";
////            userListTableView.hidden=YES;
////        }
////    }
////    else
////    {
////        if (userListArr.count!=0)
////        {
////            user = [userListArr objectAtIndex:indexPath.row];
////        }
////    }
//    
////    nameLabel.text = [[[user displayName] componentsSeparatedByString:@"@52.74.174.129@"] objectAtIndex:0];
//    [self configurePhotoForCell:cell user:user];
//    return cell;
//}

//- (NSManagedObjectContext *)managedObjectContext {
//    NSManagedObjectContext *context = nil;
//    id delegate = [[UIApplication sharedApplication] delegate];
//    if ([delegate performSelector:@selector(managedObjectContext)]) {
//        context = [delegate managedObjectContext];
//    }
//    return context;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    ChatScreenViewController *profileObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatScreenViewController"];
    profileObj.friendUserJid=[userListArray objectAtIndex:indexPath.row];
    profileObj.friendUserName=[[profileLocalDictData objectForKey:[userListArray objectAtIndex:indexPath.row]] objectForKey:@"Name"];
    profileObj.loginUserName=[[profileLocalDictData objectForKey:appDelegate.xmppLogedInUserId] objectForKey:@"Name"];
    [self.navigationController pushViewController:profileObj animated:YES];
    
    
//    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    XMPPPresence *presence = [[XMPPPresence alloc] initWithType:@"type" to:[XMPPJID jidWithString:user.jidStr]];
//    [appDelegate.xmppStream sendElement:presence];
    
    
    //Set presence
//    XMPPPresence *presence = [XMPPPresence presence];
//    NSXMLElement *status = [NSXMLElement elementWithName:@"status"];
//    [status setStringValue:@"online/unavailable/away/busy/invisible"];
//    [presence addChild:status];
//    [[self xmppStream] sendElement:presence];
    //end
    
    
    
//    UserProfileViewController *profileObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
//    profileObj.friendId=[userListArray objectAtIndex:indexPath.row];
//    [self.navigationController pushViewController:profileObj animated:YES];
    
    
//    XMPPUserCoreDataStorageObject *user = [userDetailedList objectForKey:[userListArray objectAtIndex:indexPath.row]];
    
//    NSData *photoData1 = [[myDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:user.jidStr]];
//    UIImage *imagetemp=[UIImage imageWithData:photoData1];
//    NSString *resource = [[[user primaryResource] jid] resource];
//    
////    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
////    
//        NSLog(@"%@",[NSString stringWithFormat:@"%@",user.jidStr]);
    
//    appDelegate.updateProfileUserId=user.jidStr;
    
    
    
//    appDelegate.isUpdatePofile=YES;
//    appDelegate.updateProfileUserId=user.jidStr;
//        [appDelegate.xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:user.jidStr] ignoreStorage:YES];
//    
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSPredicate *pred;
//    NSMutableArray *results = [[NSMutableArray alloc]init];
//    pred = [NSPredicate predicateWithFormat:@"xmppRegisterId == %@", user.jidStr];
//    NSLog(@"predicate: %@",pred);
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"UserEntry"];
//    [fetchRequest setPredicate:pred];
//    
//    results = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
//    if (results.count>0) {
//        NSManagedObject *devicea = [results objectAtIndex:0];
//        NSLog(@"%@",[devicea valueForKey:@"xmppRegisterId"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppName"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppPhoneNumber"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppUserStatus"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppDescription"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppAddress"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppEmailAddress"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppUserBirthDay"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppGender"]);
//        NSLog(@"\n\n");
//
//    }
    
    
    
    
    
    
//    if ([user.jidStr isEqualToString:@"2222222222@ranosys"]) 
    
//    PersonalChatViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalChatViewController"];
//    if (isSearch)
//    {
//        vc.userDetail = [searchResultArray objectAtIndex:indexPath.row];
//        vc.lastView = @"UserListViewController";
//        if ([myDelegate.userProfileImage objectForKey:[[searchResultArray objectAtIndex:indexPath.row] jidStr]] == nil) {
//            vc.friendProfileImageView = [UIImage imageNamed:@"user_thumbnail.png"];
//        }
//        else{
//            vc.friendProfileImageView = [myDelegate.userProfileImage objectForKey:[[searchResultArray objectAtIndex:indexPath.row] jidStr]];
//        }
//        vc.userListVC = self;
//    }
//    else
//    {
//        vc.userDetail = [userListArr objectAtIndex:indexPath.row];
//        vc.lastView = @"UserListViewController";
//        if ([myDelegate.userProfileImage objectForKey:[[userListArr objectAtIndex:indexPath.row] jidStr]] == nil) {
//            vc.friendProfileImageView = [UIImage imageNamed:@"user_thumbnail.png"];
//        }
//        else{
//            vc.friendProfileImageView = [myDelegate.userProfileImage objectForKey:[[userListArr objectAtIndex:indexPath.row] jidStr]];
//        }
//        vc.userListVC = self;
//    }
//    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
//{
//    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
//    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
//    UIImageView *userImage = (UIImageView*)[cell viewWithTag:2];
//    
//    if (user.photo != nil)
//    {
//        userImage.image = user.photo;
//    }
//    else
//    {
//        NSData *photoData = [[myDelegate xmppvCardAvatarModule] photoDataForJID:user.jid];
//        
//        if (photoData != nil)
//            userImage.image = [UIImage imageWithData:photoData];
//        else
//            userImage.image = [UIImage imageNamed:@"images.png"];
//        
////        [myDelegate.userProfileImage setObject:userImage.image forKey:[NSString stringWithFormat:@"%@",user.jidStr]];
//    }
//}
- (void)configurePhotoForCell:(UITableViewCell *)cell jid:(NSString *)jid
{
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

//{
////    UIImageView *userImage = (UIImageView*)[cell viewWithTag:2];
//    
//    if (user.photo != nil)
//    {
////        userImage.image = user.photo;
//    }
//    else
//    {
//        NSData *photoData = [myDelegate.xmppvCardAvatarModule photoDataForJID:user.jid];
//        
////        if (photoData != nil)
////            userImage.image = [UIImage imageWithData:photoData];
////        else
////            userImage.image = [UIImage imageNamed:@"user_thumbnail.png"];
//        
////        [myDelegate.userProfileImage setObject:userImage.image forKey:[NSString stringWithFormat:@"%@",user.jidStr]];
//    }
//}
#pragma mark - end


#pragma mark - Custom accessors
- (void)addBarButton {
    
    UIBarButtonItem *logoutBarButton, *profileBarButton;
    CGRect framing = CGRectMake(0, 0, 30, 30.0);
    UIButton *logout = [[UIButton alloc] initWithFrame:framing];
    [logout setImage:[UIImage imageNamed:@"logout"] forState:UIControlStateNormal];
    logoutBarButton =[[UIBarButtonItem alloc] initWithCustomView:logout];
    [logout addTarget:self action:@selector(logoutAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *profile = [[UIButton alloc] initWithFrame:framing];
    //    [logout setTitle:@"Logout" forState:UIControlStateNormal];
    [profile setImage:[UIImage imageNamed:@"profile"] forState:UIControlStateNormal];
    profileBarButton =[[UIBarButtonItem alloc] initWithCustomView:profile];
    [profile addTarget:self action:@selector(profileAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:logoutBarButton,profileBarButton, nil];
    
    
    UIBarButtonItem *groupBarButton, *reloadBarButton;
    UIButton *group = [[UIButton alloc] initWithFrame:framing];
    [group setImage:[UIImage imageNamed:@"group"] forState:UIControlStateNormal];
    groupBarButton =[[UIBarButtonItem alloc] initWithCustomView:group];
    [group addTarget:self action:@selector(groupAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *reload = [[UIButton alloc] initWithFrame:framing];
    //    [group setTitle:@"Group" forState:UIControlStateNormal];
    [reload setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
    reloadBarButton =[[UIBarButtonItem alloc] initWithCustomView:reload];
    [reload addTarget:self action:@selector(reloadAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:groupBarButton,reloadBarButton, nil];
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)friendProfileAction:(UIButton *)sender {
    
    int tagValue=(int)[sender tag];
    UserProfileViewController *profileObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    profileObj.friendId=[userListArray objectAtIndex:tagValue];
    [self.navigationController pushViewController:profileObj animated:YES];
}

- (void)profileAction :(id)sender {
    
    UserProfileViewController *profileObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"UserProfileViewController"];
    profileObj.friendId=appDelegate.xmppLogedInUserId;
    [self.navigationController pushViewController:profileObj animated:YES];
    
    
//    appDelegate.isUpdatePofile=YES;
//    appDelegate.updateProfileUserId=appDelegate.xmppLogedInUserId;
////    [appDelegate.xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:self.xmppUserId] ignoreStorage:YES];
//    
//    NSData *photoData1 = [[myDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:appDelegate.xmppLogedInUserId]];
//    UIImage *imagetemp=[UIImage imageWithData:photoData1];
//    
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSPredicate *pred;
//    NSMutableArray *results = [[NSMutableArray alloc]init];
//    pred = [NSPredicate predicateWithFormat:@"xmppRegisterId == %@",appDelegate.xmppLogedInUserId];
//    NSLog(@"predicate: %@",pred);
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"UserEntry"];
//    [fetchRequest setPredicate:pred];
//    
//    results = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
//    if (results.count>0) {
//        NSManagedObject *devicea = [results objectAtIndex:0];
//        NSLog(@"%@",[devicea valueForKey:@"xmppRegisterId"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppName"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppPhoneNumber"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppUserStatus"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppDescription"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppAddress"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppEmailAddress"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppUserBirthDay"]);
//        NSLog(@"%@",[devicea valueForKey:@"xmppGender"]);
//        NSLog(@"\n\n");
//    }
}

- (void)reloadAction :(id)sender {
    
    profileLocalDictData=[NSMutableDictionary new];
    historyChatData=[NSMutableArray new];
    [myDelegate showIndicator];
    [self performSelector:@selector(reloadUserData) withObject:nil afterDelay:0.1];
}

- (void)reloadUserData {
    
    [self xmppUserRefreshResponse];
}

- (void)logoutAction :(id)sender {
    
    [UserDefaultManager removeValue:@"userName"];
    [self userLogout];
    
//    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
//    [myDelegate.navigationController setViewControllers: [NSArray arrayWithObject: objReveal]
//                                               animated: NO];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    myDelegate.navigationController = [storyboard instantiateViewControllerWithIdentifier:@"loginNavigation"];
    myDelegate.window.rootViewController = myDelegate.navigationController;
}

- (void)groupAction :(id)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *objGroupView = [storyboard instantiateViewControllerWithIdentifier:@"GroupConversationViewController"];
    [self.navigationController pushViewController:objGroupView animated:YES];
}
#pragma mark - end

- (void)addSegmentBar {
    
    customSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:
                              @[@"History", @"Contacts"]];
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
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        [self.dasboardTableListing reloadData];
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
        [self.dasboardTableListing reloadData];
    }
}
#pragma mark - end

- (void)showButton {
    
//    [self xmppUserRefreshResponse];
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UserEntry"];
    NSMutableArray *devices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    for (int i=0; i<devices.count; i++) {
        NSManagedObject *devicea = [devices objectAtIndex:i];
        NSLog(@"%@",[devicea valueForKey:@"xmppRegisterId"]);
        NSLog(@"%@",[devicea valueForKey:@"xmppName"]);
        NSLog(@"%@",[devicea valueForKey:@"xmppPhoneNumber"]);
        NSLog(@"%@",[devicea valueForKey:@"xmppUserStatus"]);
        NSLog(@"%@",[devicea valueForKey:@"xmppDescription"]);
        NSLog(@"%@",[devicea valueForKey:@"xmppAddress"]);
        NSLog(@"%@",[devicea valueForKey:@"xmppEmailAddress"]);
        NSLog(@"%@",[devicea valueForKey:@"xmppUserBirthDay"]);
        NSLog(@"%@",[devicea valueForKey:@"xmppGender"]);
        NSLog(@"\n\n");
    }
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)updateProfileInformation {

    profileLocalDictData=[self getProfileUsersData];
    [self.dasboardTableListing reloadData];
}

- (void)xmppNewUserAddedNotify {

    CGRect framing = CGRectMake(0, 0, 30, 30.0);
    UIBarButtonItem *groupBarButton, *reloadBarButton;
    UIButton *group = [[UIButton alloc] initWithFrame:framing];
    //    [group setTitle:@"Group" forState:UIControlStateNormal];
    [group setImage:[UIImage imageNamed:@"group"] forState:UIControlStateNormal];
    groupBarButton =[[UIBarButtonItem alloc] initWithCustomView:group];
    [group addTarget:self action:@selector(groupAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *reload = [[UIButton alloc] initWithFrame:framing];
    //    [group setTitle:@"Group" forState:UIControlStateNormal];
    [reload setImage:[UIImage imageNamed:@"reloadRed"] forState:UIControlStateNormal];
    reloadBarButton =[[UIBarButtonItem alloc] initWithCustomView:reload];
    [reload addTarget:self action:@selector(reloadAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:groupBarButton,reloadBarButton, nil];
}

- (void)xmppUserListResponse:(NSMutableDictionary *)xmppUserDetails xmppUserListIds:(NSMutableArray *)xmppUserListIds {

    [self addBarButton];
    userDetailedList=[xmppUserDetails mutableCopy];
    userListArray=[xmppUserListIds mutableCopy];
    
//    profileLocalDictData=[self getProfileUsersData];
                [self getProfileData1:^(NSDictionary *tempProfileData) {
                    // do something with your BOOL
                    profileLocalDictData=[tempProfileData mutableCopy];
                    [self.dasboardTableListing reloadData];
                }];
            
    
    
    [self fetchAllHistoryChat:^(NSMutableArray *tempHistoryData) {
        // do something with your BOOL
        
       [myDelegate stopIndicator];
        historyChatData=[tempHistoryData mutableCopy];
        [self.dasboardTableListing reloadData];
    }];
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
