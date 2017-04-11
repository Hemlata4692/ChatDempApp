//
//  ChatScreenViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 06/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "ChatScreenViewController.h"
#import "UIPlaceHolderTextView.h"

#import "XMPPMessageArchivingCoreDataStorage.h"
#import "AppDelegateObjectFile.h"
#import "XMPP.h"
#import "NSData+XMPP.h"
#import "CustomFilterViewController.h"

#import "BSKeyboardControls.h"
#import "ChatScreenTableViewCell.h"
#import "SendImageViewController.h"
#import "DocumentAttachmentViewController.h"
#import "UserDefaultManager.h"
#import <AVFoundation/AVFoundation.h>
#import "LocationViewController.h"
#import "SendAudioViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVKit/AVKit.h>

#define navigationBarHeight 64
#define toolbarHeight 0
#define messageTextviewInitialHeight 40
#define messageTextviewHeightLimit 126

#define nameLabelFont [UIFont systemFontOfSize:17]
#define messageLabelFont [UIFont systemFontOfSize:15]
#define dateLabelFont [UIFont systemFontOfSize:14]
#define messageTextViewFont [UIFont systemFontOfSize:17]
#define DEFAULT_FONT(size) [UIFont systemFontOfSize:size]

@interface ChatScreenViewController ()<CustomFilterDelegate,/*BSKeyboardControlsDelegate,*/ UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SendImageDelegate, SendDocumentDelegate, UIDocumentInteractionControllerDelegate, SendLocationDelegate, SendAudioDelegate, AVAudioPlayerDelegate> {
    
    CGFloat messageHeight, messageYValue;
    NSMutableArray *userData;
    NSString *otherUserId;
    int btnTag;
    
//    NSString *loginUserId, *friendUserId;
    UIImage *logedInUserPhoto, *friendUserPhoto;
    NSData *tempImageData1;
    
    //Navigation views
    UIView *navBackView;
    UILabel *navTitleLabel, *navStatusLabel;
    
    float keyboardHeight;
    
    BOOL isAttachmentOpen, isReceiptOffline, isKeyboardHide;
    UIView *imagePreviewView;
    
    //Maintain audio chat
    NSMutableDictionary *chatAudioInfo;
    UILabel *chatAudioStartTime;
    int lastSelectedIndex;
    AVAudioPlayer *player;
    NSTimer *recordingTimer;
    int second, minute, continousSecond;
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

@implementation ChatScreenViewController
@synthesize userDetail, userXmlDetail;
@synthesize messageTextView, sendButtonOutlet;
@synthesize messageView;
@synthesize chatTableView;
@synthesize lastView,meeToProfile,userNameProfile;
@synthesize userProfileImageView, friendProfileImageView;

@synthesize friendUserJid;

#pragma mark - View life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationItem.title=self.friendUserName;
    userProfileImageView = [[UIImageView alloc] init];
    [self addBackBarButton];    //Add navigation bar buttons
    
    [self initializeFriendProfile:friendUserJid];   //Set current friend jid
    chatTableView.backgroundColor=[UIColor whiteColor];
    isAttachmentOpen=false;
    isKeyboardHide=true;
    chatAudioInfo=[NSMutableDictionary new];
}

