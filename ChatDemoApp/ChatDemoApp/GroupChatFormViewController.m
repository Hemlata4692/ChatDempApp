//
//  GroupChatFormViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 07/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "GroupChatFormViewController.h"
#import "UIPlaceHolderTextView.h"

@interface GroupChatFormViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *addRoomName;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *groupDescription;
@property (strong, nonatomic) IBOutlet UIButton *groupImage;
@end

@implementation GroupChatFormViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"New Group";
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.groupImage.layer.cornerRadius=35;
    self.groupImage.layer.masksToBounds=YES;
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back_white"]];
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
    
    UIBarButtonItem *addBarButton;
    framing = CGRectMake(0, 0, 50, 40);
    UIButton *addChat = [[UIButton alloc] initWithFrame:framing];
    [addChat setTitle:@"Next" forState:UIControlStateNormal];
    addBarButton =[[UIBarButtonItem alloc] initWithCustomView:addChat];
    [addChat addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:addBarButton, nil];
}
#pragma mark - end

#pragma mark - IBActions
//Back button action
- (void)backButtonAction :(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextAction :(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addGroup:(UIButton *)sender {
}

- (IBAction)selectImage:(UIButton *)sender {
    
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
