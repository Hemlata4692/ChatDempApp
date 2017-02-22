//
//  EditUserStatusViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 22/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "EditUserStatusViewController.h"

@interface EditUserStatusViewController () {

    NSString *currentStatus;
    UIToolbar *toolBar;
    int textCount;
    int textLimit;
    NSMutableDictionary *profileDic;
    UIImageView *tempImageView;
}

@property (strong, nonatomic) IBOutlet UILabel *statusTitle;
@property (strong, nonatomic) IBOutlet UIView *showStatusView;
@property (strong, nonatomic) IBOutlet UILabel *showStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *showStatusSeperetor;
@property (strong, nonatomic) IBOutlet UIButton *editStatusButton;

@property (strong, nonatomic) IBOutlet UIView *editStatusView;
@property (strong, nonatomic) IBOutlet UITextField *editStatusField;
@property (strong, nonatomic) IBOutlet UITextView *editStatusTextView;
@property (strong, nonatomic) IBOutlet UILabel *statusCount;

@end

@implementation EditUserStatusViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"Status";
    textLimit=100;
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    currentStatus=@"";
    tempImageView=[[UIImageView alloc]init];
    self.editStatusTextView.textContainer.maximumNumberOfLines = 1;
    self.editStatusTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingHead;
    [self addToolBar];
    [self customizedView:NO];
    
    [self setProfileImageUsingCompletionBlock];
    [self getStatusDataUsingCompletionBlock];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Custom accessors
- (void)customizedView:(bool)isEdit {

    if (isEdit) {
        self.navigationItem.leftBarButtonItem=nil;
        self.showStatusView.hidden=true;
        self.editStatusView.hidden=false;
        self.statusTitle.text=@"Add new status";
        [self.editStatusTextView becomeFirstResponder];
    }
    else {
        [self addBackBarButton];
        self.showStatusLabel.text=currentStatus;
        self.showStatusView.hidden=false;
        self.editStatusView.hidden=true;
        self.statusTitle.text=@"Your current status";
        self.showStatusView.translatesAutoresizingMaskIntoConstraints=YES;
        self.showStatusLabel.translatesAutoresizingMaskIntoConstraints=YES;
        self.showStatusSeperetor.translatesAutoresizingMaskIntoConstraints=YES;
        self.editStatusButton.translatesAutoresizingMaskIntoConstraints=YES;
        
        CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 72,200);
        CGRect textRect=[currentStatus
                         boundingRectWithSize:size
                         options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}
                         context:nil];
        self.showStatusLabel.frame=CGRectMake(0, 8, [[UIScreen mainScreen] bounds].size.width - 72, textRect.size.height);
        self.showStatusView.frame=CGRectMake(8, 49, [[UIScreen mainScreen] bounds].size.width - 16, self.showStatusLabel.frame.size.height+16);
        self.showStatusSeperetor.frame=CGRectMake(self.showStatusLabel.frame.origin.x+self.showStatusLabel.frame.size.width+11, (self.showStatusView.frame.size.height/2)-(43/2), 1, 43);
        self.editStatusButton.frame=CGRectMake(self.showStatusView.frame.size.width-30-8, (self.showStatusView.frame.size.height/2)-(30/2), 30, 30);
    }
}

- (void)addToolBar {

    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    toolBar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    
    [toolBar setItems:[NSArray arrayWithObjects: cancelButton, flexSpace, doneButton, nil] animated:NO];
    
    [self.editStatusTextView setInputAccessoryView:toolBar];
}
#pragma mark - end

