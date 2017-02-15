//
//  SendImageViewController.m
//  ChatDemoApp
//
//  Created by Ranosys on 15/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "SendImageViewController.h"

@interface SendImageViewController ()

@property (strong, nonatomic) IBOutlet UITextField *captionTextField;
@property (strong, nonatomic) IBOutlet UIImageView *attachedImage;
@end

@implementation SendImageViewController
@synthesize attachImage;

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.attachedImage.image=attachImage;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

//#pragma mark - Get image name
//- (NSString *)getImageName:(UIImage*)image {
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSLocale *locale = [[NSLocale alloc]
//                        initWithLocaleIdentifier:@"en_US"];
//    [dateFormatter setLocale:locale];
//    [dateFormatter setDateFormat:@"ddMMYYhhmmss"];
//    NSString * datestr = [dateFormatter stringFromDate:[NSDate date]];
//    NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpeg",datestr,[UserDefaultManager getValue:@"userId"]];
//    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];
//    NSData * imageData = UIImageJPEGRepresentation(image, 0.1);
//    [imageData writeToFile:filePath atomically:YES];
//    return fileName;
//}
//#pragma mark - end

#pragma mark - UIAction
- (IBAction)cancel:(UIButton *)sender {
    
    [_delegate sendImageDelegateAction:2 imageName:@"" imageCaption:@""];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)send:(UIButton *)sender {
    
    [_delegate sendImageDelegateAction:1 imageName:[myDelegate setOtherImageInLocalDB:attachImage]  imageCaption:self.captionTextField.text];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