- (void)viewWillAppear:(BOOL)animated {

//    self.navigationController.navigationBarHidden=NO;
      //Customized navigation bar
    second = 0;
    minute = 0;
    continousSecond = 0;
    if (!isAttachmentOpen) {
        [super viewWillAppear:YES];
        [self addNavigationtitle];
        [self viewInitialized]; //Initialised view
        [self registerForKeyboardNotifications];
        
        [myDelegate showIndicator];
        [self performSelector:@selector(getHistoryChatData) withObject:nil afterDelay:.1];
    }
    else {
        isAttachmentOpen=false;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [recordingTimer invalidate];
    recordingTimer = nil;
    player=nil;
    chatAudioInfo=[NSMutableDictionary new];
    
    if (!isAttachmentOpen) {
    [super viewWillDisappear:YES];
    
    [navBackView removeFromSuperview];
    }
}
#pragma mark - end

#pragma mark - XMPP delegates
- (XMPPStream *)xmppStream {
    
    return [myDelegate xmppStream];
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
    
    switch ([self getPresenceStatus:friendUserJid]) {
        case 0:     // online/available
            [self userOnline];
            break;
        default:    //offline
            [self userOffline];
            break;
    }
    [self setProfileImagesUsingCompletionBlock];
    
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

- (void)setProfileImagesUsingCompletionBlock {
    
    [self getChatProfilePhotoFriendJid:friendUserJid profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto placeholderImage:@"images.png" result:^(NSArray *tempImageArr) {
        
        logedInUserPhoto=[tempImageArr objectAtIndex:0];
        friendUserPhoto=[tempImageArr objectAtIndex:1];
    }];
}
#pragma mark - end

#pragma mark - Customized navigation bar using uiview and also add UIButton & UIAction
- (void)addNavigationtitle {
    
    [navBackView removeFromSuperview];
    navBackView=[[UIView alloc]initWithFrame:CGRectMake(50, 20, [[UIScreen mainScreen] bounds].size.width-100, 40)];
    navBackView.backgroundColor=[UIColor clearColor];
    navTitleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 3, navBackView.frame.size.width, 25)];
    navTitleLabel.backgroundColor=[UIColor clearColor];
    navTitleLabel.text=[self.friendUserName capitalizedString];
    navTitleLabel.textColor=[UIColor whiteColor];
    navTitleLabel.font=[UIFont systemFontOfSize:20];
    navTitleLabel.textAlignment=NSTextAlignmentCenter;
    [navBackView addSubview:navTitleLabel];
    
    navStatusLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, navTitleLabel.frame.origin.y+navTitleLabel.frame.size.height, navBackView.frame.size.width, 12)];
    navStatusLabel.backgroundColor=[UIColor clearColor];
    navStatusLabel.font=[UIFont systemFontOfSize:12];
    navStatusLabel.text=@"";
    navStatusLabel.textColor=[UIColor whiteColor];
    navStatusLabel.textAlignment=NSTextAlignmentCenter;
    [navBackView addSubview:navStatusLabel];
    
    [self.navigationController.view addSubview:navBackView];
}

