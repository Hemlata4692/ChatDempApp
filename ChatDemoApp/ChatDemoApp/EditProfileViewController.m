//
//  EditProfileViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 02/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "EditProfileViewController.h"
#import "BSKeyboardControls.h"
#import "UITextField+Validations.h"
#import "UserDefaultManager.h"

@interface EditProfileViewController ()<BSKeyboardControlsDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
    NSDictionary *profileDic;
}

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UITextField *userNameField;
@property (strong, nonatomic) IBOutlet UITextField *emailIdField;
@property (strong, nonatomic) IBOutlet UITextField *mobileNumberField;
@property (strong, nonatomic) IBOutlet UITextField *userStatusField;

//Declare BSKeyboard variable
@property (strong, nonatomic) BSKeyboardControls *keyboardControls;
@end

@implementation EditProfileViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"Edit Profile";
    
    //Adding textfield to keyboard controls array
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[self.userNameField, self.userStatusField]]];
    [self.keyboardControls setDelegate:self];
    
    self.profileImage.layer.cornerRadius=100/2;
    self.profileImage.layer.masksToBounds=YES;
    
    [self addBarButton];
    [self setCurrentProfileView];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Custom accessors
- (void)setCurrentProfileView {
    
    [self setProfileImageUsingCompletionBlock];
    
//    switch ([self getPresenceStatus:myDelegate.xmppLogedInUserId]) {
//        case 0:     // online/available

//            break;
//        default:    //offline

//            break;
//    }
    
    [self setProfileDataUsingCompletionBlock];
}

- (void)setProfileDataUsingCompletionBlock {
    
    [self getEditProfileData:myDelegate.xmppLogedInUserId result:^(NSDictionary *tempProfileData) {
        // do something with your BOOL
        
        profileDic=tempProfileData;
        self.userNameField.text=[profileDic objectForKey:@"Name"];
        self.userStatusField.text=[profileDic objectForKey:@"UserStatus"];
        self.mobileNumberField.text=[profileDic objectForKey:@"PhoneNumber"];
        self.emailIdField.text=[profileDic objectForKey:@"EmailAddress"];
        
        NSLog(@" Desc:%@ \n address:%@ \n birthDay:%@ \n gender:%@",[profileDic objectForKey:@"Description"],[profileDic objectForKey:@"Address"],[profileDic objectForKey:@"UserBirthDay"],[profileDic objectForKey:@"Gender"]);
    }];
}

- (void)setProfileImageUsingCompletionBlock {
    
    [self getProfilePhoto:myDelegate.xmppLogedInUserId profileImageView:self.profileImage placeholderImage:@"images.png" result:^(UIImage *tempImage) {
        // do something with your BOOL
        if (tempImage!=nil) {
            self.profileImage.image=tempImage;
        }
        else {
            
            self.profileImage.image=[UIImage imageNamed:@"profile_camera"];
        }
    }];
}

- (void)addBarButton {
    
    UIBarButtonItem *backBarButton;
    CGRect framing = CGRectMake(0, 0, 25, 25);
    
    UIButton *back = [[UIButton alloc] initWithFrame:framing];
    [back setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backBarButton =[[UIBarButtonItem alloc] initWithCustomView:back];
    [back addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=backBarButton;
}
#pragma mark - end

#pragma mark - Keyboard control delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction {
    
    UIView *view;
    view = field.superview.superview.superview;
}

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls {
    
    [keyboardControls.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - Textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self.keyboardControls setActiveField:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField == self.mobileNumberField) {
        if (range.length > 0 && [string length] == 0)
        {
            return YES;
        }
        if (textField.text.length > 9 && range.length == 0)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else if(textField == self.userStatusField) {
        if (range.length > 0 && [string length] == 0)
        {
            return YES;
        }
        if (textField.text.length > 99 && range.length == 0)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else {
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

#pragma mark - Login validation
- (BOOL)performValidationsForUpdate {
    
    if ([self.userNameField isEmpty]&&[self.mobileNumberField isEmpty]&&[self.userStatusField isEmpty]) {
        [UserDefaultManager showAlertMessage:@"Alert" message:@"Please fill in the required fields."];
        return NO;
    }
    else if(self.mobileNumberField.text.length<10) {
        [UserDefaultManager showAlertMessage:@"Alert" message:@"Please enter valid mobile number."];
        return NO;
    }
    else {
        return YES;
    }
}
#pragma mark - end

#pragma mark - UIButton actions
- (IBAction)changeImage:(UIButton *)sender {
    
    [self.view endEditing:YES];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             
                                                             UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                             picker.delegate = self;
                                                             picker.allowsEditing = NO;
                                                             picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                             [self presentViewController:picker animated:YES completion:NULL];
                                                         }];
    
    UIAlertAction* galleryAction = [UIAlertAction actionWithTitle:@"Choose from Gallery" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                              picker.delegate = self;
                                                              picker.allowsEditing = NO;
                                                              picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                              picker.navigationBar.tintColor = [UIColor whiteColor];
                                                              
                                                              [self presentViewController:picker animated:YES completion:NULL];
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

- (IBAction)updateProfile:(UIButton *)sender {
    
    [self.view endEditing:YES];
    if ([self performValidationsForUpdate]) {
        
        [myDelegate showIndicator];
        [self performSelector:@selector(userUpdateProfile) withObject:nil afterDelay:0.1];
    }
}

- (void)backAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - end

#pragma mark - Webservice
- (void)userUpdateProfile {
    
    //You can add these optional values. if you donot add these values then set @"" as default value
    NSMutableDictionary *profileData=[NSMutableDictionary new];
    [profileData setObject:self.userNameField.text forKey:self.xmppName];
    [profileData setObject:self.mobileNumberField.text forKey:self.xmppPhoneNumber];
    [profileData setObject:[profileDic objectForKey:@"Gender"] forKey:self.xmppGender];
    [profileData setObject:[profileDic objectForKey:@"Address"] forKey:self.xmppAddress];
    [profileData setObject:self.userStatusField.text forKey:self.xmppUserStatus];
    [profileData setObject:[profileDic objectForKey:@"Description"] forKey:self.xmppDescription];
    [profileData setObject:self.emailIdField.text forKey:self.xmppEmailAddress];
    [profileData setObject:[profileDic objectForKey:@"UserBirthDay"] forKey:self.xmppUserBirthDay];
    
    [self userUpdateProfileUsingVCard:profileData profilePlaceholder:@"profile_camera" profileImageView:self.profileImage.image];
}

#pragma mark - ImagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image1 editingInfo:(NSDictionary *)info {
    
    self.profileImage.image=image1;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - end

#pragma mark - XMPPProfileView methods
- (void)XmppUserPresenceUpdateNotify {
    
    switch ([self getPresenceStatus:myDelegate.xmppLogedInUserId]) {
        case 0:     // online/available
//            _presenceStatus.backgroundColor=[UIColor greenColor];
            break;
        default:    //offline
//            _presenceStatus.backgroundColor=[UIColor redColor];
            break;
    }
}

//- (void)XmppProileUpdateNotify {
//    
//    
//}

- (void)XMPPvCardTempModuleDidUpdateMyvCardSuccessResponse {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        [self saveUpdatedImage:self.profileImage.image placeholderImageName:@"profile_camera" jid:myDelegate.xmppLogedInUserId];
        [myDelegate stopIndicator];  
    });
}

- (void)XMPPvCardTempModuleDidUpdateMyvCardFailResponse {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [myDelegate stopIndicator];
    });
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
