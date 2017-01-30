//
//  RegisterViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 09/01/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "RegisterViewController.h"
#import "UITextField+Validations.h"
#import "UserDefaultManager.h"
#import "BSKeyboardControls.h"

@interface RegisterViewController ()<BSKeyboardControlsDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *mobileField;
@property (strong, nonatomic) IBOutlet UITextField *password;

//Declare BSKeyboard variable
@property (strong, nonatomic) BSKeyboardControls *keyboardControls;
@end

@implementation RegisterViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title=@"Register";
    
    //Adding textfield to keyboard controls array
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[self.usernameField, self.emailField, self.mobileField, self.password]]];
    [self.keyboardControls setDelegate:self];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back_white"]];
    self.profileImageView.layer.cornerRadius=96/2;
    self.profileImageView.layer.masksToBounds=YES;
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
    
    if(textField == self.mobileField) {
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
- (BOOL)performValidationsForRegister {
    
    if ([self.usernameField isEmpty]&&[self.emailField isEmpty]&&[self.mobileField isEmpty]&&[self.password isEmpty]) {
        [UserDefaultManager showAlertMessage:@"Alert" message:@"Please fill in the required fields."];
        return NO;
    }
    else if(![self.emailField isValidEmail]) {
        [UserDefaultManager showAlertMessage:@"Alert" message:@"Please validate your email field."];
        return NO;
    }
    else if(self.mobileField.text.length<10) {
        [UserDefaultManager showAlertMessage:@"Alert" message:@"Please enter valid mobile number."];
        return NO;
    }
    else {
        return YES;
    }
}
#pragma mark - end

#pragma mark - IBActions
//Back button action
- (void)backButtonAction :(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)profilePhoto:(UIButton *)sender {
    
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

- (IBAction)register:(UIButton *)sender {
    
    [self.view endEditing:YES];
    if ([self performValidationsForRegister]) {
    
        [myDelegate showIndicator];
        [self performSelector:@selector(userSignUp) withObject:nil afterDelay:0.1];
    }
}
#pragma mark - end

#pragma mark - ImagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image1 editingInfo:(NSDictionary *)info {
    
    self.profileImageView.image=image1;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - end

#pragma mark - Webservice
- (void)userSignUp {
    
    //If you want no password form then commented this code
    //You can add these optional values
    NSMutableDictionary *profileData=[NSMutableDictionary new];
    [profileData setObject:self.usernameField.text forKey:self.xmppName];
    [profileData setObject:self.mobileField.text forKey:self.xmppPhoneNumber];
    [profileData setObject:@"" forKey:self.xmppGender];
    [profileData setObject:@"" forKey:self.xmppAddress];
    [profileData setObject:@"My status" forKey:self.xmppUserStatus];
    [profileData setObject:@"" forKey:self.xmppDescription];
    [profileData setObject:self.emailField.text forKey:self.xmppEmailAddress];
    [profileData setObject:@"" forKey:self.xmppUserBirthDay];
    
    [self userRegistrationPassword:self.password.text userName:self.mobileField.text profileData:profileData profilePlaceholder:@"profile_camera" profileImageView:self.profileImageView.image];
    /*//If you want no password form then uncomment this code
    [self userRegistrationWithoutPassword:self.mobileField.text profileData:profileData profilePlaceholder:@"profile_camera" profileImageView:self.profileImageView.image];
     */
}

//Register XMPP method
- (void)UserDidRegister {
    
    [myDelegate stopIndicator];
    [self loginRegisteredUser:self.mobileField.text password:self.password.text];//After registration using this method, logged in user.
    /*//If you want no password form then uncomment this code
    [self loginRegisteredUser:self.mobileField.text];//After registration using this method, logged in user.
     */
    
//    [UserDefaultManager setValue:self.usernameField.text key:@"userName"];
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController * homeView = [storyboard instantiateViewControllerWithIdentifier:@"DashboardNavigation"];
//    [myDelegate.window setRootViewController:homeView];
//    [myDelegate.window makeKeyAndVisible];
}

- (void)UserDidNotRegister:(ErrorType)errorType {
    
    [myDelegate stopIndicator];
    NSString *errorMessage=@"";
    if(errorType==XMPP_UserExist){
        
        errorMessage=@"Username Already Exists!";
    }
    else if(errorType==XMPP_InvalidUserName){
        //This error is called when your Name is as username
        errorMessage=@"Please enter valid username";
    }
    else {
        errorMessage=@"Something went wrong, Please try again.";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Registration Failed!" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        // Ok action example
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}
//end

- (void)loginUserDidAuthenticatedResult {
    NSLog(@"a");
        [UserDefaultManager setValue:self.usernameField.text key:@"userName"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController * homeView = [storyboard instantiateViewControllerWithIdentifier:@"DashboardNavigation"];
        [myDelegate.window setRootViewController:homeView];
        [myDelegate.window makeKeyAndVisible];
}

@end
