//
//  GroupChatFormViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 07/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "GroupChatFormViewController.h"
#import "UIPlaceHolderTextView.h"
#import "BSKeyboardControls.h"
#import "UserDefaultManager.h"
#import "GroupInvitationViewController.h"

@interface GroupChatFormViewController ()<BSKeyboardControlsDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {

     int textLimit;
}

@property (strong, nonatomic) IBOutlet UITextField *addRoomName;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *groupDescription;
@property (strong, nonatomic) IBOutlet UIButton *groupImage;

//Declare BSKeyboard variable
@property (strong, nonatomic) BSKeyboardControls *keyboardControls;
@end

@implementation GroupChatFormViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    textLimit=100;
    self.navigationItem.title=@"New Group";
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:@[self.addRoomName, self.groupDescription]]];
    [self.keyboardControls setDelegate:self];
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back_white"]];
    [self viewInitialized];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    //Adding textfield to keyboard controls array
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

- (void)viewInitialized {

    self.groupImage.layer.cornerRadius=35;
    self.groupImage.layer.masksToBounds=YES;
    
    self.groupDescription.contentInset = UIEdgeInsetsMake(-5, 5, 0, 0);
    self.groupDescription.placeholder=@"Room Desccription (Optional)";
    self.groupDescription.layer.borderColor=[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:0.5].CGColor;
    self.groupDescription.layer.borderWidth=1;
    self.groupDescription.placeholderTextColor=[UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:0.5];
    self.groupDescription.text=@"";
}

#pragma mark - Custom accessors
- (void)addLeftBarButtonWithImage:(UIImage *)backImage {
    
    UIBarButtonItem *backBarButton;
    CGRect framing = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    UIButton *back = [[UIButton alloc] initWithFrame:framing];
    [back setBackgroundImage:backImage forState:UIControlStateNormal];
    backBarButton =[[UIBarButtonItem alloc] initWithCustomView:back];
    [back addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:backBarButton, nil];
    
    UIBarButtonItem *addBarButton;
    framing = CGRectMake(0, 0, 50, 40);
    UIButton *addChat = [[UIButton alloc] initWithFrame:framing];
    [addChat setTitle:@"Next" forState:UIControlStateNormal];
    addBarButton =[[UIBarButtonItem alloc] initWithCustomView:addChat];
    [addChat addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:addBarButton, nil];
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
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

#pragma mark - TextVoew delegates
- (void)textViewDidBeginEditing:(UITextView *)textView {
    //handle user taps text view to type text
    
    [self.keyboardControls setActiveField:textView];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (range.length > 0 && [text length] == 0)
    {
        return YES;
    }
    if (textView.text.length > 99 && range.length == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if ((textLimit - (int)self.groupDescription.text.length)<0) {
    
        self.groupDescription.text=[self.groupDescription.text substringToIndex:[self.groupDescription.text length]+(textLimit - (int)self.groupDescription.text.length)];
    }
}
#pragma mark - end

#pragma mark - IBActions
//Back button action
- (void)backButtonAction :(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextAction :(id)sender {
    
    [self.view endEditing:YES];
    if (([self.addRoomName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)) {
        
        [UserDefaultManager showAlertMessage:@"Alert" message:@"Subject field is required."];
    }
    else {
    
        GroupInvitationViewController *invitationViewObj = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GroupInvitationViewController"];
        invitationViewObj.isCreate=true;
        invitationViewObj.roomSubject=self.addRoomName.text;
        invitationViewObj.roomNickname=@"";
        invitationViewObj.roomDescription=self.groupDescription.text;
        if (![self image:self.groupImage.imageView.image isEqualTo:[UIImage imageNamed:@"groupPlaceholderImage.png"]]) {
            invitationViewObj.friendImage=self.groupImage.imageView.image;
        }
        else {
        
            invitationViewObj.friendImage=nil;
        }
        
        [self.navigationController pushViewController:invitationViewObj animated:YES];
    }
}

- (BOOL)image:(UIImage *)image1 isEqualTo:(UIImage *)image2
{
    NSData *data1 = UIImagePNGRepresentation(image1);
    NSData *data2 = UIImagePNGRepresentation(image2);
    
    return [data1 isEqual:data2];
}

- (IBAction)selectImage:(UIButton *)sender {
    
    [self.view endEditing:YES];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
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
#pragma mark - end


#pragma mark - ImagePicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info {
    
    [self.groupImage setImage:image forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:NO completion:NULL];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
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