#pragma mark - Fetch current status
- (void)getStatusDataUsingCompletionBlock {
    
    [self getEditProfileData:myDelegate.xmppLogedInUserId result:^(NSDictionary *tempProfileData) {
        // do something with your BOOL

        profileDic=[tempProfileData mutableCopy];
//        self.userNameField.text=[profileDic objectForKey:@"Name"];
//        self.userStatusField.text=[profileDic objectForKey:@"UserStatus"];
//        self.mobileNumberField.text=[profileDic objectForKey:@"PhoneNumber"];
//        self.emailIdField.text=[profileDic objectForKey:@"EmailAddress"];
        
//        NSLog(@" Desc:%@ \n address:%@ \n birthDay:%@ \n gender:%@",[profileDic objectForKey:@"Description"],[profileDic objectForKey:@"Address"],[profileDic objectForKey:@"UserBirthDay"],[profileDic objectForKey:@"Gender"]);
        
        currentStatus=[tempProfileData objectForKey:@"UserStatus"];
        textCount=(int)currentStatus.length;
        self.statusCount.text=[NSString stringWithFormat:@"%d",textLimit-textCount];
        [self customizedView:NO];
    }];
}

- (void)setProfileImageUsingCompletionBlock {
    
    [self getProfilePhoto:myDelegate.xmppLogedInUserId profileImageView:tempImageView placeholderImage:@"images.png" result:^(UIImage *tempImage) {
        // do something with your BOOL
        if (tempImage!=nil) {
            tempImageView.image=tempImage;
        }
        else {
            
            tempImageView.image=[UIImage imageNamed:@"profile_camera"];
        }
    }];
}

#pragma mark - end

#pragma mark - TextView delegates
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if(textView.text.length>=textLimit && range.length == 0) {
        
        return NO;
    }
    else if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    self.statusCount.text = [NSString stringWithFormat:@"%lu",textLimit - textView.text.length];
}
#pragma mark - end

#pragma mark - UIButton actions
- (void)backAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editStatus:(UIButton *)sender {
    
    self.editStatusTextView.text=currentStatus;
    [self customizedView:YES];
}

- (IBAction)doneAction:(UIBarButtonItem *)sender {
    
    [self.view endEditing:YES];
    [myDelegate showIndicator];
    [self performSelector:@selector(userUpdateProfile) withObject:nil afterDelay:0.1];
    
     NSLog(@" Desc:%@ \n address:%@ \n birthDay:%@ \n gender:%@",[profileDic objectForKey:@"Description"],[profileDic objectForKey:@"Address"],[profileDic objectForKey:@"UserBirthDay"],[profileDic objectForKey:@"Gender"]);
}

- (IBAction)cancelAction:(UIBarButtonItem *)sender {
    
    [self.editStatusTextView resignFirstResponder];
    [self customizedView:NO];
}
#pragma mark - end

#pragma mark - Webservice
- (void)userUpdateProfile {
    
    //You can add these optional values. if you donot add these values then set @"" as default value
    NSMutableDictionary *profileData=[NSMutableDictionary new];
    [profileData setObject:[profileDic objectForKey:@"Name"] forKey:self.xmppName];
    [profileData setObject:[profileDic objectForKey:@"PhoneNumber"] forKey:self.xmppPhoneNumber];
    [profileData setObject:[profileDic objectForKey:@"Gender"] forKey:self.xmppGender];
    [profileData setObject:[profileDic objectForKey:@"Address"] forKey:self.xmppAddress];
    [profileData setObject:self.editStatusTextView.text forKey:self.xmppUserStatus];
    [profileData setObject:[profileDic objectForKey:@"Description"] forKey:self.xmppDescription];
    [profileData setObject:[profileDic objectForKey:@"EmailAddress"] forKey:self.xmppEmailAddress];
    [profileData setObject:[profileDic objectForKey:@"UserBirthDay"] forKey:self.xmppUserBirthDay];
    
    [self userUpdateProfileUsingVCard:profileData profilePlaceholder:@"profile_camera" profileImageView:tempImageView.image];
}
#pragma mark - end

#pragma mark - XMPPProfileView methods
- (void)XMPPvCardTempModuleDidUpdateMyvCardSuccessResponse {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        currentStatus=self.editStatusTextView.text;
        [self customizedView:NO];
        [myDelegate stopIndicator];
    });
}

- (void)XMPPvCardTempModuleDidUpdateMyvCardFailResponse {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [myDelegate stopIndicator];
    });
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
