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
#import "UIPlaceHolderTextView.h"

#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPP.h"
#import "NSData+XMPP.h"
#import "CustomFilterViewController.h"

#import "BSKeyboardControls.h"
#import "GroupChatTableViewCell.h"
#import "SendImageViewController.h"
#import "DocumentAttachmentViewController.h"
#import "UserDefaultManager.h"
#import <AVFoundation/AVFoundation.h>
#import "LocationViewController.h"

#define navigationBarHeight 64
#define toolbarHeight 0
#define messageTextviewInitialHeight 40
#define messageTextviewHeightLimit 126

#define nameLabelFont [UIFont systemFontOfSize:17]
#define messageLabelFont [UIFont systemFontOfSize:15]
#define dateLabelFont [UIFont systemFontOfSize:14]
#define messageTextViewFont [UIFont systemFontOfSize:17]

@interface GroupChatViewController ()<CustomFilterDelegate,/*BSKeyboardControlsDelegate,*/UIGestureRecognizerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, SendImageDelegate, SendDocumentDelegate,UIDocumentInteractionControllerDelegate,SendLocationDelegate> {

    UIImage *groupImageIcon;
    NSMutableArray *groupMemberList;
    
    CGFloat messageHeight, messageYValue;
    NSMutableArray *userData;
    int btnTag;
    
    //    NSString *loginUserId, *friendUserId;
    UIImage *logedInUserPhoto, *friendUserPhoto;
    
    //Navigation views
    UIView *navBackView;
    UILabel *navTitleLabel, *navStatusLabel;
    
    float keyboardHeight;
    
    BOOL isAttachmentOpen, isReceiptOffline;
    UIView *imagePreviewView;
}

@property (strong, nonatomic) IBOutlet UITableView *chatTableView;
@property (strong, nonatomic) IBOutlet UIView *messageView;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *messageTextView;
@property (strong, nonatomic) IBOutlet UIButton *sendButtonOutlet;

@property (retain,nonatomic) UIDocumentInteractionController *docController;
@property (strong, nonatomic) IBOutlet UIImageView *sendImage;

//Declare BSKeyboard variable
//@property (strong, nonatomic) BSKeyboardControls *keyboardControls;
@end

@implementation GroupChatViewController
@synthesize userDetail, userXmlDetail;
@synthesize messageTextView, sendButtonOutlet;
@synthesize messageView;
@synthesize chatTableView;
@synthesize lastView,meeToProfile,userNameProfile;
@synthesize userProfileImageView, friendProfileImageView;

@synthesize friendUserJid;
@synthesize roomDetail;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=[roomDetail objectForKey:@"roomName"];
    
    [self appDelegateVariableInitializedGroupSubject:[roomDetail objectForKey:@"roomName"] groupDescription:[roomDetail objectForKey:@"roomDescription"] groupJid:[roomDetail objectForKey:@"roomJid"] ownerJid:[roomDetail objectForKey:@"roomOwnerJid"]];
    [self joinChatRoomJid:[roomDetail objectForKey:@"roomJid"]];
    [self addBarButtons];
    isAttachmentOpen=false;
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
    
    
    if (!isAttachmentOpen) {
        [super viewWillAppear:YES];
        [self viewInitialized]; //Initialised view
        [self registerForKeyboardNotifications];
        
        //    self.tabBarController.tabBar.hidden=NO;
        //    [[self navigationController] setNavigationBarHidden:NO];
        //    [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [myDelegate showIndicator];
        [self performSelector:@selector(getHistoryChatData) withObject:nil afterDelay:.1];
    }
    else {
        isAttachmentOpen=false;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - UIView initialized
- (void)viewInitialized {
    
    //Add tapGesture at UITableView
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapGestureOnView:)];
    [chatTableView addGestureRecognizer:singleFingerTap];
    
    /*
     //Adding textfield to keyboard controls array
     [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[self.messageTextView]]];
     [self.keyboardControls setDelegate:self];
     */
    
