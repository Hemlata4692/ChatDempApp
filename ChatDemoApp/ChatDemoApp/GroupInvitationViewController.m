//
//  GroupInvitationViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 07/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "GroupInvitationViewController.h"
#import "GroupInvideTableViewCell.h"
#import "GroupChatViewController.h"

@interface GroupInvitationViewController () {

    NSArray *friendJids;
    NSMutableDictionary *friendDetails, *selectedUnselectedFriends;
    NSMutableArray *selectedJids;
    NSMutableDictionary *groupInfoDic;
}

@property (strong, nonatomic) IBOutlet UIImageView *groupIcon;
@property (strong, nonatomic) IBOutlet UITextView *groupDescription;
@property (strong, nonatomic) IBOutlet UITableView *invitaionTableView;
@end

@implementation GroupInvitationViewController
@synthesize roomDescription, roomSubject, friendImage, roomJid;
@synthesize isCreate;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.navigationItem.title=roomSubject;
    
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back_white"]];
    [self initializedView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Custom accessors
- (void)addLeftBarButtonWithImage:(UIImage *)backImage {
    
    UIBarButtonItem *backBarButton;
    CGRect framing = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    UIButton *back = [[UIButton alloc] initWithFrame:framing];
    [back setBackgroundImage:backImage forState:UIControlStateNormal];
    backBarButton =[[UIBarButtonItem alloc] initWithCustomView:back];
    [back addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:backBarButton, nil];
}

- (void)initializedView {
    
    self.groupIcon.layer.masksToBounds=YES;
    self.groupIcon.layer.cornerRadius=25;
    
    friendJids=[[self fetchFriendJids] copy];
    friendDetails=[[self fetchFriendDetials] mutableCopy];
//    selectedUnselectedFriends=[NSMutableDictionary new];
    selectedJids=[NSMutableArray new];
//    for (NSString *jid in friendJids) {
//        
//        [selectedUnselectedFriends setObject:[NSNumber numberWithBool:false] forKey:jid];
//    }
    
    self.groupDescription.layer.borderColor=[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:0.5].CGColor;
    self.groupDescription.layer.borderWidth=1;

    self.groupDescription.text=roomDescription;
    if (([self.groupDescription.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)) {
        self.groupDescription.text=@"No description";
    }
    
    if (friendImage) {
        
        self.groupIcon.image=friendImage;
    }
    else {
    
        self.groupIcon.image=[UIImage imageNamed:@"groupPlaceholderImage.png"];
    }
}
#pragma mark - end

#pragma mark - Table view delegates
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
    
    return friendJids.count;
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
    static NSString *CellIdentifier = @"cell";
    
    GroupInvideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[GroupInvideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    [cell displayContactInformation:[[friendDetails objectForKey:[friendJids objectAtIndex:indexPath.row]] mutableCopy] isSelected:[selectedJids containsObject:[friendJids objectAtIndex:indexPath.row]]];
    [self configurePhotoForCell:cell jid:[friendJids objectAtIndex:indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([selectedJids containsObject:[friendJids objectAtIndex:indexPath.row]]) {
        [selectedJids removeObject:[friendJids objectAtIndex:indexPath.row]];
    }
    else {
        [selectedJids addObject:[friendJids objectAtIndex:indexPath.row]];
    }
    [self.invitaionTableView reloadData];
}

- (void)configurePhotoForCell:(GroupInvideTableViewCell *)cell jid:(NSString *)jid {
    
    // Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
    // We only need to ask the avatar module for a photo, if the roster doesn't have it.
    [self getProfilePhotosJid:jid profileImageView:cell.friendProfilePhoto placeholderImage:@"images.png" result:^(UIImage *tempImage) {
        // do something with your BOOL
        if (tempImage!=nil) {
            cell.friendProfilePhoto.image=tempImage;
        }
        else {
            
            cell.friendProfilePhoto.image=[UIImage imageNamed:@"images.png"];
        }
    }];
}
#pragma mark - end

#pragma mark - IBActions
//Back button action
- (void)backButtonAction :(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createGroup:(UIButton *)sender {

    if (isCreate) {
        
        [myDelegate showIndicator];
        [self performSelector:@selector(creteGroupService) withObject:nil afterDelay:0.1];
    }
    else {
       
        if (selectedJids.count>0) {
            [self sendFriendInvitation];
        }
    }
}

- (void)creteGroupService {

    if ([self image:self.groupIcon.image isEqualTo:[UIImage imageNamed:@"groupPlaceholderImage.png"]]) {
        
        [self createChatRoom:nil groupDescription:roomDescription groupSubject:roomSubject];
    }
    else {
        [self createChatRoom:self.groupIcon.image groupDescription:roomDescription groupSubject:roomSubject];
    }
}
#pragma mark - end

- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}

#pragma mark - XMPPGroupChatRoom result methods
- (void)newChatGroupCreated:(NSMutableDictionary *)groupInfo {

    groupInfoDic=[groupInfo mutableCopy];
    if (selectedJids.count>0) {
        [self sendFriendInvitation];
    }
    else {
        [myDelegate stopIndicator];
        GroupChatViewController *groupChatObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
        groupChatObj.roomDetail=[groupInfo mutableCopy];
        [self.navigationController pushViewController:groupChatObj animated:YES];
    }
}

- (void)sendFriendInvitation {

    [self sendGroupInvitation:[selectedJids copy]];
}

- (void)invitationSended {

    if (isCreate) {
        
        [myDelegate stopIndicator];
        GroupChatViewController *groupChatObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
        groupChatObj.roomDetail=[groupInfoDic mutableCopy];
        [self.navigationController pushViewController:groupChatObj animated:YES];
    }
    else {
        
        [self.navigationController popViewControllerAnimated:YES];
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
