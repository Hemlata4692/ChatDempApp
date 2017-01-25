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

#import "XMPPvCardTemp.h"
#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPvCardCoreDataStorage.h"


@class XMPPvCardTempModuleStorage;
@interface DashboardViewController () {

    HMSegmentedControl *customSegmentedControl;
}
@property (strong, nonatomic) IBOutlet UITableView *dasboardTableListing;
@end

@implementation DashboardViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"Dashboard";
    [self addBarButton];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if ([myDelegate connect])
    {
        [self fetchedResultsController];
        [self.dasboardTableListing reloadData];
        
        //        NSData *photoData1 = [[myDelegate xmppvCardAvatarModule] photoDataForJID:[XMPPJID jidWithString:@"1234567890@ranosys"]];
        //        UIImage *imagetemp=[UIImage imageWithData:photoData1];
        //        NSLog(@"d");
        //         NSLog(@"a");
        XMPPvCardTemp *newvCardTemp = [[myDelegate xmppvCardTempModule] vCardTempForJID:[XMPPJID jidWithString:[NSString stringWithFormat:@"2135647878@%@",myDelegate.hostName]] shouldFetch:YES];
        
        NSLog(@"%@",newvCardTemp.userStatus);
        NSLog(@"%@",newvCardTemp.emailAddress);
    }
    [self addSegmentBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - XMPP delegates
- (XMPPStream *)xmppStream
{
    return [myDelegate xmppStream];
}
- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [myDelegate managedObjectContext_roster];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:10];
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            //error
        }
    }
    return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
//    NSArray *sections = [[self fetchedResultsController] sections];
////    [sortArrSet removeAllObjects];
//    for (int i = 0 ; i< [[[self fetchedResultsController] sections] count];i++) {
//        for (int j = 0; j<[[sections objectAtIndex:i] numberOfObjects]; j++) {
//            if (([[[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]] displayName] != nil) && ![[[[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]] displayName] isEqualToString:@""] && ([[[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]] displayName] != NULL)) {
//                
//                if ([[[[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]] displayName] containsString:@"52.74.174.129"]) {
//                    NSString *myName = [[[[[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]] displayName] componentsSeparatedByString:@"@52.74.174.129@"] objectAtIndex:1];
//                    
////                    if (!([myName intValue] <= [yearValue intValue] - 3) || ((([yearValue intValue] - 3) == [myName intValue]) && [checkCompare isEqualToString:@"L"])) {
////                        [sortArrSet addObject:[[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]]];
////                    }
//                }
//                
//            }
//        }
//    }
//    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
////    userListArr = [[sortArrSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]] mutableCopy];
    [self.dasboardTableListing reloadData];
}
#pragma mark - end

#pragma mark - Table view delegates
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 50;
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
    NSArray *sections = [[self fetchedResultsController] sections];
    
    if (sectionIndex < [sections count])
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        return sectionInfo.numberOfObjects;
    }
    
    return 0;
    //return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsController] sections] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView;
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
    
    return headerView;
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
    
    XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    if ([user.jidStr isEqualToString:@"2222222222@ranosys"]) {
        
        NSLog(@"a");
//        - (XMPPvCardTemp *)vCardTempForJID:(XMPPJID *)jid xmppStream:(XMPPStream *)stream
//        XMPPvCardTemp *newvCardTemp = [[myDelegate xmppvCardTempModule] vCardTempForJID:user.jid shouldFetch:YES];
        NSLog(@"a");
    }
    UILabel* nameLabel = (UILabel*)[cell viewWithTag:1];
    nameLabel.text = user.displayName;
    [self configurePhotoForCell:cell user:user];
    
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    UIImageView *userImage = (UIImageView*)[cell viewWithTag:2];
    
    if (user.photo != nil)
    {
        userImage.image = user.photo;
    }
    else
    {
        NSData *photoData = [[myDelegate xmppvCardAvatarModule] photoDataForJID:user.jid];
        
        if (photoData != nil)
            userImage.image = [UIImage imageWithData:photoData];
        else
            userImage.image = [UIImage imageNamed:@"images.png"];
        
//        [myDelegate.userProfileImage setObject:userImage.image forKey:[NSString stringWithFormat:@"%@",user.jidStr]];
    }
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
    
    UIBarButtonItem *logoutBarButton;
    CGRect framing = CGRectMake(0, 0, 60, 30.0);
    UIButton *logout = [[UIButton alloc] initWithFrame:framing];
    [logout setTitle:@"Logout" forState:UIControlStateNormal];
    logoutBarButton =[[UIBarButtonItem alloc] initWithCustomView:logout];
    [logout addTarget:self action:@selector(logoutAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:logoutBarButton, nil];
    
    UIBarButtonItem *groupBarButton;
    UIButton *group = [[UIButton alloc] initWithFrame:framing];
    [group setTitle:@"Group" forState:UIControlStateNormal];
    groupBarButton =[[UIBarButtonItem alloc] initWithCustomView:group];
    [group addTarget:self action:@selector(groupAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:groupBarButton, nil];
}
#pragma mark - end

#pragma mark - IBActions
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
        
    }
    else if (segmentedControl.selectedSegmentIndex == 1) {
        
    }
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