//    switch ([self getPresenceStatus:friendUserJid]) {
//        case 0:     // online/available
//            [self userOnline];
//            break;
//        default:    //offline
//            [self userOffline];
//            break;
//    }
//    [self setProfileImagesUsingCompletionBlock];
    
    messageView.translatesAutoresizingMaskIntoConstraints = YES;
    messageTextView.translatesAutoresizingMaskIntoConstraints = YES;
    chatTableView.translatesAutoresizingMaskIntoConstraints = YES;
    
    messageTextView.text = @"";
    [messageTextView setPlaceholder:@"Type a message here..."];
    [messageTextView setFont:messageTextViewFont];
    messageTextView.backgroundColor = [UIColor whiteColor];
    messageTextView.contentInset = UIEdgeInsetsMake(-5, 5, 0, 0);
    messageTextView.layer.cornerRadius=4.0;
    messageTextView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    messageTextView.layer.borderWidth=1.0;
    
    messageTextView.alwaysBounceHorizontal = NO;
    messageTextView.bounces = NO;
    userData = [NSMutableArray new];
    
    messageView.backgroundColor = [UIColor whiteColor];
    messageHeight = messageTextviewInitialHeight;
    messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height- messageHeight - 10 - navigationBarHeight, self.view.bounds.size.width, messageHeight + 10);
    messageTextView.frame = CGRectMake(8, 5, messageView.frame.size.width - 8 - 64, messageHeight - 8);
    messageYValue = messageView.frame.origin.y;
    if ([messageTextView.text isEqualToString:@""] || messageTextView.text.length == 0) {
        sendButtonOutlet.enabled = NO;
    }
    else{
        sendButtonOutlet.enabled = YES;
    }
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(historUpdated:) name:@"UserHistory" object:nil];
    
    chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (messageHeight +10+navigationBarHeight+2));
}

- (void)addBarButtons {
    
    UIBarButtonItem *backBarButton,*menuBarButton;
    CGRect framing = CGRectMake(0, 0, 25, 25);
    
    UIButton *back = [[UIButton alloc] initWithFrame:framing];
    [back setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backBarButton =[[UIBarButtonItem alloc] initWithCustomView:back];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=backBarButton;

    if ([self isOwner]) {
        UIButton *menu = [[UIButton alloc] initWithFrame:framing];
        [menu setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
        menuBarButton =[[UIBarButtonItem alloc] initWithCustomView:menu];
        [menu addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem=menuBarButton;
    }
}
#pragma mark - end

#pragma mark - Keyboard delegates
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSLog(@"%f",[aValue CGRectValue].size.height);
    messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height- [aValue CGRectValue].size.height -(messageHeight+10+navigationBarHeight) , [UIScreen mainScreen].bounds.size.width, messageHeight+ 10);
    keyboardHeight=[aValue CGRectValue].size.height;
    messageYValue = [UIScreen mainScreen].bounds.size.height- [aValue CGRectValue].size.height -(messageHeight+10+navigationBarHeight);
    
    NSLog(@"%f",[UIScreen mainScreen].bounds.size.height- [aValue CGRectValue].size.height -(messageHeight+10+navigationBarHeight));
    chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, messageView.frame.origin.y-2);
    if (userData.count > 0) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
        [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height- messageView.frame.size.height -navigationBarHeight, self.view.bounds.size.width, messageHeight+ 10);
    messageYValue = [UIScreen mainScreen].bounds.size.height -49 -10;
    chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, messageView.frame.origin.y-2);
    if (userData.count > 0) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
        [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}
#pragma mark - end