- (void)addBackBarButton {
    
    UIBarButtonItem *backBarButton,*attachmentBarButton;
    CGRect framing = CGRectMake(0, 0, 25, 25);
    
    UIButton *back = [[UIButton alloc] initWithFrame:framing];
    [back setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backBarButton =[[UIBarButtonItem alloc] initWithCustomView:back];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=backBarButton;
    
    UIButton *attachment = [[UIButton alloc] initWithFrame:framing];
    [attachment setImage:[UIImage imageNamed:@"attachment"] forState:UIControlStateNormal];
    attachmentBarButton =[[UIBarButtonItem alloc] initWithCustomView:attachment];
    [attachment addTarget:self action:@selector(attachmentAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem=attachmentBarButton;
}
#pragma mark - end

#pragma mark - Presence status reflection
- (void)userOnline {
    
    navStatusLabel.text=@"(Online)";
    isReceiptOffline=false;
    navStatusLabel.textColor=[UIColor whiteColor];
}

- (void)userOffline {
    
    navStatusLabel.text=@"(Offline)";
    isReceiptOffline=true;
    navStatusLabel.textColor=[UIColor whiteColor];
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
    
    isKeyboardHide=NO;
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
    
    isKeyboardHide=YES;
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
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
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

#pragma mark - UIActions
- (IBAction)tapGestureOnView:(UITapGestureRecognizer *)sender {
    [messageTextView resignFirstResponder];
}

- (void)tappedOnUserImageImageView:(UIGestureRecognizer *)sender {
    
    [self.view endEditing:YES];
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSXMLElement *innerData=[[userData objectAtIndex:(int)gesture.view.tag] elementForName:@"data"];
    
    UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GlobalImageViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalImageViewController"];
    if ([[innerData attributeStringValueForName:@"from"] isEqualToString:myDelegate.xmppLogedInUserId]) {
        popupView.globalImage=logedInUserPhoto;
    }
    else {
        popupView.globalImage=friendUserPhoto;
    }
    popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:popupView animated:YES completion:nil];
}

- (void)tappedOnImageView:(UIGestureRecognizer *)sender {
    
    [self.view endEditing:YES];
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSXMLElement *innerData=[[userData objectAtIndex:(int)gesture.view.tag] elementForName:@"data"];
    
    if ([[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"FileAttachment"]) {
        NSURL *url = [NSURL fileURLWithPath:[myDelegate documentCacheDirectoryPathFileName:[innerData attributeStringValueForName:@"fileName"]]];
        self.docController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docController.delegate = self;
        [self.docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    }
    else if ([[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"ImageAttachment"]) {
        
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GlobalImageViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"GlobalImageViewController"];
        popupView.globalImage=[UIImage imageWithData:[myDelegate listionSendAttachedImageCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
        popupView.caption=[[[userData objectAtIndex:(int)gesture.view.tag] elementForName:@"body"] stringValue];
        popupView.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
        [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [self presentViewController:popupView animated:YES completion:nil];
    }
    else if ([[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"Location"]) {
    
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
    
    Internet *internet=[[Internet alloc] init];
    if (![internet start]) {
        
        [self sendXmppMessage:friendUserJid friendName:self.friendUserName messageString:messageTextView.text];
    }
}

- (void)backAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)attachmentAction {
    
    if (isReceiptOffline) {
        
        [UserDefaultManager showAlertMessage:@"Alert" message:@"Recipient may be offline so please try again later."];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [messageTextView resignFirstResponder];
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CustomFilterViewController *filterViewObj =[storyboard instantiateViewControllerWithIdentifier:@"CustomFilterViewController"];
            filterViewObj.delegate=self;
            filterViewObj.tableCellheightValue=80;
            NSMutableDictionary *tempAttachment=[NSMutableDictionary new];
            NSMutableArray *tempAttachmentArra=[NSMutableArray new];
            NSMutableArray *tempAttachmentImageArra=[NSMutableArray new];
            [tempAttachment setObject:[NSNumber numberWithInt:1] forKey:@"Documents"];
            [tempAttachmentArra addObject:@"Documents"];
            [tempAttachmentImageArra addObject:@"documentsAttachment"];
            
            [tempAttachment setObject:[NSNumber numberWithInt:2] forKey:@"Camera"];
            [tempAttachmentArra addObject:@"Camera"];
            [tempAttachmentImageArra addObject:@"cameraAttachment"];
            
            [tempAttachment setObject:[NSNumber numberWithInt:3] forKey:@"Gallery"];
            [tempAttachmentArra addObject:@"Gallery"];
            [tempAttachmentImageArra addObject:@"galleryAttachment"];
            
            [tempAttachment setObject:[NSNumber numberWithInt:4] forKey:@"Location"];
            [tempAttachmentArra addObject:@"Location"];
            [tempAttachmentImageArra addObject:@"locationIcon"];
            
            [tempAttachment setObject:[NSNumber numberWithInt:5] forKey:@"Audio"];
            [tempAttachmentArra addObject:@"Audio"];
            [tempAttachmentImageArra addObject:@"audioIcon"];
            
            [tempAttachment setObject:[NSNumber numberWithInt:6] forKey:@"Video"];
            [tempAttachmentArra addObject:@"Video"];
            [tempAttachmentImageArra addObject:@"videoIcon"];
            
            filterViewObj.filterDict=[tempAttachment mutableCopy];
            filterViewObj.filterArray=[tempAttachmentArra mutableCopy];
            filterViewObj.filterImageArray=[tempAttachmentImageArra mutableCopy];
            
            [filterViewObj setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            [self presentViewController:filterViewObj animated:NO completion:nil];
        });
    }
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
    
    if ([[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"ImageAttachment"]||[[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"FileAttachment"]||[[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"Location"]) {
        
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
    else if ([[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"VideoAttachment"]) {
        
        NSLog(@"%f",([[innerData attributeStringValueForName:@"nameHeight"] floatValue]>20?[[innerData attributeStringValueForName:@"nameHeight"] floatValue]:20));
        float mainCellHeight=5+([[innerData attributeStringValueForName:@"nameHeight"] floatValue]>20?[[innerData attributeStringValueForName:@"nameHeight"] floatValue]:20)+5+128+10+20+5; //here mainCellHeight = NameLabel_topSpace + NameHeight + space_Between_NameLabel_And_VideoImage + VideoImageViewHeight + space_Between_VideoImageView_And_DateLabel + DateLabelHeight + DateLabel_BottomSpace
        
        if (userData.count==1 || indexPath.row == 0) {
            
            return mainCellHeight;
        }
        else{
            NSXMLElement* message1 = [userData objectAtIndex:(int)indexPath.row - 1];
            NSXMLElement *innerData1=[message1 elementForName:@"data"];
            if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
                
                return 5+128+10+20+5;//Topspace_VideoImage + VideoImageHeight + space_Between_VideoImage_And_DateLabel + DateLabelHeight + DateLabel_BottomSpace
            }
            else{
                return mainCellHeight;
            }
        }
    }
    else if ([[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"AudioAttachment"]) {
        
        NSLog(@"%f",([[innerData attributeStringValueForName:@"nameHeight"] floatValue]>20?[[innerData attributeStringValueForName:@"nameHeight"] floatValue]:20));
        float mainCellHeight=5+([[innerData attributeStringValueForName:@"nameHeight"] floatValue]>20?[[innerData attributeStringValueForName:@"nameHeight"] floatValue]:20)+5+48+10+20+5; //here mainCellHeight = NameLabel_topSpace + NameHeight + space_Between_NameLabel_And_AudioView + AudioViewHeight + space_Between_AudioView_And_DateLabel + DateLabelHeight + DateLabel_BottomSpace
        
        if (userData.count==1 || indexPath.row == 0) {
            
            return mainCellHeight;
        }
        else{
            NSXMLElement* message1 = [userData objectAtIndex:(int)indexPath.row - 1];
            NSXMLElement *innerData1=[message1 elementForName:@"data"];
            if ([[innerData attributeStringValueForName:@"from"] isEqualToString:[innerData1 attributeStringValueForName:@"from"]]) {
                
                return 5+48+10+20+5;//Topspace_AudioView + AudioViewHeight + space_Between_AudioView_And_DateLabel + DateLabelHeight + DateLabel_BottomSpace
            }
            else{
                return mainCellHeight;
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
            
            //Set cell height according to next message and current message userId's
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
    
    ChatScreenTableViewCell *cell;
    
    cell=[chatTableView dequeueReusableCellWithIdentifier:@"chatCell"];
    if (cell == nil)
    {
        cell=[[ChatScreenTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"chatCell"];
    }
    
    cell.attachedImageView.tag=indexPath.row;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnImageView:)];
    [cell.attachedImageView addGestureRecognizer:tap];
    [cell.attachedImageView setUserInteractionEnabled:YES];
    
    cell.userImage.tag=indexPath.row;
    UITapGestureRecognizer *userImageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnUserImageImageView:)];
    [cell.userImage addGestureRecognizer:userImageTap];
    [cell.userImage setUserInteractionEnabled:YES];
    
    NSXMLElement* message = [userData objectAtIndex:indexPath.row];
    NSXMLElement *innerData=[message elementForName:@"data"];
    if (userData.count==1) {
        
        [cell displaySingleMessageData:message profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto chatType:[innerData attributeStringValueForName:@"chatType"]];
    }
    else if (userData.count>(indexPath.row+1)) {
        
        if ((int)indexPath.row==0) {
            
            [cell displayFirstMessage:message nextmessage:[userData objectAtIndex:indexPath.row+1] profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto chatType:[innerData attributeStringValueForName:@"chatType"]];
        }
        else {
            [cell displayMultipleMessage:message nextmessage:[userData objectAtIndex:indexPath.row+1] previousMessage:[userData objectAtIndex:indexPath.row-1] profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto chatType:[innerData attributeStringValueForName:@"chatType"]];
        }
    }
    else {
        [cell displayLastMessage:message previousMessage:[userData objectAtIndex:indexPath.row-1] profileImageView:logedInUserPhoto friendProfileImageView:friendUserPhoto chatType:[innerData attributeStringValueForName:@"chatType"]];
    }
    
    cell.playPauseButton.tag=indexPath.row;
    cell.videoPlayButton.tag=indexPath.row;
    [cell.playPauseButton addTarget:self action:@selector(playAudioAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.videoPlayButton addTarget:self action:@selector(playVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[innerData attributeStringValueForName:@"chatType"] isEqualToString:@"AudioAttachment"]&&(chatAudioInfo.count!=0)&&([[chatAudioInfo objectForKey:@"fileName"] isEqualToString:[innerData attributeStringValueForName:@"fileName"]])) {
        
        if ([[chatAudioInfo objectForKey:@"isRunning"] boolValue]) {
            [cell.playPauseButton setImage:[UIImage imageNamed:@"recordplay"] forState:UIControlStateNormal];
        }
        else {
            [cell.playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        }
        cell.audioProgress.progress=[[chatAudioInfo objectForKey:@"progress"] floatValue];
        cell.audioStartTime.text=[chatAudioInfo objectForKey:@"startTime"];
    }
    else {
    
        [cell.playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        cell.audioStartTime.text=@"00:00";
        cell.audioProgress.progress=0.0;
    }
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    
//    return (action == @selector(copy:));
//}
//- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
//    
//    if (action == @selector(copy:)) {
//        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//        UILabel *userChat = (UILabel*)[cell viewWithTag:3];
//        [[UIPasteboard generalPasteboard] setString:userChat.text];
//    }
//}
//- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 1;
//}

//- (void)tableViewScrollToBottomAnimated:(BOOL)animated
//{
//    NSInteger numberOfRows = userData.count;
//    if (numberOfRows)
//    {
//        [chatTableView scrollToRowAtIndexPath:[self indexPathForLastMessage]
//                             atScrollPosition:UITableViewScrollPositionBottom animated:animated];
//    }
//}
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

#pragma mark - Custom filter delegate
- (void)customFilterDelegateAction:(int)status{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (status) {
            case 1:
            {
                NSLog(@"1");
                
                UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                DocumentAttachmentViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"DocumentAttachmentViewController"];
                [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                popupView.delegate=self;
                [self presentViewController:popupView animated:YES completion:nil];
            }
                break;
            case 2:
            {
                NSLog(@"2");
                [self openCamera];
            }
                break;
            case 3:
            {
                NSLog(@"3");
                [self openGallery];
            }
                break;
            case 4:
            {
                NSLog(@"4");
                isAttachmentOpen=true;
                UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LocationViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"LocationViewController"];
                //            [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                popupView.delegate=self;
                
                [self presentViewController:popupView animated:YES completion:NULL];
            }
                break;
            case 5:
            {
                UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                SendAudioViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"SendAudioViewController"];
                popupView.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1.0f];
                popupView.delegate=self;
                [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                [self presentViewController:popupView animated:YES completion:nil];
            }
                break;
            case 6:
            {
                NSLog(@"2");
                [self showActionSheetVideo];
            }
            default:
                break;
        }
    });
}

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

#pragma mark - Open video gallery/recorder
- (void)showActionSheetVideo {

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Video Option"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"Video Recorder" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                 
                                                                 isAttachmentOpen=true;
                                                                 UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                 picker.delegate = self;
                                                                 picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
                                                                 picker.allowsEditing = YES;
                                                                 picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                 picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
                                                                 
                                                                 [self presentViewController:picker animated:YES completion:NULL];
                                                             }
                                                         }];
    
    UIAlertAction* galleryAction = [UIAlertAction actionWithTitle:@"Choose from Album" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                              isAttachmentOpen=true;
                                                              UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                                              imagePicker.delegate = self;
                                                              imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
                                                              imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                              imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,nil];
                                                              imagePicker.allowsEditing=NO;
                                                              [self presentViewController:imagePicker animated:YES completion:nil];
                                                          }];
    
    UIAlertAction * defaultAct = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * action) {
                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    [alert addAction:cameraAction];
    [alert addAction:galleryAction];
    [alert addAction:defaultAct];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIImagePickerController delegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if (UTTypeEqual(kUTTypeMovie,
                    (__bridge CFStringRef)[info objectForKey:UIImagePickerControllerMediaType])) {
        
        //Get size of video
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        //Error Container
        NSError *attributesError;
        NSDictionary *fileAttributes=[[NSFileManager defaultManager] attributesOfItemAtPath:[videoUrl path] error:&attributesError];
        NSNumber *fileSizeNumber=[fileAttributes objectForKey:NSFileSize];
        long long fileSize = [fileSizeNumber longLongValue];
        int maxSize=3;
        
        NSString *videoFilePath=[myDelegate getVideoFilePath];
        if ((float)((float)(fileSize/1024)/1024)<=(float)maxSize) {
            //If size is less than or equal to max size then execute this code. And save this video in document folder
            NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
            if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
                NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
                NSString *moviePath = [videoUrl path];
                
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
                    NSData *videoData=[NSData dataWithContentsOfURL:videoUrl];
                    [videoData writeToFile:videoFilePath atomically:NO];
                }
            }
            [self sendVideoFileAction:[videoFilePath lastPathComponent]];
            
        }
        else {
            //If size greater from max size then shows toast.
            [self.view makeToast:[NSString stringWithFormat:@"File size cannot exceed %d MB.",maxSize]];
        }
    }
    else {
    
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SendImageViewController *popupView =[storyboard instantiateViewControllerWithIdentifier:@"SendImageViewController"];
        [popupView setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        popupView.delegate=self;
        popupView.attachImage=[info objectForKey:UIImagePickerControllerOriginalImage];;
        [self presentViewController:popupView animated:YES completion:nil];
    }
}
#pragma mark - end

#pragma mark - Fetch history data
- (void)getHistoryChatData {

    [self getHistoryChatData:friendUserJid];
}
#pragma mark - end

#pragma mark - Send text message response
- (void)XmppSendMessageResponse:(NSXMLElement *)xmpMessage {
    
    [self messagesData:xmpMessage];
    messageTextView.text=@"";
    messageHeight = messageTextviewInitialHeight;
    messageTextView.frame = CGRectMake(messageTextView.frame.origin.x, messageTextView.frame.origin.y, messageTextView.frame.size.width, messageHeight-8);
    if ([[[[xmpMessage elementForName:@"data"] attributeForName:@"chatType"] stringValue] isEqualToString:@"Location"]||isKeyboardHide) {
        
        messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height- messageView.frame.size.height -navigationBarHeight, self.view.bounds.size.width, messageHeight+ 10);
        messageYValue = [UIScreen mainScreen].bounds.size.height -49 -10;
    }
    else {
       
        messageView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-(keyboardHeight+navigationBarHeight+messageHeight+10)  , self.view.bounds.size.width, messageHeight + 10);
    }
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

    switch ([self getPresenceStatus:friendUserJid]) {
        case 0:     // online/available
            [self userOnline];
            break;
        default:    //offline
            [self userOffline];
            break;
    }
}

- (void)historyUpdateNotify:(NSXMLElement *)message {

    [self messagesData:message];
}

#pragma mark - Send image delegates
- (void)sendImageDelegateAction:(int)status imageName:(NSString *)imageName imageCaption:(NSString *)imageCaption {

    if (status==1) {
    
        Internet *internet=[[Internet alloc] init];
        if (![internet start]) {
            
            [self sendImageAttachment:imageName imageCaption:imageCaption friendName:self.friendUserName];
        }
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
- (void)sendVideoFileAction:(NSString *)documentName {
    
    Internet *internet=[[Internet alloc] init];
    if (![internet start]) {
        
        [self sendDocumentAttachment:documentName friendName:self.friendUserName attachmentType:FileAtachmentType_Video timeDuration:@""];
    }
}

- (void)sendDocumentDelegateAction:(NSString *)documentName {

    Internet *internet=[[Internet alloc] init];
    if (![internet start]) {
        
        [self sendDocumentAttachment:documentName friendName:self.friendUserName attachmentType:FileAtachmentType_File timeDuration:@""];
    }
}

- (void)sendLocationDelegateAction:(NSString *)locationAddress latitude:(NSString *)latitude longitude:(NSString *)longitude {

    Internet *internet=[[Internet alloc] init];
    if (![internet start]) {
        
        [self sendLocationXmppMessage:friendUserJid friendName:self.friendUserName  messageString:locationAddress latitude:latitude longitude:longitude];
    }
}
#pragma mark - end

#pragma mark - Send audio file delegates
- (void)sendAudioDelegateAction:(NSString *)fileName timeDuration:(NSString *)timeDuration {

    Internet *internet=[[Internet alloc] init];
    if (![internet start]) {
        
        [self sendDocumentAttachment:fileName friendName:self.friendUserName attachmentType:FileAtachmentType_Audio timeDuration:timeDuration];
    }
}
#pragma mark - end

#pragma mark - Play video handling
- (IBAction)playVideoAction:(UIButton *)sender {
    
    NSXMLElement* message = [userData objectAtIndex:[sender tag]];
    NSXMLElement *innerData=[message elementForName:@"data"];
    
    //play video
    NSURL *videoURL = [NSURL fileURLWithPath:[myDelegate videoPathDocumentCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]];
    AVPlayer *videoplayer = [AVPlayer playerWithURL:videoURL];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = videoplayer;
    [playerViewController.player play];//used to play on start
    [self presentViewController:playerViewController animated:YES completion:nil];
}

#pragma mark - Play audio handling
- (IBAction)playAudioAction:(UIButton *)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0]; // Assuming one section
    ChatScreenTableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
    NSXMLElement* message = [userData objectAtIndex:indexPath.row];
    NSXMLElement *innerData=[message elementForName:@"data"];
    
    if ((lastSelectedIndex==(int)[sender tag])&&(chatAudioInfo.count!=0)&&([[chatAudioInfo objectForKey:@"fileName"] isEqualToString:[innerData attributeStringValueForName:@"fileName"]])) {
        
        [recordingTimer invalidate];
        recordingTimer = nil;
        if ([[chatAudioInfo objectForKey:@"isRunning"] boolValue]) {
            
            [chatAudioInfo setObject:[NSNumber numberWithBool:NO] forKey:@"isRunning"];
            [cell.playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            [player pause];
            
        }
        else {
            
            [chatAudioInfo setObject:[NSNumber numberWithBool:YES] forKey:@"isRunning"];
            [cell.playPauseButton setImage:[UIImage imageNamed:@"recordplay"] forState:UIControlStateNormal];
            [player play];
            recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(startRecordTimer)
                                                            userInfo:nil
                                                             repeats:YES];
        }
    }
    else {
        
        NSIndexPath *lastindexPath = [NSIndexPath indexPathForRow:lastSelectedIndex inSection:0]; // Assuming one section
        ChatScreenTableViewCell *lastcell = [self.chatTableView cellForRowAtIndexPath:lastindexPath];
        [lastcell.playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        lastcell.audioStartTime.text=@"00:00";
        lastcell.audioProgress.progress=0.0;
        
        [recordingTimer invalidate];
        recordingTimer = nil;
        lastSelectedIndex=(int)[sender tag];
        chatAudioInfo=[NSMutableDictionary new];
        second = 0;
        minute = 0;
        continousSecond = 0;
        
        [cell.playPauseButton setImage:[UIImage imageNamed:@"recordplay"] forState:UIControlStateNormal];
        [chatAudioInfo setObject:[NSNumber numberWithBool:YES] forKey:@"isRunning"];
        cell.audioStartTime.text=[NSString stringWithFormat:@"%02d:%02d",minute,second];
        [chatAudioInfo setObject:[NSNumber numberWithFloat:0.0] forKey:@"progress"];
        [chatAudioInfo setObject:[innerData attributeStringValueForName:@"fileName"] forKey:@"fileName"];
        
        NSDateFormatter *timeFormatte=[[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US"];
        [timeFormatte setLocale:locale];
        [timeFormatte setDateFormat:@"mm:ss"];
        
        NSDate *startDate=[timeFormatte dateFromString:@"00:00"];
        NSDate *endDate=[timeFormatte dateFromString:[innerData attributeStringValueForName:@"timeDuration"]];
        
        NSTimeInterval secs = [endDate timeIntervalSinceDate:startDate];
        NSLog(@"Seconds --------> %f", secs);
        [chatAudioInfo setObject:[NSNumber numberWithFloat:secs] forKey:@"timelimit"];
        cell.audioProgress.progress=[[chatAudioInfo objectForKey:@"progress"] floatValue];
        
        [chatAudioInfo setObject:[NSString stringWithFormat:@"%02d:%02d",minute,second] forKey:@"startTime"];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[myDelegate audioPathDocumentCacheDirectoryFileName:[innerData attributeStringValueForName:@"fileName"]]] error:nil];
        [player setDelegate:self];
        [player play];
        recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(startRecordTimer)
                                                        userInfo:nil
                                                         repeats:YES];
    }
}

//Set timer
//Wet recording timer in minutes and seconds
- (void)startRecordTimer {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastSelectedIndex inSection:0]; // Assuming one section
    ChatScreenTableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
    
    continousSecond++;
    minute = (continousSecond /60) % 60;
    second = (continousSecond  % 60);
    
    [chatAudioInfo setObject:[NSNumber numberWithFloat:(float)continousSecond/[[chatAudioInfo objectForKey:@"timelimit"] floatValue]] forKey:@"progress"];
    [chatAudioInfo setObject:[NSString stringWithFormat:@"%02d:%02d",minute,second] forKey:@"startTime"];
    cell.audioProgress.progress=[[chatAudioInfo objectForKey:@"progress"] floatValue];
    cell.audioStartTime.text=[chatAudioInfo objectForKey:@"startTime"];
}
//end

//AVAudioPlayer delegate method
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)tempPlayer successfully:(BOOL)flag {
    //if recording finished set timer to 00:00 again
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastSelectedIndex inSection:0]; // Assuming one section
    ChatScreenTableViewCell *cell = [self.chatTableView cellForRowAtIndexPath:indexPath];
    second = 0;
    minute = 0;
    continousSecond = 0;
    chatAudioInfo=[NSMutableDictionary new];
    [cell.playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    cell.audioStartTime.text=[NSString stringWithFormat:@"%02d:%02d",minute,second];
    cell.audioProgress.progress=0.0;
    
    [recordingTimer invalidate];
    recordingTimer = nil;
    if ([player play]) {
        [player stop];
    }
}
#pragma mark - end
@end