#pragma mark - Textfield delegates
- (void)textViewDidBeginEditing:(UITextView *)textView {
    //handle user taps text view to type text
    
    //    [self.keyboardControls setActiveField:textView];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //    if([text isEqualToString:@"\n"]) {
    //        [textView resignFirstResponder];
    //        return NO;
    //    }
    if ([text isEqualToString:[UIPasteboard generalPasteboard].string]) {
        
        CGSize size = CGSizeMake(messageTextView.frame.size.height,messageTextviewHeightLimit);
        NSString *string = textView.text;
        NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        text = [NSString stringWithFormat:@"%@%@",messageTextView.text,text];
        CGRect textRect=[text
                         boundingRectWithSize:size
                         options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:@{NSFontAttributeName:messageTextViewFont}
                         context:nil];
        
        if ((textRect.size.height < messageTextviewHeightLimit) && (textRect.size.height > 50)) {
            
            messageTextView.frame = CGRectMake(messageTextView.frame.origin.x, messageTextView.frame.origin.y, messageTextView.frame.size.width, textRect.size.height);
            messageHeight = messageTextView.frame.size.height + 8;
            messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height- keyboardHeight -(messageHeight+10+navigationBarHeight) , [UIScreen mainScreen].bounds.size.width, messageHeight+ 10);
            
            chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, messageView.frame.origin.y-2);
            if (userData.count > 0) {
                NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
                [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        }
        else if(textRect.size.height <= 50){
            
            messageHeight = messageTextviewInitialHeight;
            
            messageTextView.frame = CGRectMake(messageTextView.frame.origin.x, messageTextView.frame.origin.y, messageTextView.frame.size.width, messageHeight-8);
            messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-(keyboardHeight+navigationBarHeight+messageHeight+10)  , self.view.bounds.size.width, messageHeight + 10);
            chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, messageView.frame.origin.y-2);
            if (userData.count > 0) {
                NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
                [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            }
        }
        if (textView.text.length>=1) {
            
            if (trimmedString.length>=1) {
                sendButtonOutlet.enabled=YES;
            }
            else{
                sendButtonOutlet.enabled=NO;
            }
        }
        else if (textView.text.length==0) {
            sendButtonOutlet.enabled=NO;
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (([messageTextView sizeThatFits:messageTextView.frame.size].height < messageTextviewHeightLimit) && ([messageTextView sizeThatFits:messageTextView.frame.size].height > 50)) {
        
        messageTextView.frame = CGRectMake(messageTextView.frame.origin.x, messageTextView.frame.origin.y, messageTextView.frame.size.width, [messageTextView sizeThatFits:messageTextView.frame.size].height);
        messageHeight = messageTextView.frame.size.height + 8;
        messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height- keyboardHeight -(messageHeight+10+navigationBarHeight) , [UIScreen mainScreen].bounds.size.width, messageHeight+ 10);
        
        chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, messageView.frame.origin.y-2);
        if (userData.count > 0) {
            NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
            [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
    else if([messageTextView sizeThatFits:messageTextView.frame.size].height <= 50){
        messageHeight = messageTextviewInitialHeight;
        
        messageTextView.frame = CGRectMake(messageTextView.frame.origin.x, messageTextView.frame.origin.y, messageTextView.frame.size.width, messageHeight-8);
        messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-(keyboardHeight+navigationBarHeight+messageHeight+10)  , self.view.bounds.size.width, messageHeight + 10);
        chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, messageView.frame.origin.y-2);
        if (userData.count > 0) {
            NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
            [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
    
    NSString *string = textView.text;
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (textView.text.length>=1) {
        if (trimmedString.length>=1) {
            sendButtonOutlet.enabled=YES;
        }
        else if (trimmedString.length==0) {
            sendButtonOutlet.enabled=NO;
        }
    }
    else if (textView.text.length==0) {
        sendButtonOutlet.enabled=NO;
    }
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)tapGestureOnView:(UITapGestureRecognizer *)sender {
    [messageTextView resignFirstResponder];
}

- (void)tappedOnImageView:(UIGestureRecognizer *)sender {
    
    [self.view endEditing:YES];
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSXMLElement *innerData=[[userData objectAtIndex:(int)gesture.view.tag] elementForName:@"data"];
    
    if ([[innerData attributeStringValueForName:@"groupType"] isEqualToString:@"FileAttachment"]) {
        NSURL *url = [NSURL fileURLWithPath:[myDelegate documentCacheDirectoryPathFileName:[innerData attributeStringValueForName:@"fileName"]]];
        self.docController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docController.delegate = self;
        [self.docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    }
    else if ([[innerData attributeStringValueForName:@"groupType"] isEqualToString:@"ImageAttachment"]) {
        
        imagePreviewView=[[UIView alloc] initWithFrame:CGRectMake(0,self.view.bounds.size.height,self.view.bounds.size.width,self.view.bounds.size.height)];
        UIImageView *popImage=[[UIImageView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
        imagePreviewView.backgroundColor = [UIColor blackColor];
        popImage.contentMode = UIViewContentModeScaleAspectFit;
        popImage.backgroundColor = [UIColor clearColor];
        popImage.image=[UIImage imageWithData:[myDelegate listionSendAttachedImageCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
        //    [userData objectAtIndex:(int)gesture.view.tag]
        UIButton *close_button=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60,10,48,48)];
        [close_button setImage:[UIImage imageNamed:@"cross"] forState:UIControlStateNormal];
        [close_button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        [imagePreviewView addSubview:popImage];
        [imagePreviewView addSubview:close_button];
        [self.view addSubview:imagePreviewView];
        
        [UIView animateWithDuration:0.3f animations:^{
            imagePreviewView.frame = CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height);
        }];
    }
    else if ([[innerData attributeStringValueForName:@"groupType"] isEqualToString:@"Location"]) {
        
        NSXMLElement *innerLocationData=[[userData objectAtIndex:(int)gesture.view.tag] elementForName:@"location"];
        isAttachmentOpen=true;
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LocationViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"LocationViewController"];
        popupView.address=[[[userData objectAtIndex:(int)gesture.view.tag] elementForName:@"body"] stringValue];
        popupView.latitude=[NSNumber numberWithDouble:[[innerLocationData attributeStringValueForName:@"latitude"] doubleValue]];
        popupView.longitude=[NSNumber numberWithDouble:[[innerLocationData attributeStringValueForName:@"longitude"] doubleValue]];
        [self presentViewController:popupView animated:YES completion:NULL];
    }
}

- (IBAction)closeAction:(id)sender {
    
    [UIView animateWithDuration:0.3f animations:^{
        imagePreviewView.frame = CGRectMake(0,self.view.bounds.size.height,self.view.bounds.size.width,self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [imagePreviewView removeFromSuperview];
    }];
}

-(IBAction)sendMessage:(id)sender {
    
//    [self sendXmppMessage:friendUserJid friendName:self.friendUserName messageString:messageTextView.text];
}

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
    
//    if ([self isOwner]) {
    
        [tempAttachment setObject:[NSNumber numberWithInt:1] forKey:@"Add Member"];
        [tempAttachmentArra addObject:@"Add Member"];
        [tempAttachmentImageArra addObject:@"inviteNewMember"];
        [tempAttachment setObject:[NSNumber numberWithInt:2] forKey:@"Delete Group"];
        [tempAttachmentArra addObject:@"Delete Group"];
        [tempAttachmentImageArra addObject:@"deleteGroup"];
        filterViewObj.filterDict=[tempAttachment mutableCopy];
        filterViewObj.filterArray=[tempAttachmentArra mutableCopy];
        filterViewObj.filterImageArray=[tempAttachmentImageArra mutableCopy];
//    }
//    else {
//    
//        [tempAttachment setObject:[NSNumber numberWithInt:1] forKey:@"AddNewMember"];
//        [tempAttachmentArra addObject:@"Add Member"];
//        [tempAttachmentImageArra addObject:@"inviteNewMember"];
//        filterViewObj.filterDict=[tempAttachment mutableCopy];
//        filterViewObj.filterArray=[tempAttachmentArra mutableCopy];
//        filterViewObj.filterImageArray=[tempAttachmentImageArra mutableCopy];
//    }
    
    [filterViewObj setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:filterViewObj animated:NO completion:nil];
}

- (void)inviteAction {
    
    GroupInvitationViewController *invitationViewObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupInvitationViewController"];
    invitationViewObj.roomSubject=[roomDetail objectForKey:@"roomName"];
    invitationViewObj.roomDescription=[roomDetail objectForKey:@"roomDescription"];
    if (![self image:groupImageIcon isEqualTo:[UIImage imageNamed:@"groupPlaceholderImage.png"]]) {
        invitationViewObj.friendImage=groupImageIcon;
    }
    else {
        
        invitationViewObj.friendImage=nil;
    }
    invitationViewObj.roomJid=[roomDetail objectForKey:@"roomJid"];
    invitationViewObj.alreadyAddJids=[groupMemberList mutableCopy];
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
    
    
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (status==1) {
//            NSLog(@"1");
//            
//            UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            DocumentAttachmentViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"DocumentAttachmentViewController"];
//            [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
//            popupView.delegate=self;
//            [self presentViewController:popupView animated:YES completion:nil];
//        }
//        else if (status==2) {
//            NSLog(@"2");
//            [self openCamera];
//        }
//        else if (status==3) {
//            NSLog(@"3");
//            [self openGallery];
//        }
//        else if (status==4) {
//            NSLog(@"3");
//            isAttachmentOpen=true;
//            UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            LocationViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"LocationViewController"];
//            //            [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
//            popupView.delegate=self;
//            
//            [self presentViewController:popupView animated:YES completion:NULL];
//        }
//    });
}
#pragma mark - end

#pragma mark - XMPPGroupChat method
- (void)groupJoined:(NSMutableArray *)memberList {

    //Group joined
    groupMemberList=[memberList mutableCopy];
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

- (void)newChatGroupCreated:(NSMutableDictionary *)groupInfo {
    
    [self addBarButtons];
}
#pragma mark - end

#pragma mark - Table view delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return userData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSXMLElement* message = [userData objectAtIndex:indexPath.row];
    NSXMLElement *innerData=[message elementForName:@"data"];
    
    if ([[innerData attributeStringValueForName:@"groupType"] isEqualToString:@"ImageAttachment"]||[[innerData attributeStringValueForName:@"groupType"] isEqualToString:@"FileAttachment"]||[[innerData attributeStringValueForName:@"groupType"] isEqualToString:@"Location"]) {
        
        float mainCellHeight=5+[[innerData attributeStringValueForName:@"nameHeight"] floatValue]+10+[[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]+10+20+5; //here mainCellHeight = NameLabel_topSpace + NameHeight + space_Between_NameLabel_And_MessageLabel + MessageHeight + space_Between_MessageLabel_And_DateLabel + DateLabelHeight + DateLabel_BottomSpace
        float innerCellHeight=5+[[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]+10+20+5; //here innerCellHeight = MessageLabel_topSpace + MessageHeight + space_Between_MessageLabel_And_DateLabel + DateLabelHeight + DateLabel_BottomSpace
        
        if (userData.count==1 || indexPath.row == 0) {
            if (mainCellHeight > 90) {
                return mainCellHeight + (10+128);//(10+128)=(topAndBottomSpace of image+ imageHeight)
            }
            else{
                
                if ([[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]<2.0) {
                    return 200;
                }
                return 225;
            }
        }
        else{
            NSXMLElement* message1 = [userData objectAtIndex:(int)indexPath.row - 1];
            NSXMLElement *innerData1=[message1 elementForName:@"data"];
            if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
                
                return innerCellHeight+(10+128);//(10+128)=(topAndBottomSpace of image+ imageHeight)
            }
            else{
                if (mainCellHeight > 90) {
                    return mainCellHeight + (10+128);//(10+128)=(topAndBottomSpace of image+ imageHeight)
                }
                else{
                    
                    if ([[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]<2.0) {
                        return 200;
                    }
                    return 225;
                }
            }
        }
    }
    else {
        
        float mainCellHeight=5+[[innerData attributeStringValueForName:@"nameHeight"] floatValue]+10+[[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]+10+20+5; //here mainCellHeight = NameLabel_topSpace + NameHeight + space_Between_NameLabel_And_MessageLabel + MessageHeight + space_Between_MessageLabel_And_DateLabel + DateLabelHeight + DateLabel_BottomSpace
        float innerCellHeight=5+[[innerData attributeStringValueForName:@"messageBodyHeight"] floatValue]+10+20+5; //here innerCellHeight = MessageLabel_topSpace + MessageHeight + space_Between_MessageLabel_And_DateLabel + DateLabelHeight + DateLabel_BottomSpace
        
        if (userData.count==1 || indexPath.row == 0) {
            if (mainCellHeight > 90) {
                return mainCellHeight;
            }
            else{
                return 90;
            }
        }
        else{
            NSXMLElement* message1 = [userData objectAtIndex:(int)indexPath.row - 1];
            NSXMLElement *innerData1=[message1 elementForName:@"data"];
            if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
                return innerCellHeight;
            }
            else{
                if (mainCellHeight > 90) {
                    return mainCellHeight;
                }
                else{
                    return 90;
                }
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GroupChatTableViewCell *cell;
    
    cell=[chatTableView dequeueReusableCellWithIdentifier:@"chatCell"];
    if (cell == nil)
    {
        cell=[[GroupChatTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"chatCell"];
    }
    
    cell.attachedImageView.tag=indexPath.row;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnImageView:)];
    [cell.attachedImageView addGestureRecognizer:tap];
    [cell.attachedImageView setUserInteractionEnabled:YES];
    
    NSXMLElement* message = [userData objectAtIndex:indexPath.row];
    NSXMLElement *innerData=[message elementForName:@"data"];
    if (userData.count==1) {
        
        [cell displaySingleMessageData:message profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto chatType:[innerData attributeStringValueForName:@"groupType"]];
    }
    else if (userData.count>(indexPath.row+1)) {
        
        if ((int)indexPath.row==0) {
            
            [cell displayFirstMessage:message nextmessage:[userData objectAtIndex:indexPath.row+1] profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto chatType:[innerData attributeStringValueForName:@"groupType"]];
        }
        else {
            [cell displayMultipleMessage:message nextmessage:[userData objectAtIndex:indexPath.row+1] previousMessage:[userData objectAtIndex:indexPath.row-1] profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto  chatType:[innerData attributeStringValueForName:@"groupType"]];
        }
    }
    else {
        [cell displayLastMessage:message previousMessage:[userData objectAtIndex:indexPath.row-1] profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto  chatType:[innerData attributeStringValueForName:@"groupType"]];
    }
    return cell;
}

-(NSIndexPath *)indexPathForLastMessage
{
    NSInteger lastSection = 0;
    NSInteger numberOfMessages = userData.count;
    return [NSIndexPath indexPathForRow:numberOfMessages-1 inSection:lastSection];
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

#pragma mark - XMPP delegates
- (XMPPStream *)xmppStream {
    
    return [myDelegate xmppStream];
}
#pragma mark - end

#pragma mark - Custom filter delegate
- (void)openGallery {
    
    isAttachmentOpen=true;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.navigationBar.tintColor = [UIColor whiteColor];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)openCamera {
    
    isAttachmentOpen=true;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else if(authStatus == AVAuthorizationStatusDenied){
        
        [UserDefaultManager showAlertMessage:@"Camera Access" message:@"Without permission to use your camera, you won't be able to take photo.\nGo to your device settings and then Privacy to grant permission."];
    }
    else if(authStatus == AVAuthorizationStatusRestricted){
        
        [UserDefaultManager showAlertMessage:@"Camera Access" message:@"Without permission to use your camera, you won't be able to take photo.\nGo to your device settings and then Privacy to grant permission."];
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined){
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.allowsEditing = YES;
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:picker animated:YES completion:NULL];
                });
            }
            
        }];
    }
}
#pragma mark - end

#pragma mark - ImagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:NO completion:NULL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SendImageViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"SendImageViewController"];
    [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    popupView.delegate=self;
    popupView.attachImage=image;
    [self presentViewController:popupView animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - end

#pragma mark - Fetch history data
- (void)getHistoryChatData {
    
//    [self getHistoryChatData:friendUserJid];
}
#pragma mark - end

#pragma mark - Send text message response
- (void)XmppSendMessageResponse:(NSXMLElement *)xmpMessage {
    
    [self messagesData:xmpMessage];
    messageTextView.text=@"";
    messageHeight = messageTextviewInitialHeight;
    messageTextView.frame = CGRectMake(messageTextView.frame.origin.x, messageTextView.frame.origin.y, messageTextView.frame.size.width, messageHeight-8);
    messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-(keyboardHeight+navigationBarHeight+messageHeight+10)  , self.view.bounds.size.width, messageHeight + 10);
    chatTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, messageView.frame.origin.y-2);
    if (userData.count > 0) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
        [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    if (messageTextView.text.length>=1) {
        sendButtonOutlet.enabled=YES;
    }
    else if (messageTextView.text.length==0) {
        sendButtonOutlet.enabled=NO;
    }
    [chatTableView reloadData];
}

- (void)messagesData:(NSXMLElement*)message{
    
    message=[self setHeightInMessage:message];
    [userData addObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
    [chatTableView beginUpdates];
    [chatTableView insertRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationBottom];
    [chatTableView endUpdates];
    [chatTableView scrollToRowAtIndexPath:[self indexPathForLastMessage]
                         atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [chatTableView reloadData];
}

- (NSXMLElement *)setHeightInMessage:(NSXMLElement*)message {
    
    NSXMLElement *innerData=[message elementForName:@"data"];
    //Set userName height
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width - (76+8),200);//here (76+8) = (nameLabel.x + label trailing)
    CGRect textRect=[[innerData attributeStringValueForName:@"senderName"]
                     boundingRectWithSize:size
                     options:NSStringDrawingUsesLineFragmentOrigin
                     attributes:@{NSFontAttributeName:nameLabelFont}
                     context:nil];
    [innerData addAttributeWithName:@"nameHeight" numberValue:[NSNumber numberWithFloat:textRect.size.height]];
    
    if (![[[message elementForName:@"body"] stringValue] isEqualToString:@""]) {
        //Set message height
        size = CGSizeMake([[UIScreen mainScreen] bounds].size.width - (76+8),4000);//here (76+8) = (nameLabel.x + label trailing)
        textRect=[[[message elementForName:@"body"] stringValue]
                  boundingRectWithSize:size
                  options:NSStringDrawingUsesLineFragmentOrigin
                  attributes:@{NSFontAttributeName:messageLabelFont}
                  context:nil];
        [innerData addAttributeWithName:@"messageBodyHeight" numberValue:[NSNumber numberWithFloat:textRect.size.height]];
    }
    else {
        
        [innerData addAttributeWithName:@"messageBodyHeight" numberValue:[NSNumber numberWithFloat:0.0]];
    }
    
    return message;
}
#pragma mark - end

#pragma mark - XMPPChatView response method
//History data response
- (void)historyData:(NSMutableArray *)result{
    
    userData=[result mutableCopy];
    for (int i=0; i<userData.count; i++) {
        NSXMLElement *tempMessage=[userData objectAtIndex:i];
        NSXMLElement *innertext=[tempMessage elementForName:@"data"];
        if (nil==[innertext attributeStringValueForName:@"messageBodyHeight"]) {
            tempMessage=[self setHeightInMessage:tempMessage];
            [userData replaceObjectAtIndex:i withObject:tempMessage];
        }
    }
    [self.chatTableView reloadData];
    if (userData.count > 0) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
        [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    [myDelegate stopIndicator];
}

- (void)XmppUserPresenceUpdateNotify {
    
//    switch ([self getPresenceStatus:friendUserJid]) {
//        case 0:     // online/available
//            [self userOnline];
//            break;
//        default:    //offline
//            [self userOffline];
//            break;
//    }
}

- (void)historyUpdateNotify:(NSXMLElement *)message {
    
    [self messagesData:message];
}

#pragma mark - Send image delegates
- (void)sendImageDelegateAction:(int)status imageName:(NSString *)imageName imageCaption:(NSString *)imageCaption {
    
    if (status==1) {
        
//        [self sendImageAttachment:imageName imageCaption:imageCaption friendName:self.friendUserName];//friendName:self.friendUserName
    }
}

- (void)sendFileSuccessDelegate:(NSXMLElement *)message uniquiId:(NSString *)uniqueId {
    
    [self setAttachmentMessage:message uniquiId:uniqueId];
}

- (void)sendFileFailDelegate:(NSXMLElement *)message uniquiId:(NSString *)uniqueId {
    
    [self setAttachmentMessage:message uniquiId:uniqueId];
}

- (void)sendFileProgressDelegate:(NSXMLElement *)message {
    
    [self setAttachmentMessage:message uniquiId:@""];
}

- (void)setAttachmentMessage:(NSXMLElement *)message uniquiId:(NSString *)uniqueId {
    
    message=[self setHeightInMessage:message];
    
    if ([uniqueId isEqualToString:@""]) {
        
        [userData addObject:message];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
        [chatTableView beginUpdates];
        [chatTableView insertRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationBottom];
        [chatTableView endUpdates];
        [chatTableView scrollToRowAtIndexPath:[self indexPathForLastMessage]
                             atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else {
        
        for (int i=(int)userData.count-1; i>=0; i--) {
            
            NSXMLElement *innerElementData = [[userData objectAtIndex:i] elementForName:@"data"];
            if ([[innerElementData attributeStringValueForName:@"chatType"] isEqualToString:@"ImageAttachment"]||[[innerElementData attributeStringValueForName:@"chatType"] isEqualToString:@"FileAttachment"]) {
                
                if ([[[[innerElementData attributeStringValueForName:@"fileName"] componentsSeparatedByString:@"."] objectAtIndex:0] isEqualToString:uniqueId]) {
                    
                    [userData replaceObjectAtIndex:i withObject:message];
                }
            }
        }
    }
    
    if (userData.count > 0) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:userData.count-1 inSection:0];
        [chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    [chatTableView reloadData];
}
#pragma mark - end

#pragma mark - Send file delegates
- (void)sendDocumentDelegateAction:(NSString *)documentName {
    
    //    [self sendImageAttachment:imageName imageCaption:imageCaption friendName:self.friendUserName]
//    [self sendDocumentAttachment:documentName friendName:self.friendUserName];
}

- (void)sendLocationDelegateAction:(NSString *)locationAddress latitude:(NSString *)latitude longitude:(NSString *)longitude {
    
//    [self sendLocationXmppMessage:friendUserJid friendName:self.friendUserName  messageString:locationAddress latitude:latitude longitude:longitude];
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
